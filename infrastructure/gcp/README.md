# Google Cloud Run Deployment Guide for FitSync AI

This guide walks you through deploying the **FitSync AI FastAPI backend** to **Google Cloud Run**, providing a scalable, serverless container that automatically scales to zero when idle and handles high traffic seamlessly.

---

## 🌟 Why Google Cloud Run for FitSync AI?
- **Serverless Containers**: Zero server maintenance, automatic HTTPS, and auto-scaling.
- **Native Gemini Integration**: Fits seamlessly with Google's Cloud & AI ecosystem.
- **No Local Docker Required**: Google Cloud Build compiles the container directly from source code in the cloud.
- **Generous Free Tier**: 2 million requests/month and 360,000 GB-seconds of compute free every month.

---

## Method 1: Automated Deployment via `gcloud` CLI (Recommended)

### Step 1: Install Google Cloud SDK
If `gcloud` is not yet installed on your Mac:
```bash
brew install --cask google-cloud-sdk
```
*(Or download directly from [cloud.google.com/sdk](https://cloud.google.com/sdk/docs/install)).*

### Step 2: Authenticate & Set Project
```bash
# Log in to your Google Cloud account
gcloud auth login

# Set your active GCP project (or create one in Google Cloud Console)
gcloud config set project YOUR_PROJECT_ID
```

### Step 3: Run the Automated Deploy Script
From the project root:
```bash
# Export optional environment variables (recommended)
export GEMINI_API_KEY="your-gemini-api-key"
export DATABASE_URL="postgresql+asyncpg://user:pass@host:5432/dbname"

# Run the deployment script
./infrastructure/gcp/deploy.sh
```

Alternatively, run the single command directly:
```bash
cd backend
gcloud run deploy fitsync-backend \
  --source . \
  --region us-central1 \
  --platform managed \
  --allow-unauthenticated \
  --set-env-vars JWT_SECRET=supersecretkey,GEMINI_API_KEY=your-gemini-key
```

Once deployment completes, Cloud Run will output your live URL:
```text
Service URL: https://fitsync-backend-xyz.a.run.app
```

---

## Method 2: Deployment via Google Cloud Console (No CLI Needed)

If you prefer using the browser without installing anything locally:

1. Push your repository to **GitHub**.
2. Open the [Google Cloud Run Console](https://console.cloud.google.com/run).
3. Click **"Deploy container"** -> **"Service"**.
4. Select **"Continuously deploy from a repository"** -> click **"Set up Cloud Build"**.
5. Connect your GitHub account and select `fitsync-ai`.
6. Select **Branch**: `main`, and **Build Type**: `Dockerfile` (`backend/Dockerfile`).
7. Under **Authentication**, select **"Allow unauthenticated invocations"** (public API).
8. Under **Container, Variables & Secrets**:
   - Set Port: `8080`
   - Add Environment Variables:
     - `JWT_SECRET`: your secret string
     - `GEMINI_API_KEY`: your Google Gemini API key
     - `DATABASE_URL`: your PostgreSQL connection string
9. Click **"Create"**. Google Cloud will build and deploy the container in ~2 minutes.

---

## 🗄️ Setting Up PostgreSQL Database

For production PostgreSQL, you have two great options:

### Option A: Serverless PostgreSQL (Neon or Supabase - Recommended for Hackathons)
1. Create a free PostgreSQL database at [Neon.tech](https://neon.tech) or [Supabase.com](https://supabase.com).
2. Copy the connection string (e.g., `postgresql://user:pass@ep-xyz.us-east-2.aws.neon.tech/neondb?sslmode=require`).
3. Add it to Cloud Run environment variables as `DATABASE_URL`. FitSync AI automatically handles async driver conversion.

### Option B: Google Cloud SQL (PostgreSQL)
1. In GCP Console, navigate to **Cloud SQL** -> **Create Instance** -> **PostgreSQL**.
2. Connect the Cloud SQL instance to your Cloud Run service via the **Cloud SQL connection** setting.

---

## 📱 Connecting the Flutter Frontend to the Cloud Backend

Once deployed, update your Flutter app's API base URL:

In `frontend/flutter_app/lib/config/constants.dart` (or your environment config):
```dart
const String kApiBaseUrl = 'https://fitsync-backend-xyz.a.run.app';
```

Verify your deployment anytime:
- **API Documentation**: `https://YOUR_SERVICE_URL/docs`
- **Health Check**: `https://YOUR_SERVICE_URL/health`
- **AI Chat Endpoint**: `POST https://YOUR_SERVICE_URL/api/ai/chat`
