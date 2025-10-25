# ⚡ Quick Start - Deploy to rhtechnology.in

## 🎯 3 Simple Steps

### Step 1: Create Database (2 minutes)

**Login to phpMyAdmin:**
```
https://rhtechnology.in/phpmyadmin
```

**Create database:**
- Database name: `dishaajyoti`
- Collation: `utf8mb4_unicode_ci`

**Import schema:**
- Click on database → Import
- Upload file: `backend/database/schema.sql`
- Click "Go"

✅ **13 tables created with sample data!**

---

### Step 2: Upload Files (5 minutes)

**Files to upload to `/Dishajyoti/`:**

```
Download from GitHub:
backend/php-api/
├── public/
├── src/
├── config/
├── routes/
└── composer.json
```

**Upload via FTP or cPanel File Manager to:**
```
/public_html/Dishajyoti/
```

**Create `.env` file:**
```env
# Database
DB_HOST=localhost
DB_DATABASE=dishaajyoti
DB_USERNAME=your_db_user
DB_PASSWORD=your_db_password

# JWT (generate random 64 chars)
JWT_SECRET=your-random-64-character-secret-key

# AI Service (from Render.com - see step 3)
AI_SERVICE_URL=https://your-ai.onrender.com
AI_SERVICE_API_KEY=your-secure-key

# API Keys
OPENAI_API_KEY=sk-your-key
PINECONE_API_KEY=your-key
PINECONE_INDEX_NAME=dishaajyoti-knowledge
```

**Install composer:**
```bash
cd /public_html/Dishajyoti
composer install --no-dev
```

Or upload `vendor/` folder if composer not available.

---

### Step 3: Deploy AI Service (5 minutes)

**Go to Render.com:**
1. https://render.com/ → Sign up with GitHub
2. New Web Service → Select your repo
3. Configure:
   - Root: `backend/ai-service`
   - Build: `pip install -r requirements.txt`
   - Start: `gunicorn -w 4 -b 0.0.0.0:$PORT app:app`

4. Add environment variables:
   - `OPENAI_API_KEY=sk-your-key`
   - `PINECONE_API_KEY=your-key`
   - `API_KEY=same-as-php-env`

5. Deploy! Get URL and update PHP `.env`

---

## 🧪 Test It Works

```bash
# Test API
curl https://rhtechnology.in/Dishajyoti/public/api/v1/services

# Should return:
{
  "success": true,
  "data": {
    "services": [...]
  }
}
```

✅ **Done! Your backend is live!**

---

## 📱 Update Flutter App

In `lib/utils/constants.dart`:
```dart
static const String baseUrl = 'https://rhtechnology.in/Dishajyoti/public';
```

---

## 📚 Full Documentation

- **Detailed Guide**: `backend/DEPLOY_TO_YOUR_SERVER.md`
- **Database Schema**: `backend/database/schema.sql`
- **Deployment Options**: `backend/DEPLOYMENT_OPTIONS.md`

---

## 💡 Database Schema Summary

**13 Tables Created:**
1. `users` - User accounts
2. `user_profiles` - User details
3. `categories` - Service categories (8 pre-loaded)
4. `services` - Service catalog (5 samples)
5. `service_features` - Service feature list
6. `payments` - Payment records
7. `reports` - Generated reports
8. `report_details` - Report sections
9. `user_queries` - AI query history
10. `ai_responses` - AI response cache
11. `pdf_documents` - PDF metadata
12. Plus 2 more utility tables

**Sample Data Included:**
- 8 categories (Jyotish, Vastu, Numerology, etc.)
- 5 services ready to use
- Service features

---

## 🔑 Get API Keys

**OpenAI:** https://platform.openai.com/api-keys (~$50/month)
**Pinecone:** https://app.pinecone.io/ (FREE tier available)

---

**Need help? Check the full guide or contact support!** 🚀
