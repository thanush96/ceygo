# Quick Start Guide

## Prerequisites Setup

1. **Install Node.js 18+** (if not already installed)
2. **Install Docker Desktop** (for PostgreSQL and Redis)

## Initial Setup

```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Copy environment file
cp .env.example .env

# Edit .env with your configuration (at minimum, set database passwords)
```

## Start Development Environment

```bash
# Start PostgreSQL and Redis using Docker
docker-compose up -d postgres redis

# Wait a few seconds for databases to be ready, then start the backend
npm run start:dev
```

## Access Points

- **API**: http://localhost:3000/api/v1
- **API Documentation**: http://localhost:3000/api/docs
- **Health Check**: http://localhost:3000/api/v1

## First Steps

1. **Create an Admin User** (manually in database or via migration)
2. **Test OTP Login**:
   - POST `/api/v1/auth/send-otp` with `{ "phoneNumber": "+94771234567" }`
   - Check console for OTP code
   - POST `/api/v1/auth/verify-otp` with phone number and OTP
3. **Register as Driver** (after login)
4. **Register a Vehicle** (as driver)
5. **Approve Vehicle** (as admin)

## Production Deployment

1. Set up cloud PostgreSQL (AWS RDS, Google Cloud SQL, etc.)
2. Set up cloud Redis (AWS ElastiCache, Google Memorystore, etc.)
3. Configure AWS S3 bucket
4. Set all environment variables securely
5. Build Docker image: `docker build -t ceygo-backend .`
6. Deploy to your cloud platform (AWS ECS, Google Cloud Run, etc.)

## Important Notes

- OTP is currently logged to console (for development). Integrate SMS gateway for production.
- Payment gateways need API keys configured in `.env`
- S3 uploads require AWS credentials
- JWT secrets should be strong random strings in production
