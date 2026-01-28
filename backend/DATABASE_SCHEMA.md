# Database Schema - CeyGo Platform

## Complete SQL Schema with Indexes

```sql
-- ============================================
-- USERS & AUTHENTICATION
-- ============================================

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE,
    password_hash VARCHAR(255),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    role VARCHAR(20) DEFAULT 'user' CHECK (role IN ('user', 'driver', 'admin')),
    is_verified BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    profile_image_url TEXT,
    city VARCHAR(100),
    country VARCHAR(100) DEFAULT 'Sri Lanka',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_is_active ON users(is_active);
CREATE INDEX idx_users_city ON users(city);

-- ============================================
-- WALLETS
-- ============================================

CREATE TABLE wallets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    balance DECIMAL(10, 2) DEFAULT 0.00 CHECK (balance >= 0),
    total_earned DECIMAL(10, 2) DEFAULT 0.00,
    total_spent DECIMAL(10, 2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_wallets_user_id ON wallets(user_id);

-- ============================================
-- WALLET TRANSACTIONS
-- ============================================

CREATE TABLE wallet_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_id UUID NOT NULL REFERENCES wallets(id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('credit', 'debit')),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'cancelled')),
    description TEXT NOT NULL,
    reference VARCHAR(255),
    booking_id UUID,
    balance_before DECIMAL(10, 2) NOT NULL,
    balance_after DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_wallet_transactions_wallet_id ON wallet_transactions(wallet_id);
CREATE INDEX idx_wallet_transactions_booking_id ON wallet_transactions(booking_id);
CREATE INDEX idx_wallet_transactions_status ON wallet_transactions(status);
CREATE INDEX idx_wallet_transactions_created_at ON wallet_transactions(created_at DESC);
CREATE INDEX idx_wallet_transactions_type ON wallet_transactions(type);

-- ============================================
-- DRIVERS
-- ============================================

CREATE TABLE drivers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    license_number VARCHAR(50) UNIQUE,
    license_expiry_date DATE,
    license_image_url TEXT,
    is_verified BOOLEAN DEFAULT false,
    verification_status VARCHAR(20) DEFAULT 'pending' CHECK (verification_status IN ('pending', 'approved', 'rejected')),
    verification_notes TEXT,
    rating DECIMAL(3, 2) DEFAULT 0.00 CHECK (rating >= 0 AND rating <= 5),
    total_ratings INTEGER DEFAULT 0,
    total_bookings INTEGER DEFAULT 0,
    total_earnings DECIMAL(10, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_drivers_user_id ON drivers(user_id);
CREATE INDEX idx_drivers_verification_status ON drivers(verification_status);
CREATE INDEX idx_drivers_is_verified ON drivers(is_verified);

-- ============================================
-- VEHICLES
-- ============================================

CREATE TABLE vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id UUID NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
    make VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    year INTEGER NOT NULL,
    color VARCHAR(50),
    license_plate VARCHAR(20) UNIQUE NOT NULL,
    vin VARCHAR(50),
    transmission VARCHAR(20) CHECK (transmission IN ('manual', 'automatic')),
    fuel_type VARCHAR(20) CHECK (fuel_type IN ('petrol', 'diesel', 'electric', 'hybrid')),
    seats INTEGER NOT NULL CHECK (seats > 0),
    price_per_day DECIMAL(10, 2) NOT NULL CHECK (price_per_day > 0),
    location VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    description TEXT,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'suspended')),
    is_available BOOLEAN DEFAULT true,
    rating DECIMAL(3, 2) DEFAULT 0.00 CHECK (rating >= 0 AND rating <= 5),
    total_ratings INTEGER DEFAULT 0,
    trip_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_vehicles_driver_id ON vehicles(driver_id);
CREATE INDEX idx_vehicles_status ON vehicles(status);
CREATE INDEX idx_vehicles_is_available ON vehicles(is_available);
CREATE INDEX idx_vehicles_city ON vehicles(city);
CREATE INDEX idx_vehicles_location ON vehicles USING GIST (point(longitude, latitude));
CREATE INDEX idx_vehicles_price_per_day ON vehicles(price_per_day);
CREATE INDEX idx_vehicles_make_model ON vehicles(make, model);
CREATE INDEX idx_vehicles_license_plate ON vehicles(license_plate);

-- ============================================
-- VEHICLE IMAGES
-- ============================================

CREATE TABLE vehicle_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    url TEXT NOT NULL,
    s3_key VARCHAR(255),
    is_primary BOOLEAN DEFAULT false,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_vehicle_images_vehicle_id ON vehicle_images(vehicle_id);
CREATE INDEX idx_vehicle_images_is_primary ON vehicle_images(is_primary);

-- ============================================
-- BOOKINGS
-- ============================================

CREATE TABLE bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    vehicle_id UUID NOT NULL REFERENCES vehicles(id) ON DELETE RESTRICT,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    pickup_time TIME,
    pickup_location VARCHAR(255) NOT NULL,
    dropoff_location VARCHAR(255),
    total_price DECIMAL(10, 2) NOT NULL CHECK (total_price > 0),
    commission DECIMAL(10, 2) DEFAULT 0.00,
    platform_fee DECIMAL(10, 2) DEFAULT 0.00,
    driver_earnings DECIMAL(10, 2) DEFAULT 0.00,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'active', 'completed', 'cancelled')),
    cancellation_reason TEXT,
    cancelled_at TIMESTAMP,
    cancelled_by VARCHAR(20) CHECK (cancelled_by IN ('user', 'driver', 'admin', 'system')),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_dates CHECK (end_date > start_date)
);

CREATE INDEX idx_bookings_user_id ON bookings(user_id);
CREATE INDEX idx_bookings_vehicle_id ON bookings(vehicle_id);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_bookings_dates ON bookings(start_date, end_date);
CREATE INDEX idx_bookings_created_at ON bookings(created_at DESC);
CREATE INDEX idx_bookings_date_range ON bookings USING GIST (tstzrange(start_date, end_date));

-- ============================================
-- PAYMENTS
-- ============================================

CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID UNIQUE NOT NULL REFERENCES bookings(id) ON DELETE RESTRICT,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
    method VARCHAR(20) NOT NULL CHECK (method IN ('card', 'wallet', 'payhere', 'mintpay', 'koko', 'bnpl', 'emi')),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'refunded', 'partially_refunded')),
    transaction_id VARCHAR(255),
    gateway_transaction_id VARCHAR(255),
    gateway_response JSONB,
    refund_transaction_id VARCHAR(255),
    refund_amount DECIMAL(10, 2),
    refunded_at TIMESTAMP,
    failure_reason TEXT,
    is_bnpl BOOLEAN DEFAULT false,
    bnpl_plan_id UUID,
    is_emi BOOLEAN DEFAULT false,
    emi_plan_id UUID,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_payments_booking_id ON payments(booking_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_method ON payments(method);
CREATE INDEX idx_payments_gateway_transaction_id ON payments(gateway_transaction_id);
CREATE INDEX idx_payments_created_at ON payments(created_at DESC);
CREATE INDEX idx_payments_is_bnpl ON payments(is_bnpl);
CREATE INDEX idx_payments_is_emi ON payments(is_emi);

-- ============================================
-- BNPL PLANS
-- ============================================

CREATE TABLE bnpl_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id UUID NOT NULL REFERENCES payments(id) ON DELETE CASCADE,
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE RESTRICT,
    total_amount DECIMAL(10, 2) NOT NULL,
    installment_count INTEGER NOT NULL CHECK (installment_count > 0),
    installment_amount DECIMAL(10, 2) NOT NULL,
    interest_rate DECIMAL(5, 2) DEFAULT 0.00,
    first_payment_date DATE NOT NULL,
    last_payment_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'defaulted', 'cancelled')),
    provider VARCHAR(50),
    provider_plan_id VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_bnpl_plans_payment_id ON bnpl_plans(payment_id);
CREATE INDEX idx_bnpl_plans_booking_id ON bnpl_plans(booking_id);
CREATE INDEX idx_bnpl_plans_status ON bnpl_plans(status);

-- ============================================
-- BNPL INSTALLMENTS
-- ============================================

CREATE TABLE bnpl_installments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    plan_id UUID NOT NULL REFERENCES bnpl_plans(id) ON DELETE CASCADE,
    installment_number INTEGER NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    due_date DATE NOT NULL,
    paid_date DATE,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'overdue', 'failed')),
    payment_id UUID REFERENCES payments(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_bnpl_installments_plan_id ON bnpl_installments(plan_id);
CREATE INDEX idx_bnpl_installments_status ON bnpl_installments(status);
CREATE INDEX idx_bnpl_installments_due_date ON bnpl_installments(due_date);

-- ============================================
-- EMI PLANS
-- ============================================

CREATE TABLE emi_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id UUID NOT NULL REFERENCES payments(id) ON DELETE CASCADE,
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE RESTRICT,
    principal_amount DECIMAL(10, 2) NOT NULL,
    interest_rate DECIMAL(5, 2) NOT NULL,
    tenure_months INTEGER NOT NULL CHECK (tenure_months > 0),
    emi_amount DECIMAL(10, 2) NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    first_payment_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'defaulted', 'cancelled')),
    bank_name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_emi_plans_payment_id ON emi_plans(payment_id);
CREATE INDEX idx_emi_plans_booking_id ON emi_plans(booking_id);
CREATE INDEX idx_emi_plans_status ON emi_plans(status);

-- ============================================
-- EMI INSTALLMENTS
-- ============================================

CREATE TABLE emi_installments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    plan_id UUID NOT NULL REFERENCES emi_plans(id) ON DELETE CASCADE,
    installment_number INTEGER NOT NULL,
    principal_amount DECIMAL(10, 2) NOT NULL,
    interest_amount DECIMAL(10, 2) NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    due_date DATE NOT NULL,
    paid_date DATE,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'overdue', 'failed')),
    payment_id UUID REFERENCES payments(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_emi_installments_plan_id ON emi_installments(plan_id);
CREATE INDEX idx_emi_installments_status ON emi_installments(status);
CREATE INDEX idx_emi_installments_due_date ON emi_installments(due_date);

-- ============================================
-- REVENUE & COMMISSIONS
-- ============================================

CREATE TABLE revenue_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE RESTRICT,
    payment_id UUID NOT NULL REFERENCES payments(id) ON DELETE RESTRICT,
    revenue_type VARCHAR(50) NOT NULL CHECK (revenue_type IN ('commission', 'platform_fee', 'subscription', 'ads', 'other')),
    amount DECIMAL(10, 2) NOT NULL,
    commission_rate DECIMAL(5, 2),
    driver_id UUID REFERENCES drivers(id),
    user_id UUID REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'settled', 'cancelled')),
    settled_at TIMESTAMP,
    settlement_period VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_revenue_records_booking_id ON revenue_records(booking_id);
CREATE INDEX idx_revenue_records_payment_id ON revenue_records(payment_id);
CREATE INDEX idx_revenue_records_revenue_type ON revenue_records(revenue_type);
CREATE INDEX idx_revenue_records_status ON revenue_records(status);
CREATE INDEX idx_revenue_records_driver_id ON revenue_records(driver_id);
CREATE INDEX idx_revenue_records_settled_at ON revenue_records(settled_at);

-- ============================================
-- SUBSCRIPTIONS
-- ============================================

CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    plan_type VARCHAR(50) NOT NULL CHECK (plan_type IN ('basic', 'premium', 'enterprise')),
    plan_name VARCHAR(100) NOT NULL,
    price_per_month DECIMAL(10, 2) NOT NULL,
    discount_percentage DECIMAL(5, 2) DEFAULT 0.00,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'cancelled', 'expired', 'suspended')),
    start_date DATE NOT NULL,
    end_date DATE,
    auto_renew BOOLEAN DEFAULT true,
    payment_method VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);
CREATE INDEX idx_subscriptions_plan_type ON subscriptions(plan_type);

-- ============================================
-- SUBSCRIPTION PAYMENTS
-- ============================================

CREATE TABLE subscription_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscription_id UUID NOT NULL REFERENCES subscriptions(id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL,
    payment_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed')),
    payment_id UUID REFERENCES payments(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_subscription_payments_subscription_id ON subscription_payments(subscription_id);
CREATE INDEX idx_subscription_payments_status ON subscription_payments(status);
CREATE INDEX idx_subscription_payments_payment_date ON subscription_payments(payment_date);

-- ============================================
-- ADS
-- ============================================

CREATE TABLE ads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    advertiser_id UUID REFERENCES users(id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    image_url TEXT,
    link_url TEXT,
    ad_type VARCHAR(50) CHECK (ad_type IN ('banner', 'interstitial', 'video', 'native')),
    placement VARCHAR(50) CHECK (placement IN ('home', 'search', 'vehicle_detail', 'booking')),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'paused', 'expired', 'rejected')),
    start_date DATE NOT NULL,
    end_date DATE,
    budget DECIMAL(10, 2) NOT NULL,
    spent DECIMAL(10, 2) DEFAULT 0.00,
    impressions INTEGER DEFAULT 0,
    clicks INTEGER DEFAULT 0,
    ctr DECIMAL(5, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_ads_status ON ads(status);
CREATE INDEX idx_ads_placement ON ads(placement);
CREATE INDEX idx_ads_dates ON ads(start_date, end_date);
CREATE INDEX idx_ads_advertiser_id ON ads(advertiser_id);

-- ============================================
-- ADS IMPRESSIONS & CLICKS
-- ============================================

CREATE TABLE ad_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ad_id UUID NOT NULL REFERENCES ads(id) ON DELETE CASCADE,
    event_type VARCHAR(20) NOT NULL CHECK (event_type IN ('impression', 'click', 'conversion')),
    user_id UUID REFERENCES users(id),
    ip_address VARCHAR(45),
    user_agent TEXT,
    referrer TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_ad_events_ad_id ON ad_events(ad_id);
CREATE INDEX idx_ad_events_event_type ON ad_events(event_type);
CREATE INDEX idx_ad_events_created_at ON ad_events(created_at DESC);

-- ============================================
-- PRICING RULES
-- ============================================

CREATE TABLE pricing_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rule_name VARCHAR(100) NOT NULL,
    rule_type VARCHAR(50) NOT NULL CHECK (rule_type IN ('commission', 'platform_fee', 'discount', 'surcharge')),
    target_type VARCHAR(50) CHECK (target_type IN ('all', 'city', 'vehicle_type', 'user_tier')),
    target_value VARCHAR(255),
    value DECIMAL(10, 2) NOT NULL,
    value_type VARCHAR(20) CHECK (value_type IN ('percentage', 'fixed')),
    is_active BOOLEAN DEFAULT true,
    start_date DATE,
    end_date DATE,
    priority INTEGER DEFAULT 0,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_pricing_rules_rule_type ON pricing_rules(rule_type);
CREATE INDEX idx_pricing_rules_is_active ON pricing_rules(is_active);
CREATE INDEX idx_pricing_rules_priority ON pricing_rules(priority DESC);

-- ============================================
-- OTP (One-Time Password)
-- ============================================

CREATE TABLE otps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone VARCHAR(20) NOT NULL,
    code VARCHAR(6) NOT NULL,
    purpose VARCHAR(50) NOT NULL CHECK (purpose IN ('register', 'login', 'reset_password', 'verify_phone')),
    is_used BOOLEAN DEFAULT false,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_otps_phone ON otps(phone);
CREATE INDEX idx_otps_code ON otps(code);
CREATE INDEX idx_otps_expires_at ON otps(expires_at);

-- ============================================
-- AUDIT LOGS
-- ============================================

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_entity_type ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at DESC);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);

-- ============================================
-- NOTIFICATIONS
-- ============================================

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    data JSONB,
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX idx_notifications_user_unread ON notifications(user_id, is_read) WHERE is_read = false;

-- ============================================
-- FUNCTIONS & TRIGGERS
-- ============================================

-- Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply to all tables with updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_wallets_updated_at BEFORE UPDATE ON wallets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_drivers_updated_at BEFORE UPDATE ON drivers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_vehicles_updated_at BEFORE UPDATE ON vehicles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bookings_updated_at BEFORE UPDATE ON bookings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- VIEWS
-- ============================================

-- Revenue Summary View
CREATE OR REPLACE VIEW revenue_summary AS
SELECT
    DATE_TRUNC('month', created_at) as month,
    revenue_type,
    SUM(amount) as total_amount,
    COUNT(*) as transaction_count
FROM revenue_records
WHERE status = 'settled'
GROUP BY DATE_TRUNC('month', created_at), revenue_type;

-- Driver Earnings View
CREATE OR REPLACE VIEW driver_earnings_summary AS
SELECT
    d.id as driver_id,
    d.user_id,
    COUNT(b.id) as total_bookings,
    SUM(b.driver_earnings) as total_earnings,
    SUM(b.commission) as total_commission_paid,
    AVG(b.driver_earnings) as avg_earnings_per_booking
FROM drivers d
LEFT JOIN vehicles v ON v.driver_id = d.id
LEFT JOIN bookings b ON b.vehicle_id = v.id AND b.status = 'completed'
GROUP BY d.id, d.user_id;

```

## Performance Optimizations

1. **Indexes**: All foreign keys, frequently queried columns, and date ranges are indexed
2. **Partial Indexes**: For common filtered queries (e.g., unread notifications)
3. **GIST Indexes**: For geospatial queries on vehicle locations and booking date ranges
4. **Composite Indexes**: For multi-column queries
5. **Materialized Views**: For complex aggregations (can be added as needed)

## Database Maintenance

- Regular VACUUM and ANALYZE
- Index maintenance
- Partitioning for large tables (bookings, payments) by date
- Connection pooling
- Read replicas for read-heavy operations
