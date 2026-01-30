Implementation Plan
21 minutes ago

Review

Proceed
CeyGo Car Rental App: Business Plan & Backend Architecture
This document outlines the business strategy and technical architecture for the CeyGo car rental platform, specifically tailored for the Sri Lankan market.

Business Plan
1. Market Opportunity: Sri Lanka
Local Audience: Residents in urban areas and corporate clients.
Tourist Audience: International tourists (Europe, India, China, etc.) requiring flexible transport.
Problem: Fragmented car rental market with inconsistent pricing and reliability; difficulty for tourists to find verified vehicles with English-speaking support.
Solution: "CeyGo" - A trusted platform providing verified cars for both locals (NIC) and tourists (Passport).
2. Screen & Feature Roadmap
A. Renter App (Customer)
Splash & Onboarding: Modern, 2026-style futuristic UI.
Auth: Phone number OTP (essential for SL), Google/Apple Sign-in for international users.
Home: Search car by type, location, date; Airport Pickup/Drop-off toggle.
Vehicle Detail: International driving permit (IDP) requirements info, insurance clarity.
Booking Flow: Pick-up/Drop-off details, document upload (NIC for locals / Passport for tourists).
Payment: Integrated PayHere (LKR) with GPay and International Card support (Visa/Mastercard).
Chat: Real-time communication with car owner/fleet manager.
Notifications: Booking status, reminders, promotional alerts.
Profile: Booking history, saved cars, payment methods.
B. Owner/Fleet App (Provider)
Dashboard: Earning overview, active bookings, fleet status.
Vehicle Management: Add/Edit/Delete vehicles with document verification.
Booking Requests: Accept/Reject bookings, manage availability.
Chat: Communicate with renters.
Notifications: New booking requests, payment confirmations.
C. Admin Panel (Web)
Verification Engine: Review vehicle documents and user IDs.
Transaction Monitoring: Manage payouts to owners and track revenue.
Fleet Control: Ban/Blacklist vehicles or users.
Backend Architecture Proposal
1. Technology Stack Recommendation
The objective is to minimize Monthly OPEX (Operating Expenditure) without sacrificing performance.

Feature	Option A: Firebase (Serverless)	Option B: Custom (Node.js + PostgreSQL)
Effort	Low (Fast development)	Medium (Requires server setup)
Monthly Cost	Free tier initially, then Pay-as-you-go	Fixed ($5-$15/month for VPS)
Database	Firestore (NoSQL)	PostgreSQL (Relational)
Storage	Firebase Storage	Firebase Storage
Notifications	FCM	FCM
Verdict for CeyGo: Option B (Custom Backend) is the most cost-friendly for the Sri Lankan market. You can host it on a DigitalOcean/Hetzner droplet for as low as $6/month, covering everything (DB, API, Chat).

2. Technical Stack Details
Languages: TypeScript / Node.js (Express or NestJS).
Database: PostgreSQL (Superior for relational booking data).
Caching: Redis (Used for caching vehicle availability and sessions).
Auth: Firebase Auth (Identity platform) + JWT for backend session management. This gives you the reliability of Google's auth for free while maintaining your own backend.
Chat: Socket.io (Real-time) with messages persisted in PostgreSQL.
Storage: Firebase Storage (Generous free tier for images).
Notifications: Firebase Cloud Messaging (FCM) for push.
2. Database Schema (PostgreSQL)
Users: id, name, email, phone, nationality, id_type (NIC/Passport), id_number, license_no, profile_pic, role (renter/owner)
Vehicles: id, name, brand, brand_logo, image_url, price_per_day, seats, transmission, fuel_type, rating, trip_count, owner_id, plate_no, airport_pickup_available, status
Bookings: id, vehicle_id, renter_id, start_date, end_date, pickup_location, dropoff_location, flight_number (for tourists), total_price, currency (LKR/USD), status, payment_id
Payments: id, booking_id, amount, status, gateway_ref, method (PayHere/GPay/Mintpay/Koko)
Chat: id, sender_id, receiver_id, message, timestamp
3. Key Feature Implementation
Chat Feature
Tech: Socket.io for real-time communication.
Storage: Store chat history in the database for persistence.
Push: Send a push notification when a message is received and the user is offline.
Notifications
System: Trigger notifications for booking requests, confirmations, and reminders.
Medium: Firebase Cloud Messaging (FCM) for Push, Twilio/Notify.lk for SMS (critical for SL market).
Cloud Cache
Tech: Redis.
Use Case: Caching vehicle search results, session management, and frequently accessed metadata to reduce DB load and cost.
Payment Setup (PayHere & GPay)
International Payments: PayHere supports International Credit Cards. Ensure the Merchant Account is configured to accept Visa/Mastercard from outside Sri Lanka.
Multi-Currency Display: While the backend processes LKR, the frontend should display estimated prices in USD for tourists (fetching rates via an API like OpenExchangeRates).
PayHere SDK: Essential for local LKR payments and GPay.
GPay:
GPay in Sri Lanka is typically handled by PayHere through their Mobile SDK (Android).
Alternatively, Stripe can be used for GPay if targeting international tourists, but LKR support is limited. Recommendation: Stick to PayHere SDK for GPay support within the local LKR ecosystem.
Handover Structure for Backend Team
API Documentation: Swagger/OpenAPI spec.
Environment Configuration: Dockerized setup for local development.
Database Migrations: Version-controlled schema changes.
Security: SSL, Rate limiting, input validation.
Verification Plan
Automated Tests
Unit tests for API endpoints using Jest/Mocha.
Schema validation tests.
Manual Verification
Verify PayHere sandbox transaction flow.
Test Push notifications on Android/iOS devices.
Verify real-time chat latency.