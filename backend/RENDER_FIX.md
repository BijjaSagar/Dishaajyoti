# ✅ Fixed: Render.com Deployment Issues

## What Was Wrong

The `pinecone-client==3.0.3` version in requirements.txt didn't exist, causing deployment to fail on Render.com.

## What's Been Fixed

✅ Updated `pinecone-client` to version **5.0.1** (latest stable)
✅ Updated all dependencies to compatible versions
✅ Removed unnecessary dependencies to speed up builds
✅ Fixed Pinecone environment variable format
✅ Added compatibility layer for different LangChain-Pinecone versions

## Updated Files

1. **`backend/ai-service/requirements.txt`**
   - Changed: `pinecone-client==3.0.3` → `pinecone-client==5.0.1`
   - Removed: pandas, sentence-transformers, redis, pytest (not essential)
   - Added: `Werkzeug==3.0.1` for Flask compatibility

2. **`backend/ai-service/vector_store/pinecone_store.py`**
   - Added compatibility for both langchain-pinecone and langchain-community
   - Fixed environment variable default

3. **`.env.example` files**
   - Changed: `PINECONE_ENVIRONMENT=us-west1-gcp` → `us-west-1`

## 🚀 Now Deploy to Render.com

### Step 1: Push Changes to GitHub

```bash
git add .
git commit -m "Fix Pinecone version and dependencies for Render deployment"
git push
```

### Step 2: Deploy on Render.com

1. Go to **https://render.com/dashboard**
2. Click **"New +"** → **"Web Service"**
3. Connect your GitHub repository
4. Configure:

   ```
   Name: dishaajyoti-ai
   Region: Choose closest to you
   Branch: main
   Root Directory: backend/ai-service

   Environment: Python 3
   Build Command: pip install -r requirements.txt
   Start Command: gunicorn -w 4 -b 0.0.0.0:$PORT app:app

   Instance Type: Free
   ```

5. **Add Environment Variables:**

   Click "Add Environment Variable" and add:

   | Key | Value |
   |-----|-------|
   | `OPENAI_API_KEY` | `sk-your-actual-key` |
   | `PINECONE_API_KEY` | `your-pinecone-key` |
   | `PINECONE_ENVIRONMENT` | `us-west-1` (or your region) |
   | `PINECONE_INDEX_NAME` | `dishaajyoti-knowledge` |
   | `API_KEY` | `create-secure-random-key-123` |

   **Important:** The `API_KEY` must match what's in your PHP `.env` file!

6. Click **"Create Web Service"**

### Step 3: Wait for Build

Render will now:
- ✅ Install Python 3.9.12
- ✅ Install all dependencies (takes 2-3 minutes)
- ✅ Start your AI service
- ✅ Give you a URL like: `https://dishaajyoti-ai.onrender.com`

### Step 4: Test Deployment

```bash
# Test health endpoint
curl https://dishaajyoti-ai.onrender.com/health

# Expected response:
{
  "status": "healthy",
  "service": "DishaAjyoti AI Service",
  "version": "1.0.0"
}
```

If you see this ✅ **SUCCESS!**

### Step 5: Update PHP API

On your PHP server, edit `backend/php-api/.env`:

```bash
AI_SERVICE_URL=https://dishaajyoti-ai.onrender.com
AI_SERVICE_API_KEY=create-secure-random-key-123
```

## ⚠️ Important Notes

### Pinecone Index Setup

Before your AI can work, you need to create the Pinecone index:

**Option A: Via Pinecone Dashboard**
1. Go to https://app.pinecone.io/
2. Click "Create Index"
3. Settings:
   - Name: `dishaajyoti-knowledge`
   - Dimensions: `1536`
   - Metric: `cosine`
   - Cloud: `AWS`
   - Region: `us-west-1` (or closest to you)
4. Click "Create Index"

**Option B: Via Python (locally)**
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

### PDF Ingestion

After deploying, ingest your PDF books:

```bash
# Run locally (pointing to Pinecone)
cd backend/ai-service
source venv/bin/activate

export PINECONE_API_KEY=your-key
export PINECONE_INDEX_NAME=dishaajyoti-knowledge
export PINECONE_ENVIRONMENT=us-west-1

python pdf_processor/pdf_ingestion.py --all
```

## 🐛 Troubleshooting

### Build Still Fails?

**Check these:**
1. Requirements.txt is in `backend/ai-service/` folder
2. Root Directory is set to `backend/ai-service`
3. Python version is 3.9+ (specified in runtime.txt)

**View build logs:**
- In Render dashboard → Your service → "Logs" tab
- Look for specific error messages

### Service Won't Start?

**Check these:**
1. All environment variables are set (especially OPENAI_API_KEY)
2. Start command is correct: `gunicorn -w 4 -b 0.0.0.0:$PORT app:app`
3. Check logs for specific errors

### "Connection refused" from PHP?

**Check these:**
1. Service is "Live" in Render dashboard (green status)
2. URL in PHP .env is correct (copy from Render dashboard)
3. API_KEY matches in both places
4. Test the health endpoint directly first

### Pinecone Errors?

**Common fixes:**
1. Make sure index exists in Pinecone dashboard
2. Index name matches exactly: `dishaajyoti-knowledge`
3. Dimensions are correct: `1536`
4. API key is valid and not rate-limited

## ✅ Verification Checklist

Before testing with your Flutter app:

- [ ] Render service shows "Live" status
- [ ] Health endpoint returns 200 OK
- [ ] All environment variables set
- [ ] Pinecone index exists
- [ ] PDFs ingested into Pinecone (at least test data)
- [ ] PHP API .env updated with Render URL
- [ ] Test query returns valid response

## 🎉 Success!

If all above checks pass, your AI service is ready!

You can now:
- ✅ Make AI queries from your Flutter app
- ✅ Get answers based on your PDF books
- ✅ Generate comprehensive reports
- ✅ Use conversational chat

## 💰 Costs

**Render.com Free Tier:**
- ✅ 750 hours/month (enough for 24/7 for 1 service)
- ✅ 512 MB RAM
- ✅ Free SSL
- ⚠️ Service "sleeps" after 15 min inactivity (30s to wake up)

**To Remove Sleep (Optional):**
- Upgrade to paid tier: $7/month
- Or use UptimeRobot.com (free) to ping every 14 minutes

## 📞 Still Having Issues?

1. **Check logs** in Render dashboard
2. **Test locally** first with same dependencies
3. **Verify API keys** are correct
4. **Check Pinecone quota** (free tier: 100K vectors)

## 📚 Related Docs

- **Render Deployment:** `backend/DEPLOY_TO_RENDER.md`
- **All Options:** `backend/DEPLOYMENT_OPTIONS.md`
- **Setup Guide:** `backend/SETUP_GUIDE.md`

---

**The build should work now!** 🚀

Try deploying again and let me know if you encounter any other errors.
