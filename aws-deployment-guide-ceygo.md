# CeyGo Deployment on AWS - Complete Guide

## AWS Deployment Options & Costs

### Option 1: AWS Free Tier (12 Months Free) ⭐ START HERE

Perfect for learning and initial development.

```
What's Free for 12 Months:
├─ EC2 t2.micro (1 vCPU, 1GB RAM) - 750 hours/month
├─ RDS db.t2.micro (PostgreSQL) - 750 hours/month  
├─ ElastiCache (Redis) t2.micro - 750 hours/month
├─ 5GB S3 storage
├─ 30GB EBS storage
└─ 15GB bandwidth out

Perfect for: Development, Testing, MVP
Handles: 100-500 concurrent users
Cost: $0 for first year

After 12 months: ~$20-30/month
```

### Option 2: Production on Single EC2 (Cheapest)

```
EC2 t3.small (2 vCPU, 2GB RAM)
Cost: $15/month (On-Demand)
Cost: $9/month (1-year Reserved Instance)
Cost: $6/month (Spot Instance - risky but cheap)

What runs on it:
├─ Docker Compose
├─ NestJS API
├─ PostgreSQL
├─ Redis
└─ Nginx

Handles: 5,000-10,000 users
Perfect for: Year 1-2 of CeyGo
```

### Option 3: Managed Services (Scalable)

```
Service                     Monthly Cost
────────────────────────────────────────
RDS db.t3.micro            $15
ElastiCache t3.micro       $12
EC2 t3.small               $15
Application Load Balancer  $16
Total:                     $58/month

Handles: 20,000+ users
Auto-scaling: Yes
Maintenance: Minimal
```

### Option 4: AWS Lightsail (Simplest!)

```
Lightsail 2GB Instance
Cost: $10/month
Includes: Server + Database + Static IP

Perfect for: Simple deployment
Handles: 2,000-5,000 users
Setup time: 30 minutes
```

---

## Recommended Path: Start with FREE Tier

Let me show you step-by-step how to deploy CeyGo on AWS Free Tier.

---

# AWS Free Tier Deployment Guide

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    AWS Free Tier                        │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │  EC2 t2.micro (1GB RAM) - FREE                   │  │
│  │                                                   │  │
│  │  ┌────────────────────────────────────────────┐  │  │
│  │  │  Docker Compose                           │  │  │
│  │  │  ├─ NestJS API (Port 3000)                │  │  │
│  │  │  ├─ PostgreSQL (Port 5432)                │  │  │
│  │  │  ├─ Redis (Port 6379)                     │  │  │
│  │  │  └─ Nginx (Port 80/443)                   │  │  │
│  │  └────────────────────────────────────────────┘  │  │
│  │                                                   │  │
│  │  Elastic IP: Free                                │  │
│  │  EBS Storage: 30GB Free                          │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
│  Cost: $0/month for 12 months                          │
└─────────────────────────────────────────────────────────┘
```

---

## Step-by-Step Deployment

### Step 1: Create AWS Account

```bash
1. Go to: https://aws.amazon.com
2. Click: "Create an AWS Account"
3. Enter:
   - Email address
   - Password
   - AWS Account name: "CeyGo Production"
4. Contact Information:
   - Account Type: Personal or Business
   - Full Name
   - Phone Number
   - Country: Sri Lanka
5. Payment Information:
   - Add credit/debit card (won't be charged if you stay in free tier)
6. Identity Verification:
   - Phone verification
7. Select Support Plan: Basic (Free)
8. Complete!
```

---

### Step 2: Launch EC2 Instance (Free Tier)

#### 2.1 Open EC2 Dashboard

```bash
1. Sign in to AWS Console: https://console.aws.amazon.com
2. Region: Select "Singapore (ap-southeast-1)" (closest to Sri Lanka)
3. Services → EC2 → Launch Instance
```

#### 2.2 Configure Instance

```
Step 1: Name and Tags
├─ Name: ceygo-production
└─ Add tag: Environment = Production

Step 2: Choose AMI (Operating System)
├─ Ubuntu Server 22.04 LTS
└─ ✅ Check "Free tier eligible"

Step 3: Choose Instance Type
├─ t2.micro (1 vCPU, 1GB RAM)
└─ ✅ Free tier eligible

Step 4: Key Pair (for SSH access)
├─ Create new key pair
├─ Name: ceygo-key
├─ Type: RSA
├─ Format: .pem (for Mac/Linux) or .ppk (for Windows)
└─ Download and save securely!

Step 5: Network Settings
├─ VPC: Default
├─ Auto-assign Public IP: Enable
└─ Security Group: Create new
    ├─ Name: ceygo-security-group
    ├─ Description: CeyGo API security rules
    └─ Inbound Rules:
        ├─ SSH (22) - Your IP only (for security)
        ├─ HTTP (80) - Anywhere (0.0.0.0/0)
        ├─ HTTPS (443) - Anywhere (0.0.0.0/0)
        └─ Custom TCP (3000) - Anywhere (for testing)

Step 6: Storage
├─ 30GB gp3 (General Purpose SSD)
└─ ✅ Free tier eligible (30GB max)

Step 7: Advanced Details
└─ Leave as default

Launch Instance! 🚀
```

---

### Step 3: Connect to Your EC2 Instance

#### 3.1 Get Your Instance IP

```bash
1. Go to EC2 Dashboard
2. Click "Instances"
3. Select your instance
4. Copy "Public IPv4 address" (e.g., 54.123.45.67)
```

#### 3.2 SSH into Instance (Mac/Linux)

```bash
# Set permissions on key file
chmod 400 ~/Downloads/ceygo-key.pem

# Connect to instance
ssh -i ~/Downloads/ceygo-key.pem ubuntu@YOUR_INSTANCE_IP

# Example:
ssh -i ~/Downloads/ceygo-key.pem ubuntu@54.123.45.67
```

#### 3.3 SSH into Instance (Windows)

**Using PuTTY:**
```
1. Download PuTTY: https://www.putty.org
2. Convert .pem to .ppk using PuTTYgen
3. Open PuTTY:
   - Host: ubuntu@YOUR_INSTANCE_IP
   - Port: 22
   - Connection → SSH → Auth → Private key: Select .ppk file
4. Click "Open"
```

**Using Windows Terminal (Modern Way):**
```bash
ssh -i C:\Users\YourName\Downloads\ceygo-key.pem ubuntu@YOUR_INSTANCE_IP
```

You should see:
```
Welcome to Ubuntu 22.04.3 LTS
ubuntu@ip-172-31-xx-xx:~$
```

---

### Step 4: Install Docker & Docker Compose

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add ubuntu user to docker group
sudo usermod -aG docker ubuntu

# Install Docker Compose
sudo apt install docker-compose -y

# Install Git
sudo apt install git -y

# Logout and login to apply docker group
exit
```

SSH back in:
```bash
ssh -i ~/Downloads/ceygo-key.pem ubuntu@YOUR_INSTANCE_IP
```

Verify installation:
```bash
docker --version
# Docker version 24.0.x

docker-compose --version
# docker-compose version 1.29.x
```

---

### Step 5: Clone Your CeyGo Repository

```bash
# Clone your repo
git clone https://github.com/yourusername/ceygo-backend.git
cd ceygo-backend

# Or if private repo:
git clone https://YOUR_GITHUB_TOKEN@github.com/yourusername/ceygo-backend.git
```

---

### Step 6: Create Production Environment File

```bash
nano .env.production
```

Paste:
```env
# App
NODE_ENV=production
PORT=3000
API_URL=http://YOUR_INSTANCE_IP:3000

# Database
DATABASE_URL=postgresql://ceygo_user:SecurePassword123!@postgres:5432/ceygo_db
DB_HOST=postgres
DB_PORT=5432
DB_USER=ceygo_user
DB_PASSWORD=SecurePassword123!
DB_NAME=ceygo_db

# Redis
REDIS_URL=redis://redis:6379
REDIS_HOST=redis
REDIS_PORT=6379

# JWT
JWT_SECRET=super_secure_jwt_secret_change_this_in_production_xyz789
JWT_EXPIRATION=24h
REFRESH_TOKEN_EXPIRATION=7d

# PayHere (Sri Lanka)
PAYHERE_MERCHANT_ID=your_merchant_id
PAYHERE_MERCHANT_SECRET=your_merchant_secret
PAYHERE_SANDBOX=false  # Set to true for testing
PAYHERE_NOTIFY_URL=http://YOUR_INSTANCE_IP:3000/api/v1/payments/notify
PAYHERE_RETURN_URL=http://YOUR_INSTANCE_IP:3000/api/v1/payments/success
PAYHERE_CANCEL_URL=http://YOUR_INSTANCE_IP:3000/api/v1/payments/cancel

# Firebase (Optional - can disable)
FIREBASE_ENABLED=false
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_CLIENT_EMAIL=your_client_email
FIREBASE_PRIVATE_KEY="your_private_key"

# AWS (for file uploads - optional)
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_REGION=ap-southeast-1
AWS_S3_BUCKET=ceygo-uploads

# CORS
CORS_ORIGIN=*  # Change to your frontend domain in production

# Rate Limiting
RATE_LIMIT_TTL=60
RATE_LIMIT_MAX=100

# Logging
LOG_LEVEL=info
```

Save and exit (Ctrl+X, Y, Enter)

---

### Step 7: Create Docker Compose File

```bash
nano docker-compose.yml
```

Paste:
```yaml
version: '3.8'

services:
  app:
    build: 
      context: .
      dockerfile: Dockerfile
    container_name: ceygo-api
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    env_file:
      - .env.production
    depends_on:
      - postgres
      - redis
    volumes:
      - ./uploads:/app/uploads
      - ./logs:/app/logs
    networks:
      - ceygo-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  postgres:
    image: postgres:15-alpine
    container_name: ceygo-postgres
    restart: unless-stopped
    environment:
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: ${DB_NAME}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    networks:
      - ceygo-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ceygo_user"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    container_name: ceygo-redis
    restart: unless-stopped
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"
    networks:
      - ceygo-network
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  nginx:
    image: nginx:alpine
    container_name: ceygo-nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
    depends_on:
      - app
    networks:
      - ceygo-network

volumes:
  postgres_data:
    driver: local
  redis_data:
    driver: local

networks:
  ceygo-network:
    driver: bridge
```

---

### Step 8: Create Nginx Configuration

```bash
mkdir -p nginx
nano nginx/nginx.conf
```

Paste:
```nginx
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Logging
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/json application/javascript application/xml+rss;

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;

    upstream api {
        server app:3000;
    }

    server {
        listen 80;
        server_name _;

        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header X-Content-Type-Options "nosniff" always;

        # Client max body size (for file uploads)
        client_max_body_size 10M;

        location / {
            limit_req zone=api_limit burst=20 nodelay;
            
            proxy_pass http://api;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_cache_bypass $http_upgrade;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            # Timeouts
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
        }

        # Health check endpoint (no rate limit)
        location /health {
            proxy_pass http://api;
            access_log off;
        }

        # WebSocket support for Socket.io
        location /socket.io/ {
            proxy_pass http://api;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
}
```

---

### Step 9: Create Dockerfile (if not already exists)

```bash
nano Dockerfile
```

Paste:
```dockerfile
# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy source code
COPY . .

# Build the app
RUN npm run build

# Production stage
FROM node:18-alpine

WORKDIR /app

# Copy from builder
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nestjs -u 1001

# Create directories
RUN mkdir -p /app/uploads /app/logs && \
    chown -R nestjs:nodejs /app

# Switch to non-root user
USER nestjs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Start app
CMD ["node", "dist/main"]
```

---

### Step 10: Deploy!

```bash
# Build and start all containers
docker-compose up -d --build

# This will:
# 1. Build your NestJS app
# 2. Pull PostgreSQL, Redis, Nginx images
# 3. Start all containers
# 4. Run in background (-d flag)
```

Wait 2-3 minutes for the build to complete.

Check status:
```bash
docker-compose ps
```

You should see:
```
NAME              IMAGE             STATUS
ceygo-api         ceygo-api:latest  Up
ceygo-postgres    postgres:15       Up
ceygo-redis       redis:7           Up
ceygo-nginx       nginx:alpine      Up
```

---

### Step 11: Run Database Migrations

```bash
# Run migrations
docker-compose exec app npm run typeorm migration:run

# (Optional) Seed initial data
docker-compose exec app npm run seed
```

---

### Step 12: Test Your Deployment

```bash
# Test health endpoint
curl http://YOUR_INSTANCE_IP/health

# Should return:
# {"status":"ok"}

# Check logs
docker-compose logs -f app

# You should see:
# [NestApplication] Nest application successfully started
# CeyGo API is running on: http://localhost:3000/api/v1
```

---

### Step 13: Access Your API

Your CeyGo API is now live at:
```
http://YOUR_INSTANCE_IP/api/v1
```

Test endpoints:
```bash
# Get all vehicles
curl http://YOUR_INSTANCE_IP/api/v1/vehicles

# Create a user (POST)
curl -X POST http://YOUR_INSTANCE_IP/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","phone":"+94771234567"}'
```

---

## Step 14: Setup Domain Name (Optional but Recommended)

### 14.1 Allocate Elastic IP (Free)

```bash
1. EC2 Dashboard → Elastic IPs → Allocate Elastic IP
2. Associate Elastic IP with your instance
3. Note the Elastic IP (e.g., 54.123.45.67)
```

This ensures your IP doesn't change when you restart the instance.

### 14.2 Configure Domain (if you have one)

```
Example: api.ceygo.lk

1. Go to your domain registrar (e.g., Namecheap, GoDaddy)
2. Add DNS A Record:
   - Type: A
   - Host: api
   - Value: YOUR_ELASTIC_IP
   - TTL: 300

Wait 5-30 minutes for DNS propagation
```

---

## Step 15: Setup SSL Certificate (HTTPS) - FREE

Using Let's Encrypt (Free SSL):

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Stop nginx container temporarily
docker-compose stop nginx

# Get SSL certificate
sudo certbot certonly --standalone -d api.ceygo.lk

# You'll be asked:
# - Email: your@email.com
# - Agree to terms: Yes
# - Share email: No (optional)

# Certificate will be saved at:
# /etc/letsencrypt/live/api.ceygo.lk/fullchain.pem
# /etc/letsencrypt/live/api.ceygo.lk/privkey.pem

# Copy certificates to nginx folder
sudo cp /etc/letsencrypt/live/api.ceygo.lk/fullchain.pem nginx/ssl/
sudo cp /etc/letsencrypt/live/api.ceygo.lk/privkey.pem nginx/ssl/

# Update nginx.conf to use SSL
nano nginx/nginx.conf
```

Add SSL configuration:
```nginx
server {
    listen 80;
    server_name api.ceygo.lk;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.ceygo.lk;

    ssl_certificate /etc/nginx/ssl/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # ... rest of your config
}
```

Restart nginx:
```bash
docker-compose up -d nginx
```

Now your API is accessible at: `https://api.ceygo.lk` 🔒

---

## Monitoring & Maintenance

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f app
docker-compose logs -f postgres
docker-compose logs -f redis

# Last 100 lines
docker-compose logs --tail=100 app
```

### Restart Services

```bash
# Restart all
docker-compose restart

# Restart specific service
docker-compose restart app

# Rebuild and restart
docker-compose up -d --build app
```

### Update Your Code

```bash
cd ~/ceygo-backend

# Pull latest code
git pull origin main

# Rebuild and restart
docker-compose down
docker-compose up -d --build

# Run new migrations if any
docker-compose exec app npm run typeorm migration:run
```

### Database Backup

```bash
# Create backup
docker-compose exec postgres pg_dump -U ceygo_user ceygo_db > backup-$(date +%Y%m%d).sql

# Restore from backup
docker-compose exec -T postgres psql -U ceygo_user ceygo_db < backup-20250130.sql
```

### Check Resource Usage

```bash
# Docker stats
docker stats

# System resources
htop

# Disk usage
df -h

# Check specific container
docker-compose exec app top
```

---

## Cost Optimization Tips

### 1. Use Reserved Instances (After Free Tier)

```
Instead of: t3.small on-demand ($15/month)
Use: t3.small 1-year reserved ($9/month)
Savings: 40%
```

### 2. Use Spot Instances (For Non-Critical)

```
t3.small spot: $3-6/month
Risk: Can be terminated with 2-min notice
Good for: Development, testing, background jobs
```

### 3. Stop Instance When Not in Use

```bash
# Stop instance (keeps data, stops billing compute)
aws ec2 stop-instances --instance-ids i-1234567890abcdef0

# Start when needed
aws ec2 start-instances --instance-ids i-1234567890abcdef0

# Automate: Stop at night (11 PM - 7 AM)
# Saves ~33% on compute costs
```

### 4. Use S3 for File Storage (Cheaper than EBS)

```
EBS: $0.10/GB/month
S3: $0.023/GB/month
Savings: 77%
```

### 5. Enable Cost Alerts

```bash
1. AWS Console → Billing → Budgets
2. Create Budget:
   - Name: CeyGo Monthly Budget
   - Amount: $10
   - Alert: Email when 80% reached
```

---

## Scaling Options (When You Grow)

### Level 1: Vertical Scaling (Bigger Instance)

```
Current: t2.micro (1GB RAM) - Free
Upgrade: t3.small (2GB RAM) - $15/month
Upgrade: t3.medium (4GB RAM) - $30/month
```

### Level 2: Managed Database

```
Move PostgreSQL to RDS:
- db.t3.micro: $15/month
- Automated backups
- Auto-failover
- Easy scaling
```

### Level 3: Load Balancer + Multiple Instances

```
Application Load Balancer: $16/month
2x EC2 t3.small: $30/month
RDS: $15/month
ElastiCache: $12/month
Total: $73/month
Handles: 50,000+ users
```

### Level 4: AWS App Runner (Easiest Scaling)

```
Cost: $25-100/month (auto-scales)
Zero infrastructure management
Deploy from GitHub automatically
```

---

## Security Best Practices

### 1. Update Security Group

```
Only allow:
- SSH (22) from YOUR IP (not 0.0.0.0/0)
- HTTP (80) from anywhere
- HTTPS (443) from anywhere
- Remove port 3000 direct access (use Nginx)
```

### 2. Enable AWS WAF (Optional)

```
Cost: $5/month
Blocks: SQL injection, XSS, DDoS
Good for: Production apps
```

### 3. Regular Updates

```bash
# Update every week
sudo apt update && sudo apt upgrade -y

# Update Docker images
docker-compose pull
docker-compose up -d --build
```

### 4. Enable CloudWatch Monitoring (Free Tier)

```
Monitors:
- CPU usage
- Network traffic
- Disk I/O
- Set alarms for high usage
```

---

## AWS Free Tier Limits (Don't Exceed!)

```
EC2:
✅ 750 hours/month (1 t2.micro instance 24/7)
❌ 2 instances = 1500 hours = CHARGED

EBS Storage:
✅ 30GB
❌ 31GB = CHARGED

Data Transfer:
✅ 15GB out/month
❌ 16GB = $0.09/GB charged

RDS:
✅ 750 hours/month
✅ 20GB storage
```

### Monitor Usage:
```
AWS Console → Billing → Free Tier Usage
Check weekly!
```

---

## Troubleshooting

### Issue 1: Can't Connect to Instance

```bash
# Check security group allows SSH from your IP
# Check you're using correct key file
# Check instance is running

# Test connection:
ssh -vvv -i ceygo-key.pem ubuntu@YOUR_IP
```

### Issue 2: Docker Containers Won't Start

```bash
# Check logs
docker-compose logs

# Check disk space
df -h

# Rebuild
docker-compose down
docker-compose up -d --build --force-recreate
```

### Issue 3: Out of Memory

```bash
# Check memory usage
free -h

# Add swap file (temporary fix)
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Permanent: Upgrade to larger instance
```

### Issue 4: Database Connection Failed

```bash
# Check PostgreSQL is running
docker-compose ps postgres

# Check logs
docker-compose logs postgres

# Restart PostgreSQL
docker-compose restart postgres
```

---

## Deployment Checklist

Before going to production:

- [ ] Environment variables set correctly
- [ ] Database migrations run
- [ ] SSL certificate installed (HTTPS)
- [ ] Domain name configured
- [ ] Security group configured (SSH restricted)
- [ ] Elastic IP allocated (static IP)
- [ ] Backups configured
- [ ] Monitoring enabled (CloudWatch)
- [ ] Cost alerts set ($10/month budget)
- [ ] Docker containers running
- [ ] Health check passing
- [ ] API endpoints tested
- [ ] PayHere sandbox tested
- [ ] Firebase notifications tested (if enabled)
- [ ] Load testing completed
- [ ] Error logging configured

---

## Quick Commands Reference

```bash
# SSH into instance
ssh -i ceygo-key.pem ubuntu@YOUR_IP

# View all containers
docker-compose ps

# View logs
docker-compose logs -f

# Restart services
docker-compose restart

# Update code
cd ~/ceygo-backend
git pull
docker-compose up -d --build

# Database backup
docker-compose exec postgres pg_dump -U ceygo_user ceygo_db > backup.sql

# Check disk space
df -h

# Check memory
free -h

# Check running processes
htop
```

---

## Cost Summary

### Year 1 (Free Tier):
```
EC2 t2.micro: $0
EBS 30GB: $0
Bandwidth 15GB: $0
Total: $0/month
```

### Year 2 (After Free Tier):
```
EC2 t3.small: $15/month (or $9 with reserved instance)
EBS 30GB: $3/month
Bandwidth: ~$2/month
Total: $20/month (or $14 with reserved)
```

### When You Scale (10,000+ users):
```
EC2 t3.medium: $30
RDS db.t3.small: $15
ElastiCache: $12
Load Balancer: $16
Total: $73/month
```

---

## Next Steps

1. **Deploy on Free Tier** (follow this guide)
2. **Test thoroughly** (all endpoints, payments, notifications)
3. **Monitor costs** (set budget alerts)
4. **Scale when needed** (after 1,000+ users)
5. **Consider managed services** (when revenue justifies it)

---

## Additional Resources

- **AWS Free Tier**: https://aws.amazon.com/free
- **EC2 Documentation**: https://docs.aws.amazon.com/ec2
- **Docker Compose**: https://docs.docker.com/compose
- **Let's Encrypt**: https://letsencrypt.org
- **AWS Calculator**: https://calculator.aws (estimate costs)

---

**Your CeyGo app is now running on AWS! 🚀**

Need help with any specific step? Just ask!
