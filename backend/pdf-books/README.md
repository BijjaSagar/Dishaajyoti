# PDF Books Repository

## 📚 Where to Place Your PDF Books

Place your service-specific PDF books in the corresponding folders below:

### Service Categories

```
pdf-books/
├── jyotisha/          ← Place Vedic Jyotish/Astrology books here
├── vastu/             ← Place Vastu Shastra books here
├── numerology/        ← Place Numerology books here
├── palmistry/         ← Place Palmistry books here
├── gems-stones/       ← Place Gemology/Ratna Shastra books here
├── muhurta/           ← Place Muhurta (auspicious timing) books here
├── prashna/           ← Place Prashna (horary astrology) books here
└── remedies/          ← Place Remedial measures books here
```

## 📖 How to Add PDF Books

1. **Copy your PDF files** into the appropriate service folder
2. **Naming convention**: Use descriptive names
   - Example: `jyotisha_fundamentals.pdf`
   - Example: `vastu_principles_residential.pdf`
   - Example: `numerology_chaldean_system.pdf`

3. **Multiple books per service**: You can add multiple PDF books in each folder
   - The AI will learn from ALL books in the folder
   - More comprehensive knowledge base = better answers

## 🔄 After Adding PDFs

Once you add PDF books:
1. Run the PDF ingestion script: `python backend/ai-service/pdf_processor/ingest_pdfs.py`
2. The system will:
   - Extract text from all PDFs
   - Create embeddings (vector representations)
   - Store in Pinecone vector database
   - Make knowledge available to AI agents

## ✅ Supported Formats

- PDF files (.pdf)
- Text should be selectable (not scanned images)
- For scanned PDFs, OCR will be applied automatically

## 📊 Status

After ingestion, you can check which books are active:
- Access admin panel at: `http://localhost:8000/admin/pdf-books`
- View ingestion logs: `backend/ai-service/logs/ingestion.log`

## 🚀 Quick Start

**Example: Adding a Jyotisha book**

```bash
# 1. Copy your PDF to the folder
cp ~/Downloads/brihat_parashara_hora.pdf backend/pdf-books/jyotisha/

# 2. Run ingestion
cd backend/ai-service
python pdf_processor/ingest_pdfs.py --service jyotisha

# 3. Verify
# The book is now available to the Jyotisha AI agent
```

## 💡 Tips

- **Quality matters**: Clear, well-formatted PDFs give better results
- **Language**: PDFs in English work best, Hindi support available
- **Size**: No size limit, but larger files take longer to process
- **Updates**: Re-run ingestion after adding new books

---

**Need help?** Contact: support@dishaajyoti.com
