# 🚀 Deploy Python AI Service to Render.com (FREE)

## ⏱️ Total Time: 10 Minutes

---

## Step 1: Create Render.com Account (2 minutes)

1. Go to **https://render.com/**
2. Click **"Get Started"**
3. Sign up with **GitHub** (easiest)
4. Authorize Render to access your repositories

---

## Step 2: Push Code to GitHub (1 minute)

```bash
cd /path/to/Dishaajyoti

# Add the new deployment files
git add backend/ai-service/render.yaml
git add backend/ai-service/runtime.txt

# Commit
git commit -m "Add Render.com deployment configuration"

# Push to GitHub
git push origin main
```

---

## Step 3: Create Web Service on Render (3 minutes)

1. **In Render Dashboard**, click **"New +"** → **"Web Service"**

2. **Connect Repository:**
   - Click **"Connect a repository"**
   - Find and select your **Dishaajyoti** repository
   - Click **"Connect"**

3. **Configure Service:**

   **Basic Settings:**
   ```
   Name: dishaajyoti-ai
   Region: Choose closest to you (e.g., Oregon, Frankfurt)
   Branch: main
   Root Directory: backend/ai-service
   ```

   **Build & Deploy:**
   ```
   Environment: Python 3
   Build Command: pip install -r requirements.txt
   Start Command: gunicorn -w 4 -b 0.0.0.0:$PORT app:app
   ```

   **Instance Type:**
   ```
   Select: Free
   ```

4. Click **"Advanced"** and verify:
   ```
   Auto-Deploy: Yes (recommended)
   ```

---

## Step 4: Add Environment Variables (2 minutes)

Still in the configuration page, scroll to **"Environment Variables"**.

Click **"Add Environment Variable"** and add each of these:

### Required Variables:

| Key | Value |
|-----|-------|
| `OPENAI_API_KEY` | `sk-your-openai-api-key-here` |
| `PINECONE_API_KEY` | `your-pinecone-api-key-here` |
| `PINECONE_INDEX_NAME` | `dishaajyoti-knowledge` |
| `PINECONE_ENVIRONMENT` | `us-west1-gcp` (or your region) |
| `API_KEY` | `your-secure-random-key-123` |

### Optional Variables:

| Key | Value | Purpose |
|-----|-------|---------|
| `OPENAI_MODEL` | `gpt-4-turbo-preview` | AI model to use |
| `OPENAI_TEMPERATURE` | `0.7` | Response creativity |
| `CHUNK_SIZE` | `1000` | PDF chunk size |
| `EMBEDDING_MODEL` | `text-embedding-3-small` | Embedding model |
| `LOG_LEVEL` | `INFO` | Logging level |

**Important:**
- The `API_KEY` must match what you set in `backend/php-api/.env`
- Keep these values secret!

---

## Step 5: Deploy! (1 minute)

1. Click **"Create Web Service"**
2. Render will start building your service
3. Wait for **"Live"** status (2-3 minutes)
4. Copy your service URL: `https://dishaajyoti-ai.onrender.com`

---

## Step 6: Update PHP API Configuration (1 minute)

On **your PHP server**, edit `backend/php-api/.env`:

```bash
# Old value:
# AI_SERVICE_URL=http://localhost:5000

# New value (use your Render URL):
AI_SERVICE_URL=https://dishaajyoti-ai.onrender.com

# Make sure API_KEY matches what you set in Render:
AI_SERVICE_API_KEY=your-secure-random-key-123
```

Save and restart your PHP server (if needed).

---

## Step 7: Test the Deployment (2 minutes)

### Test 1: Health Check

```bash
curl https://dishaajyoti-ai.onrender.com/health
```

**Expected Response:**
```json
{
  "status": "healthy",
  "service": "DishaAjyoti AI Service",
  "version": "1.0.0"
}
```

### Test 2: List Agents

```bash
curl https://dishaajyoti-ai.onrender.com/api/agents \
  -H "X-API-Key: your-secure-random-key-123"
```

**Expected Response:**
```json
{
  "agents": [
    {
      "type": "jyotisha",
      "description": "Vedic Astrology expert..."
    },
    ...
  ]
}
```

### Test 3: End-to-End (via PHP API)

```bash
# First, get a token by logging in to your PHP API
curl -X POST http://your-php-server.com/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com", "password": "password123"}'

# Use the token to test AI query
curl -X POST http://your-php-server.com/api/v1/ai/query \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "service_id": 1,
    "query": "What are the basic principles of Vedic astrology?",
    "context": {}
  }'
```

If this works, **YOU'RE DONE!** ✅

---

## 🎉 Your Architecture Now:

```
┌─────────────────────────┐
│    Flutter Mobile App    │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│  Your PHP Server        │
│  (Your existing hosting)│
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│  Render.com (FREE)      │
│  Python AI Service      │
│  🤖 GPT-4 + Pinecone    │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│  OpenAI + Pinecone APIs │
│  (Cloud Services)       │
└─────────────────────────┘
```

---

## 📊 What You Get (FREE):

✅ **750 hours/month** (always-on for 1 app)
✅ **512 MB RAM**
✅ **Free SSL certificate** (HTTPS)
✅ **Automatic deploys** from GitHub
✅ **Zero maintenance**
✅ **99.9% uptime**
✅ **No credit card required**

---

## ⚠️ Important Notes

### Cold Starts
Free tier services "sleep" after 15 minutes of inactivity.
First request after sleep takes ~30 seconds to wake up.

**Solution for production:**
1. Upgrade to paid tier ($7/month - no cold starts)
2. Or use a service like **UptimeRobot** to ping every 14 minutes

### PDF Ingestion
You need to ingest PDFs **after** deploying to Render.

**Option A: Run locally**
```bash
cd backend/ai-service
source venv/bin/activate

# Set environment variables to point to Render
export PINECONE_API_KEY=your-key
export PINECONE_INDEX_NAME=dishaajyoti-knowledge

# Ingest PDFs
python pdf_processor/pdf_ingestion.py --all
```

**Option B: Use Render Shell**
1. In Render dashboard, go to your service
2. Click **"Shell"** tab
3. Run ingestion commands there

---

## 🔧 Troubleshooting

### Issue: "Build failed"

**Check:**
1. `requirements.txt` exists in `backend/ai-service/`
2. Root Directory is set to `backend/ai-service`
3. Check build logs for specific error

### Issue: "Service won't start"

**Check:**
1. Start Command is: `gunicorn -w 4 -b 0.0.0.0:$PORT app:app`
2. All environment variables are set
3. Check logs in Render dashboard

### Issue: "Connection refused from PHP API"

**Check:**
1. `AI_SERVICE_URL` in PHP .env is correct
2. `API_KEY` matches in both PHP and Render
3. Render service is "Live" (not sleeping)

### Issue: "OpenAI API error"

**Check:**
1. `OPENAI_API_KEY` is correct in Render
2. You have credits in OpenAI account
3. API key is not rate-limited

### Issue: "Pinecone error"

**Check:**
1. `PINECONE_API_KEY` is correct
2. `PINECONE_INDEX_NAME` exists in Pinecone
3. Index has correct dimensions (1536)

---

## 🚀 Next Steps After Deployment

1. **Ingest Your PDF Books**
   ```bash
   cd backend/ai-service
   python pdf_processor/pdf_ingestion.py --all
   ```

2. **Test with Real Queries**
   - Use Postman or curl
   - Test each AI agent
   - Verify responses are accurate

3. **Monitor Performance**
   - Check Render dashboard for metrics
   - Monitor OpenAI usage
   - Track Pinecone vector count

4. **Consider Upgrading** (if needed)
   - Paid tier: $7/month
   - No cold starts
   - Better performance
   - More resources

---

## 💰 Cost Comparison

| Component | Free Tier | Paid Option |
|-----------|-----------|-------------|
| **Render.com** | FREE | $7/mo |
| **OpenAI API** | Pay-per-use | ~$50-100/mo |
| **Pinecone** | 100K vectors FREE | $70/mo for 1M |
| **Your PHP Hosting** | Existing | Existing |

**Total Monthly Cost:**
- **Development**: FREE (use free tiers)
- **Production**: $7-177/month (depending on usage)

---

## 📞 Support

**Render.com Issues:**
- Docs: https://render.com/docs
- Community: https://community.render.com/

**AI Service Issues:**
- Check logs in Render dashboard
- Test locally first
- Verify environment variables

**Need Help?**
Contact: support@dishaajyoti.com

---

## ✅ Deployment Checklist

Before going live:

- [ ] Render service deployed and "Live"
- [ ] All environment variables set
- [ ] Health endpoint returns 200
- [ ] PHP API can connect to Render
- [ ] PDFs ingested into Pinecone
- [ ] Test query returns valid response
- [ ] OpenAI API key has credits
- [ ] Pinecone index exists
- [ ] Logs show no errors
- [ ] Flutter app updated with PHP API URL

---

## 🎉 Congratulations!

Your AI service is now running on **FREE cloud hosting**!

Your users can now:
- ✅ Ask questions about Jyotisha, Vastu, Numerology
- ✅ Get answers based on YOUR PDF books
- ✅ Receive accurate, sourced responses
- ✅ Have conversational AI chats
- ✅ Generate comprehensive reports

**All without maintaining a Python server!** 🚀

---

**Questions? Issues? Let me know!** 💬
