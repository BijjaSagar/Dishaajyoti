# DishaAjyoti Backend

Complete backend system with PHP REST API and Python AI microservice powered by OpenAI, LangChain, and Pinecone.

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter Mobile App                    │
└───────────────────────┬─────────────────────────────────┘
                        │ HTTP/REST
                        ▼
┌─────────────────────────────────────────────────────────┐
│               PHP REST API (Port 8000)                   │
│  - Authentication & User Management                      │
│  - Service Catalog                                       │
│  - Payment Processing                                    │
│  - Report Generation Orchestration                       │
└───────────────────────┬─────────────────────────────────┘
                        │ HTTP
                        ▼
┌─────────────────────────────────────────────────────────┐
│         Python AI Microservice (Port 5000)               │
│  - OpenAI GPT-4 Integration                              │
│  - LangChain RAG Pipeline                                │
│  - Pinecone Vector Database                              │
│  - PDF Knowledge Base Processing                         │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│              MySQL Database (Port 3306)                  │
│  - User Data                                             │
│  - Services & Payments                                   │
│  - Reports & AI Responses                                │
└─────────────────────────────────────────────────────────┘
```

## 📁 Project Structure

```
backend/
├── php-api/                  # PHP REST API
│   ├── public/
│   │   └── index.php        # Entry point
│   ├── src/
│   │   ├── Controllers/     # API controllers
│   │   ├── Models/          # Data models
│   │   ├── Services/        # Business logic
│   │   └── Middleware/      # Auth middleware
│   ├── routes/
│   │   └── api.php          # Route definitions
│   ├── config/
│   │   └── database.php     # DB configuration
│   ├── composer.json        # PHP dependencies
│   └── .env.example         # Environment template
│
├── ai-service/              # Python AI Microservice
│   ├── app/
│   │   ├── agents/          # AI agents for each service
│   │   ├── services/        # Query & report services
│   │   └── models/          # Data models
│   ├── pdf_processor/       # PDF ingestion
│   ├── vector_store/        # Pinecone integration
│   ├── config/              # Configuration
│   ├── app.py               # Flask entry point
│   ├── requirements.txt     # Python dependencies
│   └── .env.example         # Environment template
│
├── pdf-books/               # 📚 PDF knowledge base
│   ├── jyotisha/           # Vedic astrology books
│   ├── vastu/              # Vastu shastra books
│   ├── numerology/         # Numerology books
│   ├── palmistry/          # Palmistry books
│   ├── gems-stones/        # Gemology books
│   ├── muhurta/            # Muhurta books
│   ├── prashna/            # Prashna books
│   └── remedies/           # Remedial measures
│
├── database/
│   └── schema.sql          # MySQL database schema
│
└── config/                  # Shared configuration
```

## 🚀 Quick Start Guide

### Prerequisites

- PHP 8.0+
- Python 3.9+
- MySQL 8.0+
- Composer
- pip

### 1. Database Setup

```bash
# Create database
mysql -u root -p
CREATE DATABASE dishaajyoti CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EXIT;

# Import schema
mysql -u root -p dishaajyoti < backend/database/schema.sql
```

### 2. PHP API Setup

```bash
cd backend/php-api

# Install dependencies
composer install

# Copy environment file
cp .env.example .env

# Edit .env with your settings
nano .env
```

**Important .env variables:**
```env
DB_DATABASE=dishaajyoti
DB_USERNAME=root
DB_PASSWORD=your_password

JWT_SECRET=generate-a-secure-random-key

AI_SERVICE_URL=http://localhost:5000
AI_SERVICE_API_KEY=your-secure-api-key

OPENAI_API_KEY=sk-your-openai-api-key
PINECONE_API_KEY=your-pinecone-api-key
```

**Start PHP server:**
```bash
# Development server
php -S localhost:8000 -t public

# Or use Apache/Nginx (recommended for production)
```

### 3. Python AI Service Setup

```bash
cd backend/ai-service

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Copy environment file
cp .env.example .env

# Edit .env with your API keys
nano .env
```

**Important .env variables:**
```env
OPENAI_API_KEY=sk-your-openai-api-key-here
PINECONE_API_KEY=your-pinecone-api-key
PINECONE_INDEX_NAME=dishaajyoti-knowledge

API_KEY=your-secure-api-key  # Must match PHP API
```

**Start AI service:**
```bash
# Development
python app.py

# Production
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

### 4. Ingest PDF Books

```bash
cd backend/ai-service

# Activate virtual environment
source venv/bin/activate

# Place your PDF books in backend/pdf-books/{service-name}/

# Ingest all services
python pdf_processor/pdf_ingestion.py --all

# Or ingest specific service
python pdf_processor/pdf_ingestion.py --service jyotisha

# Re-ingest (delete and re-add)
python pdf_processor/pdf_ingestion.py --service jyotisha --reingest
```

## 📚 Adding PDF Books

### Where to Place Books

1. Navigate to `backend/pdf-books/`
2. Choose the appropriate service folder:
   - `jyotisha/` - Vedic astrology books
   - `vastu/` - Vastu shastra books
   - `numerology/` - Numerology books
   - `palmistry/` - Palmistry books
   - etc.

3. Copy your PDF files:
```bash
cp ~/path/to/your/book.pdf backend/pdf-books/jyotisha/
```

4. Run ingestion:
```bash
cd backend/ai-service
python pdf_processor/pdf_ingestion.py --service jyotisha
```

### Supported PDF Types

✅ Text-based PDFs (preferred)
✅ Scanned PDFs with OCR
✅ English and Hindi content
✅ Any file size

## 🔑 API Endpoints

### PHP REST API (Port 8000)

#### Authentication
- `POST /api/v1/auth/register` - User registration
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/refresh` - Refresh token
- `POST /api/v1/auth/logout` - Logout
- `GET /api/v1/auth/me` - Get current user

#### Services
- `GET /api/v1/services` - List all services
- `GET /api/v1/services/{id}` - Get service details
- `GET /api/v1/services/categories` - List categories
- `GET /api/v1/services/featured` - Featured services

#### User Profile
- `GET /api/v1/user/profile` - Get profile
- `PUT /api/v1/user/profile` - Update profile
- `GET /api/v1/user/reports` - Get user reports

#### AI Queries
- `POST /api/v1/ai/query` - Ask AI a question
- `POST /api/v1/ai/chat` - Conversational chat

#### Payments
- `POST /api/v1/payments/create-order` - Create payment order
- `POST /api/v1/payments/verify` - Verify payment
- `GET /api/v1/payments/history` - Payment history

#### Reports
- `POST /api/v1/reports/generate` - Generate report
- `GET /api/v1/reports` - List reports
- `GET /api/v1/reports/{id}` - Get report details

### Python AI Service (Port 5000)

- `GET /health` - Health check
- `POST /api/query` - Process AI query
- `POST /api/chat` - Conversational chat
- `POST /api/generate-report` - Generate comprehensive report
- `GET /api/agents` - List available agents

## 💡 Example Usage

### Query Example

```bash
curl -X POST http://localhost:8000/api/v1/ai/query \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "service_id": 1,
    "query": "What does my birth chart say about career?",
    "context": {
      "date_of_birth": "1990-05-15",
      "time_of_birth": "14:30",
      "place_of_birth": "New Delhi"
    }
  }'
```

### Chat Example

```bash
curl -X POST http://localhost:8000/api/v1/ai/chat \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "service_id": 1,
    "message": "Tell me more about my 10th house",
    "session_id": "session_123"
  }'
```

## 🔧 Configuration

### OpenAI Configuration

Get your API key from: https://platform.openai.com/api-keys

Recommended model: `gpt-4-turbo-preview` (fast and accurate)

### Pinecone Configuration

1. Sign up at: https://www.pinecone.io/
2. Create a new index:
   - Name: `dishaajyoti-knowledge`
   - Dimensions: `1536`
   - Metric: `cosine`
   - Cloud: AWS (or your preference)
   - Region: `us-west-1` (or closest to you)

3. Get your API key from the Pinecone dashboard

### Performance Tuning

**For faster responses:**
- Use `gpt-3.5-turbo` instead of `gpt-4`
- Reduce `CHUNK_SIZE` in .env
- Enable Redis caching
- Use CDN for static assets

**For better accuracy:**
- Use `gpt-4-turbo-preview`
- Increase `k` parameter in similarity search
- Add more PDF books to knowledge base
- Fine-tune prompts in agent classes

## 🐛 Troubleshooting

### PDF Ingestion Fails

```bash
# Check PDF format
file backend/pdf-books/jyotisha/your-book.pdf

# Try with a single PDF first
python pdf_processor/pdf_ingestion.py --service jyotisha

# Check logs
tail -f backend/ai-service/logs/ai-service.log
```

### AI Service Connection Error

```bash
# Verify AI service is running
curl http://localhost:5000/health

# Check firewall settings
# Check .env API_KEY matches in both services
```

### Database Connection Error

```bash
# Test MySQL connection
mysql -u root -p -e "SHOW DATABASES;"

# Verify credentials in .env
# Check MySQL is running
```

## 📊 Monitoring

### Check Vector Database Status

```python
from vector_store.pinecone_store import PineconeVectorStore

store = PineconeVectorStore()
stats = store.get_stats()
print(stats)
```

### View Logs

```bash
# AI Service logs
tail -f backend/ai-service/logs/ai-service.log

# PHP logs
tail -f backend/php-api/logs/app.log
```

## 🔒 Security

- JWT tokens for authentication
- API key protection for AI service
- Input validation and sanitization
- SQL injection prevention
- Rate limiting (implement in production)
- HTTPS in production

## 📈 Scaling

For production deployment:

1. **PHP API**: Use Nginx + PHP-FPM
2. **AI Service**: Use Gunicorn with multiple workers
3. **Database**: MySQL replication
4. **Caching**: Redis for query results
5. **Load Balancer**: Nginx for multiple instances
6. **CDN**: CloudFlare for static assets

## 📝 License

Proprietary - DishaAjyoti

## 🆘 Support

For issues or questions, contact: support@dishaajyoti.com

---

**Built with ❤️ using OpenAI GPT-4, LangChain, and Pinecone**
