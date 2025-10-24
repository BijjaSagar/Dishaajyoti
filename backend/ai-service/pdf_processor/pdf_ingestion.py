"""
PDF Ingestion - Process PDF books and store in vector database
"""

import os
import logging
from pathlib import Path
from typing import List, Dict
import PyPDF2
import pdfplumber
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.schema import Document

from vector_store.pinecone_store import PineconeVectorStore

logger = logging.getLogger(__name__)


class PDFIngestion:
    """Handles PDF processing and ingestion into vector database"""

    def __init__(self):
        """Initialize PDF ingestion"""
        self.vector_store = PineconeVectorStore()
        self.pdf_books_path = Path(os.getenv('PDF_BOOKS_PATH', '../pdf-books'))

        # Text splitter configuration
        chunk_size = int(os.getenv('CHUNK_SIZE', 1000))
        chunk_overlap = int(os.getenv('CHUNK_OVERLAP', 200))

        self.text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=chunk_size,
            chunk_overlap=chunk_overlap,
            length_function=len,
            separators=["\n\n", "\n", ". ", " ", ""]
        )

        logger.info("PDF Ingestion initialized")

    def extract_text_from_pdf(self, pdf_path: Path) -> str:
        """
        Extract text from PDF file

        Args:
            pdf_path: Path to PDF file

        Returns:
            Extracted text
        """
        try:
            text = ""

            # Try pdfplumber first (better for complex PDFs)
            try:
                with pdfplumber.open(pdf_path) as pdf:
                    for page in pdf.pages:
                        page_text = page.extract_text()
                        if page_text:
                            text += page_text + "\n\n"
            except Exception as e:
                logger.warning(f"pdfplumber failed for {pdf_path}, trying PyPDF2: {str(e)}")

                # Fallback to PyPDF2
                with open(pdf_path, 'rb') as file:
                    pdf_reader = PyPDF2.PdfReader(file)
                    for page in pdf_reader.pages:
                        page_text = page.extract_text()
                        if page_text:
                            text += page_text + "\n\n"

            if not text.strip():
                raise ValueError(f"No text could be extracted from {pdf_path}")

            logger.info(f"Extracted {len(text)} characters from {pdf_path.name}")
            return text

        except Exception as e:
            logger.error(f"Error extracting text from {pdf_path}: {str(e)}")
            raise

    def process_pdf(self, pdf_path: Path, service_type: str) -> List[Document]:
        """
        Process a single PDF file

        Args:
            pdf_path: Path to PDF file
            service_type: Type of service (jyotisha, vastu, etc.)

        Returns:
            List of Document objects
        """
        try:
            logger.info(f"Processing PDF: {pdf_path.name} for service: {service_type}")

            # Extract text
            text = self.extract_text_from_pdf(pdf_path)

            # Split into chunks
            text_chunks = self.text_splitter.split_text(text)

            # Create Document objects with metadata
            documents = []
            for i, chunk in enumerate(text_chunks):
                doc = Document(
                    page_content=chunk,
                    metadata={
                        'source': pdf_path.name,
                        'service_type': service_type,
                        'chunk_index': i,
                        'total_chunks': len(text_chunks)
                    }
                )
                documents.append(doc)

            logger.info(f"Created {len(documents)} document chunks from {pdf_path.name}")
            return documents

        except Exception as e:
            logger.error(f"Error processing PDF {pdf_path}: {str(e)}")
            raise

    def ingest_service_pdfs(self, service_type: str) -> Dict[str, int]:
        """
        Ingest all PDFs for a specific service type

        Args:
            service_type: Type of service (jyotisha, vastu, etc.)

        Returns:
            Dict with ingestion statistics
        """
        try:
            service_path = self.pdf_books_path / service_type

            if not service_path.exists():
                raise ValueError(f"Service path does not exist: {service_path}")

            # Find all PDF files
            pdf_files = list(service_path.glob('*.pdf'))

            if not pdf_files:
                logger.warning(f"No PDF files found in {service_path}")
                return {
                    'service_type': service_type,
                    'pdfs_processed': 0,
                    'total_chunks': 0,
                    'status': 'no_files'
                }

            logger.info(f"Found {len(pdf_files)} PDF files for {service_type}")

            # Process all PDFs
            all_documents = []
            processed_files = []

            for pdf_file in pdf_files:
                try:
                    documents = self.process_pdf(pdf_file, service_type)
                    all_documents.extend(documents)
                    processed_files.append(pdf_file.name)
                except Exception as e:
                    logger.error(f"Failed to process {pdf_file}: {str(e)}")
                    continue

            # Ingest into vector store
            if all_documents:
                logger.info(f"Ingesting {len(all_documents)} documents for {service_type}")
                self.vector_store.add_documents(all_documents, namespace=service_type)
                logger.info(f"Successfully ingested documents for {service_type}")

            return {
                'service_type': service_type,
                'pdfs_processed': len(processed_files),
                'processed_files': processed_files,
                'total_chunks': len(all_documents),
                'status': 'success'
            }

        except Exception as e:
            logger.error(f"Error ingesting PDFs for {service_type}: {str(e)}")
            raise

    def ingest_all_services(self) -> List[Dict[str, int]]:
        """
        Ingest PDFs for all service types

        Returns:
            List of ingestion statistics for each service
        """
        results = []

        # Get all service directories
        service_dirs = [d for d in self.pdf_books_path.iterdir() if d.is_dir()]

        logger.info(f"Found {len(service_dirs)} service directories")

        for service_dir in service_dirs:
            service_type = service_dir.name
            try:
                result = self.ingest_service_pdfs(service_type)
                results.append(result)
            except Exception as e:
                logger.error(f"Failed to ingest service {service_type}: {str(e)}")
                results.append({
                    'service_type': service_type,
                    'status': 'error',
                    'error': str(e)
                })

        return results

    def reingest_service(self, service_type: str) -> Dict[str, int]:
        """
        Delete and re-ingest PDFs for a service

        Args:
            service_type: Service to reingest

        Returns:
            Ingestion statistics
        """
        try:
            logger.info(f"Reingesting service: {service_type}")

            # Delete existing namespace
            logger.info(f"Deleting existing namespace: {service_type}")
            self.vector_store.delete_namespace(service_type)

            # Ingest PDFs
            result = self.ingest_service_pdfs(service_type)

            return result

        except Exception as e:
            logger.error(f"Error reingesting {service_type}: {str(e)}")
            raise


def main():
    """Main function for command-line usage"""
    import argparse

    parser = argparse.ArgumentParser(description='Ingest PDF books into vector database')
    parser.add_argument('--service', type=str, help='Service type to ingest (e.g., jyotisha, vastu)')
    parser.add_argument('--all', action='store_true', help='Ingest all services')
    parser.add_argument('--reingest', action='store_true', help='Delete and reingest')

    args = parser.parse_args()

    # Setup logging
    from config.logging_config import setup_logging
    setup_logging()

    # Load environment variables
    from dotenv import load_dotenv
    load_dotenv()

    ingestion = PDFIngestion()

    if args.all:
        logger.info("Ingesting all services...")
        results = ingestion.ingest_all_services()
        print("\n=== Ingestion Results ===")
        for result in results:
            print(f"\nService: {result['service_type']}")
            print(f"Status: {result.get('status', 'unknown')}")
            if result.get('status') == 'success':
                print(f"PDFs processed: {result['pdfs_processed']}")
                print(f"Total chunks: {result['total_chunks']}")
            elif result.get('error'):
                print(f"Error: {result['error']}")

    elif args.service:
        service = args.service

        if args.reingest:
            logger.info(f"Reingesting service: {service}")
            result = ingestion.reingest_service(service)
        else:
            logger.info(f"Ingesting service: {service}")
            result = ingestion.ingest_service_pdfs(service)

        print("\n=== Ingestion Result ===")
        print(f"Service: {result['service_type']}")
        print(f"Status: {result.get('status', 'unknown')}")
        if result.get('status') == 'success':
            print(f"PDFs processed: {result['pdfs_processed']}")
            print(f"Files: {', '.join(result.get('processed_files', []))}")
            print(f"Total chunks: {result['total_chunks']}")

    else:
        parser.print_help()


if __name__ == '__main__':
    main()
