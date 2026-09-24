#!/bin/bash
set -e

# FitSync AI - Google Cloud Run One-Click Deployment Script
echo "=========================================================="
echo "      FitSync AI - Google Cloud Run Deployment Script     "
echo "=========================================================="

# Check for gcloud CLI
if ! command -v gcloud &> /dev/null; then
    echo "❌ Google Cloud SDK ('gcloud') is not found."
    echo ""
    echo "To install gcloud on macOS via Homebrew, run:"
    echo "   brew install --cask google-cloud-sdk"
    echo ""
    echo "Or download directly from:"
    echo "   https://cloud.google.com/sdk/docs/install"
    echo ""
    exit 1
fi

# Authenticate check
echo "🔍 Checking Google Cloud authentication..."
CURRENT_ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null || true)
if [ -z "$CURRENT_ACCOUNT" ]; then
    echo "🔑 Please authenticate with Google Cloud:"
    gcloud auth login
fi

# Project selection
PROJECT_ID=$(gcloud config get-value project 2>/dev/null || true)
if [ -z "$PROJECT_ID" ] || [ "$PROJECT_ID" = "(unset)" ]; then
    echo "📝 Enter your Google Cloud Project ID:"
    read -r PROJECT_ID
    gcloud config set project "$PROJECT_ID"
fi

REGION="us-central1"
SERVICE_NAME="fitsync-backend"

echo "🚀 Configuration:"
echo "   - Project ID: $PROJECT_ID"
echo "   - Service:    $SERVICE_NAME"
echo "   - Region:     $REGION"
echo ""

# Enable required Google Cloud APIs
echo "⚡ Enabling required GCP Services (run, cloudbuild, artifactregistry)..."
gcloud services enable run.googleapis.com cloudbuild.googleapis.com artifactregistry.googleapis.com --quiet

# Optional environment variables
ENV_VARS="JWT_SECRET=supersecretkey"
if [ -n "$GEMINI_API_KEY" ]; then
    ENV_VARS="$ENV_VARS,GEMINI_API_KEY=$GEMINI_API_KEY"
fi
if [ -n "$DATABASE_URL" ]; then
    ENV_VARS="$ENV_VARS,DATABASE_URL=$DATABASE_URL"
fi

# Deploy directly from source using Cloud Build (No local Docker required!)
echo "📦 Building container in Google Cloud and deploying to Cloud Run..."
cd "$(dirname "$0")/../../backend"

gcloud run deploy "$SERVICE_NAME" \
    --source . \
    --region "$REGION" \
    --platform managed \
    --allow-unauthenticated \
    --set-env-vars "$ENV_VARS" \
    --quiet

echo ""
echo "🎉 Deployment Complete!"
SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" --platform managed --region "$REGION" --format 'value(status.url)')
echo "🌐 Live Backend URL: $SERVICE_URL"
echo "📖 Swagger API Docs: $SERVICE_URL/docs"
echo "❤️ Health Check:     $SERVICE_URL/health"
echo "=========================================================="

