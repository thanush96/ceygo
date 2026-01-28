# CeyGo Car Rental Platform - Backend API

Production-grade backend system for the CeyGo Car Rental Platform built with NestJS, PostgreSQL, and Redis.

## Features

- 🔐 **Authentication**: OTP-based login with JWT tokens
- 👥 **Multi-role System**: User, Driver/Owner, and Admin roles
- 🚗 **Vehicle Management**: Registration, approval, and search
- 📅 **Booking System**: Date-based availability and pricing
- 💳 **Payment Integration**: Multiple payment gateways (PayHere, Mintpay/Koko, Cards, Wallet)
- 💰 **Commission System**: Automated commission calculation
- 📊 **Admin Dashboard**: Statistics and management tools
- 📤 **File Upload**: S3 integration for images
- ⚡ **Redis Caching**: Performance optimization
- 📚 **API Documentation**: Swagger/OpenAPI

## Tech Stack

- **Framework**: NestJS
- **Database**: PostgreSQL with TypeORM
- **Cache**: Redis
- **Storage**: AWS S3
- **Authentication**: JWT + OTP
- **Documentation**: Swagger

## Prerequisites

- Node.js 18+
- PostgreSQL 15+
- Redis 7+
- AWS Account (for S3)

## Installation

1. Clone the repository and navigate to backend:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Set up environment variables:
```bash
cp .env.example .env
# Edit .env with your configuration
```

4. Start PostgreSQL and Redis (using Docker):
```bash
docker-compose up -d postgres redis
```

5. Run migrations:
```bash
npm run migration:run
```

6. Start the development server:
```bash
npm run start:dev
```

The API will be available at `http://localhost:3000/api/v1`
API Documentation: `http://localhost:3000/api/docs`

## Docker Deployment

```bash
docker-compose up -d
```

## API Endpoints

### Authentication
- `POST /api/v1/auth/send-otp` - Send OTP
- `POST /api/v1/auth/verify-otp` - Verify OTP and login
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/refresh` - Refresh token

### Users
- `GET /api/v1/users/profile` - Get profile
- `PUT /api/v1/users/profile` - Update profile
- `GET /api/v1/users/wallet` - Get wallet

### Drivers
- `POST /api/v1/drivers/register` - Register as driver
- `GET /api/v1/drivers/profile` - Get driver profile
- `PUT /api/v1/drivers/profile` - Update driver profile

### Vehicles
- `GET /api/v1/vehicles` - Search vehicles
- `GET /api/v1/vehicles/:id` - Get vehicle details
- `POST /api/v1/vehicles` - Register vehicle (Driver)
- `GET /api/v1/vehicles/driver/my-vehicles` - Get my vehicles

### Bookings
- `POST /api/v1/bookings` - Create booking
- `GET /api/v1/bookings` - Get bookings
- `GET /api/v1/bookings/:id` - Get booking details
- `PUT /api/v1/bookings/:id/cancel` - Cancel booking

### Payments
- `POST /api/v1/payments/process` - Process payment
- `PUT /api/v1/payments/:id/refund` - Refund payment (Admin)

### Admin
- `GET /api/v1/admin/dashboard` - Dashboard stats
- `PUT /api/v1/admin/vehicles/:id/approve` - Approve vehicle
- `PUT /api/v1/admin/drivers/:id/verify` - Verify driver

### Upload
- `POST /api/v1/upload/single` - Upload single file
- `POST /api/v1/upload/multiple` - Upload multiple files

## Environment Variables

See `.env.example` for all required environment variables.

## Database Schema

The application uses TypeORM entities. Key entities:
- Users (with Wallets)
- Drivers
- Vehicles (with Images)
- Bookings
- Payments
- OTPs

## Payment Gateways

Currently supports:
- **Wallet**: Internal wallet system
- **PayHere**: Integration ready (needs API keys)
- **Mintpay/Koko**: Integration ready (needs API keys)
- **Card**: Integration ready (needs gateway setup)

## Commission Model

Default commission: 15% (configurable via `COMMISSION_PERCENTAGE`)

## Security

- JWT authentication
- Role-based access control
- Input validation
- Rate limiting
- CORS configuration

## Production Deployment

1. Set up PostgreSQL and Redis on cloud
2. Configure AWS S3 bucket
3. Set secure environment variables
4. Build and deploy using Docker or cloud platform
5. Set up load balancer and auto-scaling

## License

Proprietary - All rights reserved
