# Local Development & Docker Orchestration

---

## 1. Complete Docker Compose Stack

The local stack provisions the entire microservice ecosystem with a single command:

```yaml
# docker/docker-compose.yml
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    container_name: journalit_postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: journal_it
      POSTGRES_USER: journal_admin
      POSTGRES_PASSWORD: journal_secret_password
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U journal_admin -d journal_it"]
      interval: 5s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    container_name: journalit_redis
    restart: unless-stopped
    ports:
      - "6379:6379"
    volumes:
      - redisdata:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5

  minio:
    image: minio/minio:RELEASE.2024-05-10T01-41-38Z
    container_name: journalit_minio
    restart: unless-stopped
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadminpassword
    ports:
      - "9000:9000"
      - "9001:9001"
    volumes:
      - miniodata:/data

  api:
    build:
      context: ../apps/api
      dockerfile: Dockerfile
    container_name: journalit_api
    restart: unless-stopped
    env_file:
      - ../.env
    ports:
      - "8000:8000"
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
      minio:
        condition: service_started
    volumes:
      - ../apps/api:/app

  worker:
    build:
      context: ../apps/api
      dockerfile: Dockerfile
    container_name: journalit_worker
    restart: unless-stopped
    command: celery -A src.workers.celery_app worker --loglevel=info -c 4
    env_file:
      - ../.env
    depends_on:
      redis:
        condition: service_healthy
      postgres:
        condition: service_healthy
    volumes:
      - ../apps/api:/app

  web:
    build:
      context: ../apps/web
      dockerfile: Dockerfile
    container_name: journalit_web
    restart: unless-stopped
    env_file:
      - ../.env
    ports:
      - "3000:3000"
    depends_on:
      - api
    volumes:
      - ../apps/web:/app
      - /app/node_modules

volumes:
  pgdata:
  redisdata:
  miniodata:
```

---

## 2. Environment Variables Specification (`.env.example`)

```bash
# ==============================================
# JOURNAL IT — ENVIRONMENT CONFIGURATION
# ==============================================

# Application Environment
NODE_ENV=development
APP_ENV=local
NEXT_PUBLIC_APP_URL=http://localhost:3000
API_BASE_URL=http://localhost:8000

# Security & Secrets
JWT_SECRET_KEY=dev_jwt_secret_change_in_production_32chars
SESSION_SECRET=dev_session_cookie_secret_minimum_32chars
VAULT_MASTER_KEY_B64=c3VwZXJfc2VjcmV0XzI1Nl9iaXRfbWFzdGVyX2tleV9mb3JfZ2NtIQ==

# Google Gemini API
GEMINI_API_KEY=AIzaSyDummyKeyForDevelopmentTesting
GEMINI_MODEL_DEFAULT=gemini-2.0-flash
GEMINI_MODEL_FALLBACK=gemini-1.5-pro

# Database (PostgreSQL 16)
DATABASE_URL=postgresql://journal_admin:journal_secret_password@localhost:5432/journal_it

# Cache & Queues (Redis 7)
REDIS_URL=redis://localhost:6379/0

# Object Storage (MinIO / S3)
S3_ENDPOINT_URL=http://localhost:9000
S3_ACCESS_KEY=minioadmin
S3_SECRET_KEY=minioadminpassword
S3_BUCKET_NAME=journalit-media
S3_REGION=us-east-1

# Google Docs Integration (OAuth2)
GOOGLE_CLIENT_ID=your-google-oauth-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=GOCSPX-your-google-client-secret
GOOGLE_REDIRECT_URI=http://localhost:8000/api/v1/auth/google/callback
```

---

## 3. Step-by-Step Developer Setup Guide

### 1. Bootstrapping Containers
```bash
# Start all supporting services
docker compose -f docker/docker-compose.yml up -d postgres redis minio

# Run database migrations
cd apps/api
alembic upgrade head

# Seed initial test data (Admin user, demo newsroom tenant)
python -m src.scripts.seed_db
```

### 2. Running Web & API Locally (Without Docker)
```bash
# Terminal 1: FastAPI Backend
cd apps/api
source venv/bin/activate
uvicorn src.main:app --host 0.0.0.0 --port 8000 --reload

# Terminal 2: Celery Worker
cd apps/api
celery -A src.workers.celery_app worker --loglevel=info

# Terminal 3: Next.js Frontend
cd apps/web
pnpm install
pnpm dev
```

### 3. Packaging & Running Mobile Flutter App
```bash
cd apps/mobile_flutter
flutter pub get
# Run in Android Emulator or connected physical device
flutter run
```
