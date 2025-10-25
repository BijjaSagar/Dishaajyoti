"""
Pinecone vector store integration
"""

import os
import logging
from typing import List, Dict, Any
from pinecone import Pinecone, ServerlessSpec
from langchain_openai import OpenAIEmbeddings
from langchain.schema import Document

logger = logging.getLogger(__name__)


class PineconeVectorStore:
    """Manages vector storage and retrieval using Pinecone"""

    def __init__(self):
        """Initialize Pinecone connection"""
        self.api_key = os.getenv('PINECONE_API_KEY')
        self.environment = os.getenv('PINECONE_ENVIRONMENT', 'us-west-1')
        self.index_name = os.getenv('PINECONE_INDEX_NAME', 'dishaajyoti-knowledge')
        self.embedding_dimension = int(os.getenv('EMBEDDING_DIMENSION', 1536))

        if not self.api_key:
            raise ValueError("PINECONE_API_KEY environment variable is required")

        # Initialize Pinecone
        self.pc = Pinecone(api_key=self.api_key)

        # Initialize embeddings
        self.embeddings = OpenAIEmbeddings(
            model=os.getenv('EMBEDDING_MODEL', 'text-embedding-3-small')
        )

        # Create or connect to index
        self._setup_index()

        logger.info(f"Pinecone vector store initialized with index: {self.index_name}")

    def _setup_index(self):
        """Create index if it doesn't exist"""
        try:
            # List existing indexes
            existing_indexes = [index.name for index in self.pc.list_indexes()]

            if self.index_name not in existing_indexes:
                logger.info(f"Creating new Pinecone index: {self.index_name}")
                self.pc.create_index(
                    name=self.index_name,
                    dimension=self.embedding_dimension,
                    metric='cosine',
                    spec=ServerlessSpec(
                        cloud='aws',
                        region=self.environment
                    )
                )
                logger.info(f"Index {self.index_name} created successfully")
            else:
                logger.info(f"Using existing index: {self.index_name}")

            self.index = self.pc.Index(self.index_name)

        except Exception as e:
            logger.error(f"Error setting up Pinecone index: {str(e)}")
            raise

    def add_documents(self, documents: List[Document], namespace: str) -> None:
        """
        Add documents to vector store

        Args:
            documents: List of LangChain Document objects
            namespace: Namespace to store documents (e.g., 'jyotisha', 'vastu')
        """
        try:
            logger.info(f"Adding {len(documents)} documents to namespace: {namespace}")

            # Try new langchain-pinecone first, fallback to community version
            try:
                from langchain_pinecone import PineconeVectorStore as LangchainPinecone

                vectorstore = LangchainPinecone.from_documents(
                    documents=documents,
                    embedding=self.embeddings,
                    index_name=self.index_name,
                    namespace=namespace
                )
            except ImportError:
                from langchain_community.vectorstores import Pinecone as LangchainPinecone

                vectorstore = LangchainPinecone.from_documents(
                    documents=documents,
                    embedding=self.embeddings,
                    index_name=self.index_name,
                    namespace=namespace
                )

            logger.info(f"Successfully added documents to namespace: {namespace}")

        except Exception as e:
            logger.error(f"Error adding documents to Pinecone: {str(e)}")
            raise

    def similarity_search(
        self,
        query: str,
        namespace: str,
        k: int = 5,
        filter: Dict[str, Any] = None
    ) -> List[Document]:
        """
        Search for similar documents

        Args:
            query: Search query
            namespace: Namespace to search in
            k: Number of results to return
            filter: Metadata filter

        Returns:
            List of similar documents
        """
        try:
            # Try new langchain-pinecone first, fallback to community version
            try:
                from langchain_pinecone import PineconeVectorStore as LangchainPinecone

                vectorstore = LangchainPinecone(
                    index=self.index,
                    embedding=self.embeddings,
                    namespace=namespace
                )
            except ImportError:
                from langchain_community.vectorstores import Pinecone as LangchainPinecone

                vectorstore = LangchainPinecone(
                    index=self.index,
                    embedding=self.embeddings,
                    namespace=namespace
                )

            results = vectorstore.similarity_search(
                query=query,
                k=k,
                filter=filter
            )

            logger.info(f"Found {len(results)} similar documents in namespace: {namespace}")
            return results

        except Exception as e:
            logger.error(f"Error during similarity search: {str(e)}")
            raise

    def similarity_search_with_score(
        self,
        query: str,
        namespace: str,
        k: int = 5
    ) -> List[tuple]:
        """
        Search for similar documents with relevance scores

        Args:
            query: Search query
            namespace: Namespace to search in
            k: Number of results to return

        Returns:
            List of (document, score) tuples
        """
        try:
            # Try new langchain-pinecone first, fallback to community version
            try:
                from langchain_pinecone import PineconeVectorStore as LangchainPinecone

                vectorstore = LangchainPinecone(
                    index=self.index,
                    embedding=self.embeddings,
                    namespace=namespace
                )
            except ImportError:
                from langchain_community.vectorstores import Pinecone as LangchainPinecone

                vectorstore = LangchainPinecone(
                    index=self.index,
                    embedding=self.embeddings,
                    namespace=namespace
                )

            results = vectorstore.similarity_search_with_score(
                query=query,
                k=k
            )

            logger.info(f"Found {len(results)} documents with scores in namespace: {namespace}")
            return results

        except Exception as e:
            logger.error(f"Error during similarity search with score: {str(e)}")
            raise

    def delete_namespace(self, namespace: str) -> None:
        """
        Delete all vectors in a namespace

        Args:
            namespace: Namespace to delete
        """
        try:
            self.index.delete(delete_all=True, namespace=namespace)
            logger.info(f"Deleted namespace: {namespace}")
        except Exception as e:
            logger.error(f"Error deleting namespace: {str(e)}")
            raise

    def get_stats(self) -> Dict[str, Any]:
        """Get index statistics"""
        try:
            stats = self.index.describe_index_stats()
            return stats
        except Exception as e:
            logger.error(f"Error getting index stats: {str(e)}")
            raise
