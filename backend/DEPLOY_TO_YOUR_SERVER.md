# 🚀 Deploy to Your Server (rhtechnology.in)

## Your Setup
- **Your Server**: https://rhtechnology.in/Dishajyoti/
- **PHP Backend**: Deploy here
- **MySQL Database**: Create on your server
- **Python AI Service**: Deploy to Render.com (FREE)

---

## Step 1: Create MySQL Database (5 minutes)

### 1.1 Access Your Database

Login to **cPanel** or **phpMyAdmin** on your hosting:
```
https://rhtechnology.in/cpanel
or
https://rhtechnology.in/phpmyadmin
```

### 1.2 Create New Database

**Option A: Via cPanel**
1. Go to **MySQL Databases**
2. Create Database: `dishaajyoti`
3. Create User: `dishaajyoti_user`
4. Set Password: (use a strong password)
5. Add User to Database (ALL PRIVILEGES)

**Option B: Via phpMyAdmin**
1. Click **"New"** in left sidebar
2. Database name: `dishaajyoti`
3. Collation: `utf8mb4_unicode_ci`
4. Click **"Create"**

### 1.3 Import Schema

1. Click on **dishaajyoti** database
2. Click **"Import"** tab
3. Click **"Choose File"**
4. Select: `backend/database/schema.sql`
5. Click **"Go"**

✅ **Database created with 13 tables and sample data!**

---

## Step 2: Upload PHP Backend Files (10 minutes)

### 2.1 Files to Upload

Upload these folders to your server:

```
rhtechnology.in/Dishajyoti/
├── public/              ← Upload backend/php-api/public/
├── src/                 ← Upload backend/php-api/src/
├── config/              ← Upload backend/php-api/config/
├── routes/              ← Upload backend/php-api/routes/
├── vendor/              ← (Will be created by composer)
├── composer.json        ← Upload backend/php-api/composer.json
└── .env                 ← Create this (see below)
```

### 2.2 Upload via FTP/File Manager

**Option A: FTP (Recommended)**
```bash
# Use FileZilla or any FTP client
Host: ftp.rhtechnology.in
Username: your-ftp-username
Password: your-ftp-password
Port: 21

# Upload to: /public_html/Dishajyoti/
```

**Option B: cPanel File Manager**
1. Login to cPanel
2. Go to **File Manager**
3. Navigate to `/public_html/Dishajyoti/`
4. Upload files

### 2.3 Create .env File

Create `.env` in `/Dishajyoti/` with this content:

```env
# Application Configuration
APP_NAME="DishaAjyoti API"
APP_ENV=production
APP_DEBUG=false
APP_URL=https://rhtechnology.in/Dishajyoti

# Database Configuration
DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=dishaajyoti
DB_USERNAME=dishaajyoti_user
DB_PASSWORD=your-database-password-here

# JWT Configuration (Generate a random 64-character string)
JWT_SECRET=CHANGE-THIS-TO-RANDOM-64-CHAR-STRING
JWT_ALGORITHM=HS256
JWT_EXPIRY=3600
JWT_REFRESH_EXPIRY=2592000

# AI Service Configuration (Will get this from Render.com)
AI_SERVICE_URL=https://your-service.onrender.com
AI_SERVICE_API_KEY=your-secure-random-key-123

# OpenAI Configuration
OPENAI_API_KEY=sk-your-openai-key-here
OPENAI_MODEL=gpt-4-turbo-preview

# Pinecone Configuration
PINECONE_API_KEY=your-pinecone-key
PINECONE_ENVIRONMENT=us-west-1
PINECONE_INDEX_NAME=dishaajyoti-knowledge

# CORS Configuration
CORS_ALLOWED_ORIGINS=https://rhtechnology.in,http://localhost
CORS_ALLOWED_METHODS=GET,POST,PUT,DELETE,OPTIONS
CORS_ALLOWED_HEADERS=Content-Type,Authorization,X-Requested-With

# Logging
LOG_LEVEL=info
LOG_FILE=../logs/app.log
```

**Generate JWT Secret:**
```bash
# On your computer, run:
openssl rand -hex 32

# Or use online generator:
# https://www.uuidgenerator.net/
```

### 2.4 Install Composer Dependencies

**Option A: Via SSH (if available)**
```bash
ssh your-username@rhtechnology.in
cd public_html/Dishajyoti
composer install --no-dev --optimize-autoloader
```

**Option B: Via cPanel Terminal**
1. Open **Terminal** in cPanel
2. Run:
```bash
cd public_html/Dishajyoti
composer install --no-dev --optimize-autoloader
```

**Option C: Upload vendor folder**
If you can't run composer on server:
1. Run locally: `cd backend/php-api && composer install`
2. Upload the entire `vendor/` folder via FTP

---

## Step 3: Configure .htaccess for API Routes

Create `.htaccess` in `/Dishajyoti/public/`:

```apache
<IfModule mod_rewrite.c>
    RewriteEngine On

    # Handle Authorization Header
    RewriteCond %{HTTP:Authorization} .
    RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]

    # Redirect to index.php
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule ^ index.php [L]
</IfModule>

# Enable CORS
<IfModule mod_headers.c>
    Header set Access-Control-Allow-Origin "*"
    Header set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
    Header set Access-Control-Allow-Headers "Content-Type, Authorization, X-Requested-With"
</IfModule>

# Security Headers
<IfModule mod_headers.c>
    Header set X-Content-Type-Options "nosniff"
    Header set X-Frame-Options "SAMEORIGIN"
    Header set X-XSS-Protection "1; mode=block"
</IfModule>
```

---

## Step 4: Test PHP API

### 4.1 Test Basic Connection

Visit in browser:
```
https://rhtechnology.in/Dishajyoti/public/index.php
```

You should see API response (might be error, that's ok - it means PHP is working)

### 4.2 Test API Endpoint

```bash
# Test services endpoint
curl https://rhtechnology.in/Dishajyoti/public/api/v1/services

# Expected response:
{
  "success": true,
  "data": {
    "services": [...]
  }
}
```

### 4.3 Test User Registration

```bash
curl -X POST https://rhtechnology.in/Dishajyoti/public/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123456",
    "full_name": "Test User",
    "phone": "9876543210"
  }'

# Expected:
{
  "success": true,
  "data": {
    "user": {...},
    "token": "..."
  }
}
```

✅ **PHP API is working!**

---

## Step 5: Deploy Python AI Service to Render.com (10 minutes)

Since your server doesn't support Python, we'll use Render.com (FREE):

### 5.1 Go to Render.com
1. Visit: https://render.com/
2. Sign up with GitHub
3. Connect your repository

### 5.2 Create Web Service
1. Click **"New +"** → **"Web Service"**
2. Select your GitHub repository
3. Configure:

```
Name: dishaajyoti-ai
Region: Choose closest to India (Singapore or Oregon)
Branch: main
Root Directory: backend/ai-service

Build Command: pip install -r requirements.txt
Start Command: gunicorn -w 4 -b 0.0.0.0:$PORT app:app

Instance Type: Free
```

### 5.3 Add Environment Variables

| Key | Value |
|-----|-------|
| `OPENAI_API_KEY` | `sk-your-key` |
| `PINECONE_API_KEY` | `your-key` |
| `PINECONE_ENVIRONMENT` | `us-west-1` |
| `PINECONE_INDEX_NAME` | `dishaajyoti-knowledge` |
| `API_KEY` | `same-random-key-as-php-env` |

### 5.4 Deploy

Click **"Create Web Service"**

Wait 2-3 minutes for build...

You'll get URL: `https://dishaajyoti-ai-xxx.onrender.com`

### 5.5 Update PHP .env

Edit your server's `.env` file:
```env
AI_SERVICE_URL=https://dishaajyoti-ai-xxx.onrender.com
AI_SERVICE_API_KEY=same-key-as-render
```

---

## Step 6: Create Pinecone Index

1. Go to: https://app.pinecone.io/
2. Sign up (FREE tier available)
3. Click **"Create Index"**
4. Settings:
   - Name: `dishaajyoti-knowledge`
   - Dimensions: `1536`
   - Metric: `cosine`
   - Cloud: `AWS`
   - Region: `us-west-1`
5. Click **"Create"**

---

## Step 7: Final Testing

### Test Complete Flow

```bash
# 1. Register user
curl -X POST https://rhtechnology.in/Dishajyoti/public/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "Password123",
    "full_name": "Test User",
    "phone": "9876543210"
  }'

# Copy the token from response

# 2. Get services
curl https://rhtechnology.in/Dishajyoti/public/api/v1/services \
  -H "Authorization: Bearer YOUR_TOKEN"

# 3. Test AI query
curl -X POST https://rhtechnology.in/Dishajyoti/public/api/v1/ai/query \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "service_id": 1,
    "query": "What is Vedic astrology?",
    "context": {}
  }'
```

If all work ✅ **DEPLOYED SUCCESSFULLY!**

---

## Step 8: Update Flutter App

In `lib/utils/constants.dart`:

```dart
static const String baseUrl = 'https://rhtechnology.in/Dishajyoti/public';
```

---

## 🎯 Your Final Architecture

```
┌──────────────────────────────────────────┐
│     Flutter Mobile App                   │
└────────────┬─────────────────────────────┘
             │
             ▼
┌──────────────────────────────────────────┐
│  Your Server (rhtechnology.in)           │
│  ├── PHP REST API                        │
│  ├── MySQL Database                      │
│  └── File Storage                        │
└────────────┬─────────────────────────────┘
             │
             ▼
┌──────────────────────────────────────────┐
│  Render.com (FREE)                       │
│  ├── Python AI Service                   │
│  ├── OpenAI GPT-4                        │
│  └── Pinecone Vector DB                  │
└──────────────────────────────────────────┘
```

---

## 📂 Directory Structure on Your Server

```
/public_html/Dishajyoti/
├── public/
│   ├── index.php         ← Main entry point
│   └── .htaccess         ← URL rewriting
├── src/
│   ├── Controllers/      ← API controllers
│   ├── Models/           ← Data models
│   ├── Services/         ← Business logic
│   └── Middleware/       ← Auth middleware
├── config/
│   └── database.php      ← DB config
├── routes/
│   └── api.php           ← Route definitions
├── vendor/               ← Composer dependencies
├── logs/                 ← Log files (create this)
├── composer.json
└── .env                  ← Configuration (SECRET!)
```

---

## 🔒 Security Checklist

- [ ] `.env` file is NOT publicly accessible
- [ ] `APP_DEBUG=false` in production
- [ ] Strong JWT_SECRET (64 random chars)
- [ ] Strong database password
- [ ] HTTPS enabled (SSL certificate)
- [ ] File upload limits set
- [ ] Rate limiting enabled (optional)

---

## 🐛 Troubleshooting

### Issue: "Database connection failed"
**Fix:**
1. Check DB credentials in `.env`
2. Verify database exists
3. Check user has privileges
```sql
GRANT ALL PRIVILEGES ON dishaajyoti.* TO 'dishaajyoti_user'@'localhost';
FLUSH PRIVILEGES;
```

### Issue: "Vendor folder not found"
**Fix:**
```bash
composer install --no-dev --optimize-autoloader
```

### Issue: "Class not found"
**Fix:**
```bash
composer dump-autoload -o
```

### Issue: "Permission denied"
**Fix:**
```bash
chmod -R 755 /public_html/Dishajyoti
chmod -R 777 /public_html/Dishajyoti/logs
```

### Issue: ".htaccess not working"
**Fix:**
Check if mod_rewrite is enabled in Apache:
```apache
# In .htaccess, add at top:
<IfModule !mod_rewrite.c>
    # Redirect to error page if mod_rewrite not available
</IfModule>
```

---

## 📊 API Endpoints Summary

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/auth/register` | Register new user |
| POST | `/api/v1/auth/login` | Login user |
| GET | `/api/v1/services` | Get all services |
| POST | `/api/v1/ai/query` | Ask AI question |
| POST | `/api/v1/ai/chat` | Conversational chat |
| POST | `/api/v1/reports/generate` | Generate report |

**Base URL:** `https://rhtechnology.in/Dishajyoti/public/api/v1`

---

## ✅ Success Checklist

- [ ] MySQL database created
- [ ] Schema imported (13 tables)
- [ ] PHP files uploaded
- [ ] .env file configured
- [ ] Composer dependencies installed
- [ ] .htaccess configured
- [ ] PHP API returns valid JSON
- [ ] Python AI deployed to Render
- [ ] Pinecone index created
- [ ] End-to-end test successful
- [ ] Flutter app updated with correct URL

---

## 🎉 You're Done!

Your DishaAjyoti backend is now **LIVE** at:
- **API**: https://rhtechnology.in/Dishajyoti/public/api/v1
- **AI Service**: https://your-service.onrender.com

**Next Steps:**
1. Test all endpoints
2. Add your PDF books
3. Run PDF ingestion
4. Connect Flutter app
5. Start getting AI-powered insights!

---

**Questions? Issues? Let me know!** 🚀
