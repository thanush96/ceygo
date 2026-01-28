# CeyGo - Production Architecture Documentation

## 1. System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │ Flutter  │  │  Web     │  │  Admin   │  │  Mobile  │       │
│  │   App    │  │  Portal  │  │  Panel   │  │   App    │       │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘       │
└───────┼─────────────┼─────────────┼─────────────┼──────────────┘
        │             │             │             │
        └─────────────┴─────────────┴─────────────┘
                           │
        ┌──────────────────┴──────────────────┐
        │         API GATEWAY LAYER           │
        │  ┌──────────────────────────────┐   │
        │  │   NestJS REST API Server     │   │
        │  │  - Rate Limiting             │   │
        │  │  - Authentication            │   │
        │  │  - Request Validation        │   │
        │  │  - CORS & Security           │   │
        │  └──────────────────────────────┘   │
        └──────────────────┬──────────────────┘
                           │
        ┌──────────────────┴──────────────────┐
        │       APPLICATION SERVICE LAYER      │
        │  ┌──────────┐  ┌──────────┐        │
        │  │  Auth    │  │ Payments │        │
        │  │  Users   │  │ Revenue  │        │
        │  │ Drivers  │  │ Bookings │        │
        │  │ Vehicles │  │  Admin   │        │
        │  └──────────┘  └──────────┘        │
        └──────────────────┬──────────────────┘
                           │
        ┌──────────────────┴──────────────────┐
        │         DATA & CACHE LAYER          │
        │  ┌──────────┐      ┌──────────┐     │
        │  │PostgreSQL│      │  Redis   │     │
        │  │ Database │      │  Cache   │     │
        │  └──────────┘      └──────────┘     │
        └──────────────────┬──────────────────┘
                           │
        ┌──────────────────┴──────────────────┐
        │      EXTERNAL SERVICES LAYER         │
        │  ┌──────────┐  ┌──────────┐         │
        │  │ Payment  │  │   AWS    │         │
        │  │ Gateways │  │   S3     │         │
        │  │ (PayHere │  │ (Images) │         │
        │  │ Mintpay  │  └──────────┘         │
        │  │ Koko)    │                       │
        │  └──────────┘                       │
        └──────────────────────────────────────┘
```

## 2. Backend Folder Structure

```
backend/
├── src/
│   ├── common/                    # Shared utilities
│   │   ├── decorators/            # Custom decorators
│   │   ├── entities/              # Base entities
│   │   ├── enums/                 # Enumerations
│   │   ├── filters/               # Exception filters
│   │   ├── guards/                # Auth guards
│   │   ├── interceptors/          # Request/response interceptors
│   │   ├── interfaces/            # TypeScript interfaces
│   │   ├── pipes/                 # Validation pipes
│   │   └── utils/                 # Helper functions
│   │
│   ├── config/                    # Configuration
│   │   ├── database.config.ts
│   │   ├── redis.module.ts
│   │   └── cache.config.ts
│   │
│   ├── modules/
│   │   ├── auth/                  # Authentication
│   │   ├── users/                 # User management
│   │   ├── drivers/               # Driver management
│   │   ├── vehicles/              # Vehicle management
│   │   ├── bookings/              # Booking management
│   │   ├── payments/              # Payment processing
│   │   │   ├── gateways/          # Payment gateway integrations
│   │   │   │   ├── payhere.gateway.ts
│   │   │   │   ├── mintpay.gateway.ts
│   │   │   │   ├── koko.gateway.ts
│   │   │   │   └── card.gateway.ts
│   │   │   └── bnpl/              # BNPL/EMI services
│   │   ├── revenue/               # Revenue system
│   │   │   ├── commission.service.ts
│   │   │   ├── platform-fees.service.ts
│   │   │   ├── subscriptions.service.ts
│   │   │   └── ads.service.ts
│   │   ├── admin/                 # Admin panel
│   │   ├── upload/                # File uploads
│   │   ├── notifications/        # Push/email notifications
│   │   └── analytics/             # Analytics & reporting
│   │
│   ├── migrations/                # Database migrations
│   ├── seeds/                     # Database seeds
│   └── main.ts                    # Application entry
│
├── test/                          # Test files
├── docker-compose.yml             # Docker setup
├── Dockerfile                     # Production Docker image
└── package.json
```

## 3. API Structure (REST Endpoints)

### Authentication
- `POST /api/v1/auth/register` - User registration
- `POST /api/v1/auth/send-otp` - Send OTP
- `POST /api/v1/auth/verify-otp` - Verify OTP
- `POST /api/v1/auth/login` - Login
- `POST /api/v1/auth/refresh` - Refresh token
- `POST /api/v1/auth/logout` - Logout

### Users
- `GET /api/v1/users/profile` - Get user profile
- `PUT /api/v1/users/profile` - Update profile
- `GET /api/v1/users/wallet` - Get wallet balance
- `POST /api/v1/users/wallet/topup` - Top up wallet
- `GET /api/v1/users/wallet/transactions` - Wallet transactions

### Drivers
- `POST /api/v1/drivers/register` - Driver registration
- `GET /api/v1/drivers/profile` - Get driver profile
- `PUT /api/v1/drivers/profile` - Update driver profile

### Vehicles
- `GET /api/v1/vehicles` - Search vehicles (with filters)
- `GET /api/v1/vehicles/:id` - Get vehicle details
- `POST /api/v1/vehicles` - Create vehicle (driver)
- `PUT /api/v1/vehicles/:id` - Update vehicle
- `DELETE /api/v1/vehicles/:id` - Delete vehicle
- `POST /api/v1/vehicles/:id/images` - Upload images
- `GET /api/v1/vehicles/availability/:id` - Check availability

### Bookings
- `POST /api/v1/bookings` - Create booking
- `GET /api/v1/bookings` - List bookings (user/driver)
- `GET /api/v1/bookings/:id` - Get booking details
- `PUT /api/v1/bookings/:id/cancel` - Cancel booking
- `PUT /api/v1/bookings/:id/complete` - Complete booking (driver)

### Payments
- `POST /api/v1/payments/process` - Process payment
- `POST /api/v1/payments/bnpl/initiate` - Initiate BNPL
- `POST /api/v1/payments/emi/calculate` - Calculate EMI
- `POST /api/v1/payments/refund` - Process refund
- `GET /api/v1/payments/:id` - Get payment details
- `GET /api/v1/payments/history` - Payment history

### Revenue (Admin)
- `GET /api/v1/admin/revenue/overview` - Revenue overview
- `GET /api/v1/admin/revenue/commission` - Commission reports
- `GET /api/v1/admin/revenue/subscriptions` - Subscription revenue
- `GET /api/v1/admin/revenue/ads` - Ads revenue
- `PUT /api/v1/admin/revenue/commission-rate` - Update commission rate

### Admin Panel
- `GET /api/v1/admin/dashboard` - Dashboard stats
- `GET /api/v1/admin/users` - List users
- `PUT /api/v1/admin/users/:id/status` - Update user status
- `GET /api/v1/admin/drivers` - List drivers
- `PUT /api/v1/admin/drivers/:id/verify` - Verify driver
- `GET /api/v1/admin/vehicles` - List vehicles
- `PUT /api/v1/admin/vehicles/:id/approve` - Approve vehicle
- `PUT /api/v1/admin/vehicles/:id/reject` - Reject vehicle
- `GET /api/v1/admin/bookings` - List all bookings
- `GET /api/v1/admin/reports` - Generate reports
- `PUT /api/v1/admin/pricing-rules` - Update pricing rules

## 4. Database Schema (PostgreSQL)

See `DATABASE_SCHEMA.md` for complete SQL schema with indexes.

## 5. Authentication Flow

```
1. User Registration/Login
   └─> Generate JWT Token
   └─> Store refresh token in Redis
   └─> Return access + refresh tokens

2. Request Authentication
   └─> Extract JWT from header
   └─> Validate token
   └─> Attach user to request
   └─> Check role permissions

3. Token Refresh
   └─> Validate refresh token
   └─> Generate new access token
   └─> Return new token pair
```

## 6. Payment Flow

```
1. Booking Creation
   └─> Calculate total price
   └─> Apply discounts/coupons
   └─> Create pending booking

2. Payment Processing
   ├─> Wallet Payment
   │   └─> Check balance
   │   └─> Debit wallet
   │   └─> Create transaction
   │
   ├─> Gateway Payment (PayHere/Mintpay/Koko)
   │   └─> Initiate gateway request
   │   └─> Handle webhook/callback
   │   └─> Update payment status
   │
   ├─> BNPL Payment
   │   └─> Check eligibility
   │   └─> Create installment plan
   │   └─> Process first payment
   │
   └─> Card Payment
       └─> Tokenize card
       └─> Process payment
       └─> Store card for future use

3. Payment Confirmation
   └─> Update booking status
   └─> Calculate commission
   └─> Create revenue records
   └─> Send confirmation
```

## 7. Commission Logic

```
Commission Calculation:
- Base commission: 15% of booking total
- Tiered commission based on driver performance
- Platform fees: 2.5% additional
- Subscription discounts: Up to 5% reduction

Commission Distribution:
- Platform: 15% + 2.5% fees
- Driver: 82.5% (after commission)
- Processing fees: Variable by gateway

Commission Settlement:
- Hold period: 24 hours after booking completion
- Weekly payout to drivers
- Automatic reconciliation
```

## 8. Wallet Logic

```
Wallet Operations:
- Top-up: Via payment gateway
- Debit: For bookings
- Credit: Refunds, rewards, referrals
- Transfer: Between users (future)

Transaction Types:
- CREDIT: Top-up, refund, reward, referral
- DEBIT: Booking payment, withdrawal

Balance Management:
- Real-time balance updates
- Transaction history
- Balance locks during payments
- Minimum balance requirements
```

## 9. Admin Flow

```
Admin Operations:
1. User Management
   - View all users
   - Suspend/activate accounts
   - View user activity

2. Driver Management
   - Verify driver documents
   - Approve/reject drivers
   - Monitor driver performance

3. Vehicle Management
   - Approve/reject vehicles
   - Verify vehicle documents
   - Manage vehicle status

4. Booking Management
   - View all bookings
   - Cancel bookings
   - Process refunds

5. Revenue Management
   - View revenue reports
   - Adjust commission rates
   - Manage pricing rules

6. System Configuration
   - Update platform fees
   - Manage subscription plans
   - Configure payment gateways
```

## 10. Security Model

```
Security Layers:
1. Authentication
   - JWT tokens (access + refresh)
   - Token rotation
   - Session management

2. Authorization
   - Role-based access control (RBAC)
   - Resource-level permissions
   - API endpoint guards

3. Data Protection
   - Input validation
   - SQL injection prevention
   - XSS protection
   - CSRF tokens

4. Rate Limiting
   - Per-user limits
   - Per-endpoint limits
   - IP-based throttling

5. Fraud Detection
   - Suspicious activity monitoring
   - Payment fraud detection
   - Booking conflict prevention
   - Device fingerprinting

6. Encryption
   - HTTPS/TLS
   - Encrypted sensitive data
   - Secure payment processing
```

## 11. Deployment Flow

```
Development → Staging → Production

1. Code Push
   └─> Trigger CI/CD pipeline

2. Build Stage
   └─> Run tests
   └─> Build Docker image
   └─> Security scanning

3. Deploy Stage
   └─> Deploy to staging
   └─> Run integration tests
   └─> Manual approval
   └─> Deploy to production

4. Post-Deploy
   └─> Health checks
   └─> Monitor metrics
   └─> Rollback if needed
```

## 12. DevOps Pipeline

```
CI/CD Pipeline:
- GitHub Actions / GitLab CI
- Automated testing
- Docker image building
- Container registry
- Kubernetes deployment
- Health monitoring
- Log aggregation
- Error tracking

Infrastructure:
- Container orchestration (K8s)
- Load balancing
- Auto-scaling
- Database replication
- Redis cluster
- CDN for static assets
```

## 13. Environment Configuration

```
Required Environment Variables:
- Database: DB_HOST, DB_PORT, DB_USERNAME, DB_PASSWORD, DB_DATABASE
- Redis: REDIS_HOST, REDIS_PORT, REDIS_PASSWORD
- JWT: JWT_SECRET, JWT_EXPIRES_IN
- AWS: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION, S3_BUCKET
- Payment Gateways: PAYHERE_*, MINTPAY_*, KOKO_*, STRIPE_*
- App: PORT, NODE_ENV, API_PREFIX, CORS_ORIGIN
- Security: RATE_LIMIT_TTL, RATE_LIMIT_MAX
```

## 14. Error Handling Strategy

```
Error Categories:
1. Client Errors (4xx)
   - Validation errors
   - Authentication errors
   - Authorization errors
   - Not found errors

2. Server Errors (5xx)
   - Internal server errors
   - Database errors
   - External service errors

Error Response Format:
{
  "statusCode": 400,
  "message": "Error message",
  "error": "Error type",
  "timestamp": "2026-01-27T10:00:00Z",
  "path": "/api/v1/endpoint"
}

Error Logging:
- Structured logging
- Error tracking (Sentry)
- Alert notifications
- Error analytics
```

## 15. Logging System

```
Log Levels:
- ERROR: System errors, exceptions
- WARN: Warning conditions
- INFO: Informational messages
- DEBUG: Debug information

Logging Strategy:
- Structured JSON logs
- Centralized log aggregation
- Log retention policies
- Performance logging
- Audit logging for sensitive operations

Tools:
- Winston / Pino for logging
- ELK Stack / CloudWatch for aggregation
- Sentry for error tracking
```

## Performance Targets

- API Response Time: < 200ms (p95)
- Database Queries: < 50ms (p95)
- Cache Hit Rate: > 80%
- Uptime: 99.9%
- Concurrent Users: 100k+
- Requests per Second: 10k+

## Scalability Considerations

- Horizontal scaling with load balancers
- Database read replicas
- Redis cluster for caching
- CDN for static assets
- Microservice-ready architecture
- Event-driven architecture for async operations
- Queue system for background jobs
