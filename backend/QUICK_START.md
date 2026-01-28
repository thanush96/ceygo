# CeyGo Backend - Quick Start Guide

## Prerequisites
- Node.js 18+ 
- PostgreSQL 14+
- Redis 6+
- npm or yarn

## Installation

```bash
# Install dependencies
cd backend
npm install

# Copy environment file
cp .env.example .env

# Edit .env with your configuration
```

## Environment Setup

Edit `.env` file with your settings:

```env
# Database
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=your_password
DB_DATABASE=ceygo_db

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379

# JWT
JWT_SECRET=your_secret_key_here
JWT_EXPIRES_IN=7d

# App
PORT=3000
NODE_ENV=development
```

## Database Setup

```bash
# Create database
createdb ceygo_db

# Run migrations (when available)
npm run migration:run

# Or use TypeORM synchronize in development
# (Set NODE_ENV=development in .env)
```

## Running the Application

```bash
# Development
npm run start:dev

# Production
npm run build
npm run start:prod
```

## API Documentation

Once running, access Swagger documentation at:
```
http://localhost:3000/api/docs
```

## Key Endpoints

### Authentication
- `POST /api/v1/auth/register` - Register user
- `POST /api/v1/auth/login` - Login

### Payments
- `POST /api/v1/payments/process` - Process payment
- `POST /api/v1/payments/bnpl/initiate` - Initiate BNPL
- `POST /api/v1/payments/emi/initiate` - Initiate EMI

### Revenue (Admin)
- `GET /api/v1/revenue/overview` - Revenue overview
- `GET /api/v1/revenue/commission` - Commission reports

### Admin
- `GET /api/v1/admin/dashboard` - Dashboard stats
- `PUT /api/v1/admin/vehicles/:id/approve` - Approve vehicle

## Testing

```bash
# Unit tests
npm run test

# E2E tests
npm run test:e2e

# Coverage
npm run test:cov
```

## Docker Deployment

```bash
# Build and run
docker-compose up -d

# View logs
docker-compose logs -f

# Stop
docker-compose down
```

## Project Structure

```
backend/
├── src/
│   ├── modules/          # Feature modules
│   │   ├── auth/         # Authentication
│   │   ├── users/        # User management
│   │   ├── payments/     # Payment processing
│   │   ├── revenue/      # Revenue system
│   │   └── admin/        # Admin panel
│   ├── common/           # Shared utilities
│   └── config/           # Configuration
├── ARCHITECTURE.md       # System architecture
├── DATABASE_SCHEMA.md    # Database schema
└── IMPLEMENTATION_GUIDE.md # Implementation details
```

## Next Steps

1. Configure payment gateway credentials
2. Set up production database
3. Configure Redis cluster
4. Review security settings
5. Set up monitoring

For detailed information, see:
- `ARCHITECTURE.md` - System design
- `IMPLEMENTATION_GUIDE.md` - Implementation details
- `PRODUCTION_READY_SUMMARY.md` - Production checklist
