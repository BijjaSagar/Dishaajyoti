"""
Base Agent class for all AI agents
"""

import os
import logging
from abc import ABC, abstractmethod
from typing import List, Dict, Any
from langchain_openai import ChatOpenAI
from langchain.chains import ConversationalRetrievalChain
from langchain.prompts import PromptTemplate
from langchain.memory import ConversationBufferMemory

from vector_store.pinecone_store import PineconeVectorStore

logger = logging.getLogger(__name__)


class BaseAgent(ABC):
    """Base class for all AI agents"""

    def __init__(self, agent_type: str, namespace: str):
        """
        Initialize base agent

        Args:
            agent_type: Type of agent (jyotisha, vastu, etc.)
            namespace: Pinecone namespace for this agent's knowledge base
        """
        self.agent_type = agent_type
        self.namespace = namespace

        # Initialize OpenAI
        self.llm = ChatOpenAI(
            model=os.getenv('OPENAI_MODEL', 'gpt-4-turbo-preview'),
            temperature=float(os.getenv('OPENAI_TEMPERATURE', 0.7)),
            max_tokens=int(os.getenv('OPENAI_MAX_TOKENS', 2000))
        )

        # Initialize vector store
        self.vector_store = PineconeVectorStore()

        logger.info(f"Initialized {agent_type} agent with namespace: {namespace}")

    @abstractmethod
    def get_system_prompt(self) -> str:
        """
        Get the system prompt for this agent
        Must be implemented by subclasses
        """
        pass

    @abstractmethod
    def get_agent_description(self) -> str:
        """
        Get description of what this agent does
        Must be implemented by subclasses
        """
        pass

    def search_knowledge_base(self, query: str, k: int = 5) -> List[Any]:
        """
        Search the agent's knowledge base

        Args:
            query: Search query
            k: Number of results to return

        Returns:
            List of relevant documents
        """
        try:
            results = self.vector_store.similarity_search_with_score(
                query=query,
                namespace=self.namespace,
                k=k
            )
            return results
        except Exception as e:
            logger.error(f"Error searching knowledge base: {str(e)}")
            return []

    def format_context(self, documents: List[tuple]) -> str:
        """
        Format retrieved documents into context string

        Args:
            documents: List of (document, score) tuples

        Returns:
            Formatted context string
        """
        if not documents:
            return "No relevant information found in knowledge base."

        context_parts = []
        for i, (doc, score) in enumerate(documents, 1):
            # Only include documents with good relevance score
            if score > 0.7:  # Adjust threshold as needed
                context_parts.append(f"Reference {i} (Relevance: {score:.2f}):\n{doc.page_content}\n")

        if not context_parts:
            return "No highly relevant information found in knowledge base."

        return "\n".join(context_parts)

    def generate_response(
        self,
        query: str,
        context_data: Dict[str, Any] = None
    ) -> Dict[str, Any]:
        """
        Generate a response to a query

        Args:
            query: User's question
            context_data: Additional context (birth details, etc.)

        Returns:
            Dict containing answer and metadata
        """
        try:
            # Search knowledge base
            documents = self.search_knowledge_base(query)

            # Format context
            knowledge_context = self.format_context(documents)

            # Build enhanced prompt
            system_prompt = self.get_system_prompt()

            user_context = ""
            if context_data:
                user_context = self._format_user_context(context_data)

            full_prompt = f"""{system_prompt}

KNOWLEDGE BASE REFERENCE:
{knowledge_context}

{user_context}

USER QUESTION:
{query}

Please provide a detailed, accurate answer based on the knowledge base references and traditional principles.
If the knowledge base doesn't have sufficient information, clearly state what you can and cannot answer confidently.
"""

            # Generate response
            response = self.llm.invoke(full_prompt)

            # Extract source information
            sources = []
            for doc, score in documents:
                if score > 0.7:
                    sources.append({
                        'content': doc.page_content[:200] + '...',
                        'metadata': doc.metadata,
                        'relevance_score': float(score)
                    })

            return {
                'answer': response.content,
                'sources': sources,
                'confidence': self._calculate_confidence(documents),
                'agent_type': self.agent_type
            }

        except Exception as e:
            logger.error(f"Error generating response: {str(e)}", exc_info=True)
            raise

    def generate_chat_response(
        self,
        message: str,
        chat_history: List[Dict[str, str]],
        context_data: Dict[str, Any] = None
    ) -> Dict[str, Any]:
        """
        Generate a conversational response

        Args:
            message: User's message
            chat_history: Previous conversation
            context_data: Additional context

        Returns:
            Dict containing answer and metadata
        """
        try:
            # Search knowledge base
            documents = self.search_knowledge_base(message)
            knowledge_context = self.format_context(documents)

            # Build conversation context
            conversation = ""
            for msg in chat_history[-5:]:  # Last 5 messages
                role = msg.get('role', 'user')
                content = msg.get('content', '')
                conversation += f"{role.upper()}: {content}\n"

            # Build prompt
            system_prompt = self.get_system_prompt()
            user_context = self._format_user_context(context_data) if context_data else ""

            full_prompt = f"""{system_prompt}

KNOWLEDGE BASE REFERENCE:
{knowledge_context}

{user_context}

CONVERSATION HISTORY:
{conversation}

USER MESSAGE:
{message}

Please respond naturally while maintaining accuracy based on the knowledge base and conversation context.
"""

            # Generate response
            response = self.llm.invoke(full_prompt)

            # Extract sources
            sources = []
            for doc, score in documents:
                if score > 0.7:
                    sources.append({
                        'content': doc.page_content[:200] + '...',
                        'relevance_score': float(score)
                    })

            return {
                'answer': response.content,
                'sources': sources,
                'agent_type': self.agent_type
            }

        except Exception as e:
            logger.error(f"Error generating chat response: {str(e)}", exc_info=True)
            raise

    def _format_user_context(self, context_data: Dict[str, Any]) -> str:
        """Format user context data"""
        if not context_data:
            return ""

        context_parts = ["USER CONTEXT:"]
        for key, value in context_data.items():
            if value:
                context_parts.append(f"- {key.replace('_', ' ').title()}: {value}")

        return "\n".join(context_parts)

    def _calculate_confidence(self, documents: List[tuple]) -> float:
        """Calculate confidence score based on document relevance"""
        if not documents:
            return 0.0

        # Average of top scores
        scores = [score for _, score in documents if score > 0.5]
        if not scores:
            return 0.3

        return min(sum(scores) / len(scores), 1.0)
