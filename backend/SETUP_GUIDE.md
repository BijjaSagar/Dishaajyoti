# 🚀 Complete Setup Guide for DishaAjyoti Backend

## Step-by-Step Installation

### Step 1: Prepare Your Environment

```bash
# Update system
sudo apt update && sudo apt upgrade -y  # Linux
# or
brew update  # macOS

# Install required software
sudo apt install php8.1 php8.1-mysql php8.1-curl php8.1-mbstring  # Linux
# or
brew install php mysql  # macOS

# Install Python 3.9+
sudo apt install python3 python3-pip python3-venv
# or
brew install python@3.9

# Install MySQL
sudo apt install mysql-server
# or
brew install mysql

# Install Composer (PHP package manager)
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
```

### Step 2: Get API Keys

#### OpenAI API Key
1. Go to https://platform.openai.com/
2. Sign up or log in
3. Navigate to API Keys
4. Click "Create new secret key"
5. Copy the key (starts with `sk-`)
6. **Cost**: ~$0.02 per 1000 tokens with GPT-4

#### Pinecone API Key
1. Go to https://www.pinecone.io/
2. Sign up (free tier available)
3. Create a new project
4. Go to API Keys section
5. Copy your API key
6. **Free tier**: 100k vectors, sufficient for testing

### Step 3: Setup Database

```bash
# Start MySQL
sudo systemctl start mysql  # Linux
# or
brew services start mysql  # macOS

# Secure MySQL installation
sudo mysql_secure_installation

# Create database
mysql -u root -p
```

In MySQL console:
```sql
CREATE DATABASE dishaajyoti CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'dishaajyoti'@'localhost' IDENTIFIED BY 'YourSecurePassword123!';
GRANT ALL PRIVILEGES ON dishaajyoti.* TO 'dishaajyoti'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

Import schema:
```bash
cd /path/to/Dishaajyoti
mysql -u dishaajyoti -p dishaajyoti < backend/database/schema.sql
```

### Step 4: Setup PHP API

```bash
cd backend/php-api

# Install dependencies
composer install

# Copy and configure environment
cp .env.example .env
nano .env  # or use your preferred editor
```

Update .env:
```env
# Database
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=dishaajyoti
DB_USERNAME=dishaajyoti
DB_PASSWORD=YourSecurePassword123!

# JWT (generate a random 64-character string)
JWT_SECRET=your-64-character-random-secret-key-here

# AI Service
AI_SERVICE_URL=http://localhost:5000
AI_SERVICE_API_KEY=create-a-secure-random-key-123

# OpenAI
OPENAI_API_KEY=sk-your-openai-key-here

# Pinecone
PINECONE_API_KEY=your-pinecone-key-here
PINECONE_ENVIRONMENT=us-west1-gcp
PINECONE_INDEX_NAME=dishaajyoti-knowledge
```

**Generate secure JWT secret:**
```bash
# Linux/macOS
openssl rand -hex 32

# Or use online generator
# https://www.uuidgenerator.net/
```

**Test PHP API:**
```bash
# Start development server
php -S localhost:8000 -t public

# In another terminal, test
curl http://localhost:8000/api/v1/services
```

### Step 5: Setup Python AI Service

```bash
cd backend/ai-service

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate  # Linux/macOS
# or
venv\Scripts\activate  # Windows

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Copy and configure environment
cp .env.example .env
nano .env
```

Update .env:
```env
# Flask
FLASK_ENV=development
FLASK_DEBUG=True
PORT=5000

# API Security (must match PHP API)
API_KEY=create-a-secure-random-key-123

# OpenAI (use same key as PHP API)
OPENAI_API_KEY=sk-your-openai-key-here
OPENAI_MODEL=gpt-4-turbo-preview

# Pinecone (use same credentials as PHP API)
PINECONE_API_KEY=your-pinecone-key-here
PINECONE_ENVIRONMENT=us-west1-gcp
PINECONE_INDEX_NAME=dishaajyoti-knowledge
```

**Create Pinecone Index:**

Option 1: Via Pinecone Dashboard
1. Go to https://app.pinecone.io/
2. Click "Create Index"
3. Name: `dishaajyoti-knowledge`
4. Dimensions: `1536`
5. Metric: `cosine`
6. Click Create

Option 2: Via Python
```python
from pinecone import Pinecone, ServerlessSpec

pc = Pinecone(api_key='your-api-key')

pc.create_index(
    name='dishaajyoti-knowledge',
    dimension=1536,
    metric='cosine',
    spec=ServerlessSpec(cloud='aws', region='us-west-1')
)
```

**Test AI Service:**
```bash
# Start AI service
python app.py

# In another terminal, test
curl http://localhost:5000/health
```

### Step 6: Add PDF Books

```bash
# Navigate to pdf-books directory
cd backend/pdf-books

# Create a test directory if needed
mkdir -p jyotisha

# Copy your PDF books
cp ~/path/to/your/jyotish-book.pdf jyotisha/

# Example books to add:
# jyotisha/ - Brihat Parashara Hora Shastra, Jataka Parijata, Phaladeepika
# vastu/ - Vastu Shastra texts, residential vastu guides
# numerology/ - Chaldean numerology, Pythagorean system books
# palmistry/ - Hand analysis books, Indian palmistry texts
```

### Step 7: Ingest PDF Books into AI

```bash
cd backend/ai-service

# Make sure virtual environment is activated
source venv/bin/activate

# Ingest all PDF books
python pdf_processor/pdf_ingestion.py --all

# Or ingest specific service
python pdf_processor/pdf_ingestion.py --service jyotisha

# Expected output:
# Processing PDF: book1.pdf for service: jyotisha
# Created 145 document chunks from book1.pdf
# Ingesting 145 documents for jyotisha
# Successfully ingested documents for jyotisha
```

**Verify ingestion:**
```python
# In Python shell
from vector_store.pinecone_store import PineconeVectorStore

store = PineconeVectorStore()
stats = store.get_stats()
print(stats)  # Should show vectors for each namespace
```

### Step 8: Test End-to-End

#### Test 1: Register User
```bash
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "TestPassword123",
    "full_name": "Test User",
    "phone": "9876543210"
  }'
```

#### Test 2: Login
```bash
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "TestPassword123"
  }'

# Copy the token from response
```

#### Test 3: AI Query
```bash
curl -X POST http://localhost:8000/api/v1/ai/query \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "service_id": 1,
    "query": "What are the general principles of Vedic astrology?",
    "context": {}
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "query_id": 1,
    "answer": "Vedic astrology, also known as Jyotish...",
    "sources": [...],
    "confidence": 0.85,
    "agent_type": "jyotisha"
  }
}
```

### Step 9: Production Deployment

#### PHP API with Nginx

Create `/etc/nginx/sites-available/dishaajyoti-api`:
```nginx
server {
    listen 80;
    server_name api.dishaajyoti.com;
    root /var/www/dishaajyoti/backend/php-api/public;

    index index.php;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

Enable site:
```bash
sudo ln -s /etc/nginx/sites-available/dishaajyoti-api /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

#### Python AI Service with Gunicorn

Create systemd service `/etc/systemd/system/dishaajyoti-ai.service`:
```ini
[Unit]
Description=DishaAjyoti AI Service
After=network.target

[Service]
User=www-data
WorkingDirectory=/var/www/dishaajyoti/backend/ai-service
Environment="PATH=/var/www/dishaajyoti/backend/ai-service/venv/bin"
ExecStart=/var/www/dishaajyoti/backend/ai-service/venv/bin/gunicorn -w 4 -b 127.0.0.1:5000 app:app

[Install]
WantedBy=multi-user.target
```

Start service:
```bash
sudo systemctl daemon-reload
sudo systemctl start dishaajyoti-ai
sudo systemctl enable dishaajyoti-ai
```

## 🎯 Quick Reference

### Start All Services (Development)

```bash
# Terminal 1: MySQL (usually runs as service)
sudo systemctl start mysql

# Terminal 2: PHP API
cd backend/php-api
php -S localhost:8000 -t public

# Terminal 3: Python AI Service
cd backend/ai-service
source venv/bin/activate
python app.py
```

### Stop All Services

```bash
# Ctrl+C in each terminal

# Or if running as services:
sudo systemctl stop nginx
sudo systemctl stop dishaajyoti-ai
sudo systemctl stop mysql
```

### Re-ingest PDFs After Updates

```bash
cd backend/ai-service
source venv/bin/activate

# Re-ingest specific service (deletes old data first)
python pdf_processor/pdf_ingestion.py --service jyotisha --reingest
```

### View Logs

```bash
# AI Service
tail -f backend/ai-service/logs/ai-service.log

# PHP API
tail -f backend/php-api/logs/app.log

# Nginx
tail -f /var/log/nginx/error.log
```

## ⚠️ Common Issues

### Issue: "Connection refused" to AI service

**Solution:**
```bash
# Check if AI service is running
curl http://localhost:5000/health

# Check if port is in use
lsof -i :5000

# Verify API_KEY matches in both .env files
```

### Issue: PDF ingestion fails

**Solution:**
```bash
# Check PDF file
file backend/pdf-books/jyotisha/your-file.pdf

# Try with verbose logging
LOG_LEVEL=DEBUG python pdf_processor/pdf_ingestion.py --service jyotisha

# Check Pinecone quota
# Visit https://app.pinecone.io/
```

### Issue: MySQL connection error

**Solution:**
```bash
# Test connection
mysql -u dishaajyoti -p dishaajyoti

# Check MySQL is running
sudo systemctl status mysql

# Verify credentials in .env
```

## 💰 Cost Estimates

**Monthly costs (estimated):**

- **OpenAI API**: $20-100/month (depends on usage)
  - GPT-4: $0.03 per 1K tokens input, $0.06 per 1K tokens output
  - GPT-3.5: $0.001 per 1K tokens (much cheaper)

- **Pinecone**: Free tier (100K vectors) or $70/month for 1M vectors

- **Server**: $5-20/month (DigitalOcean/AWS)

**Total**: ~$25-200/month depending on usage

## ✅ Checklist

- [ ] MySQL database created
- [ ] PHP dependencies installed
- [ ] Python virtual environment created
- [ ] OpenAI API key configured
- [ ] Pinecone API key configured
- [ ] Pinecone index created
- [ ] PDF books added to folders
- [ ] PDFs ingested into vector database
- [ ] PHP API running on port 8000
- [ ] Python AI service running on port 5000
- [ ] Test API calls successful
- [ ] Flutter app updated with new endpoints

## 🎉 Next Steps

1. Add your actual PDF books to the appropriate folders
2. Test with real queries related to your books
3. Fine-tune agent prompts for better responses
4. Configure production servers
5. Set up SSL certificates
6. Implement rate limiting
7. Add monitoring and analytics

## 📞 Support

If you encounter issues:
1. Check this guide
2. Review logs
3. Contact: support@dishaajyoti.com

---

**You're all set! 🚀**
