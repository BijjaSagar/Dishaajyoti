"""
Query Service - Handles AI query processing
"""

import logging
import time
from typing import Dict, Any, List
from app.agents.base_agent import BaseAgent

logger = logging.getLogger(__name__)


class QueryService:
    """Service for processing AI queries"""

    def __init__(self, agent: BaseAgent):
        """
        Initialize query service

        Args:
            agent: AI agent to use for processing queries
        """
        self.agent = agent

    def process_query(self, query: str, context: Dict[str, Any] = None) -> Dict[str, Any]:
        """
        Process a single query

        Args:
            query: User's question
            context: Additional context data

        Returns:
            Dict containing answer, sources, and metadata
        """
        try:
            start_time = time.time()

            logger.info(f"Processing query for agent: {self.agent.agent_type}")
            logger.debug(f"Query: {query}")

            # Generate response using the agent
            result = self.agent.generate_response(query, context)

            # Calculate processing time
            processing_time = int((time.time() - start_time) * 1000)  # ms

            # Add metadata
            result['processing_time_ms'] = processing_time
            result['timestamp'] = time.time()

            logger.info(f"Query processed successfully in {processing_time}ms")

            return result

        except Exception as e:
            logger.error(f"Error processing query: {str(e)}", exc_info=True)
            raise

    def process_chat(
        self,
        message: str,
        history: List[Dict[str, str]],
        context: Dict[str, Any] = None
    ) -> Dict[str, Any]:
        """
        Process a conversational chat message

        Args:
            message: User's message
            history: Conversation history
            context: Additional context data

        Returns:
            Dict containing response and metadata
        """
        try:
            start_time = time.time()

            logger.info(f"Processing chat for agent: {self.agent.agent_type}")
            logger.debug(f"Message: {message}")

            # Generate chat response using the agent
            result = self.agent.generate_chat_response(message, history, context)

            # Calculate processing time
            processing_time = int((time.time() - start_time) * 1000)  # ms

            # Add metadata
            result['processing_time_ms'] = processing_time
            result['timestamp'] = time.time()

            logger.info(f"Chat processed successfully in {processing_time}ms")

            return result

        except Exception as e:
            logger.error(f"Error processing chat: {str(e)}", exc_info=True)
            raise
