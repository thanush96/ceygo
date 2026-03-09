-- ============================================================
-- CeyGo Test Seed Data
-- 5 Renters, 10 Owners, Vehicles, Bookings, Payments,
-- Favorites, Chat History
-- ============================================================

BEGIN;

-- Clean existing test data (by email pattern)
DELETE FROM favorites WHERE user_id IN (SELECT id FROM users WHERE email LIKE '%@testceygo.com');
DELETE FROM chat_messages WHERE sender_id IN (SELECT id FROM users WHERE email LIKE '%@testceygo.com') OR receiver_id IN (SELECT id FROM users WHERE email LIKE '%@testceygo.com');
UPDATE bookings SET payment_id = NULL WHERE renter_id IN (SELECT id FROM users WHERE email LIKE '%@testceygo.com');
DELETE FROM payments WHERE id IN (SELECT payment_id FROM bookings WHERE renter_id IN (SELECT id FROM users WHERE email LIKE '%@testceygo.com'));
DELETE FROM bookings WHERE renter_id IN (SELECT id FROM users WHERE email LIKE '%@testceygo.com');
DELETE FROM vehicles WHERE owner_id IN (SELECT id FROM users WHERE email LIKE '%@testceygo.com');
DELETE FROM users WHERE email LIKE '%@testceygo.com';

-- ============================================================
-- VEHICLE BRANDS (upsert)
-- ============================================================
INSERT INTO vehicle_brands (id, name, logo_url, is_active, created_at, updated_at)
VALUES
  ('b0000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Toyota', 'https://www.carlogos.org/car-logos/toyota-logo-2020-europe.png', true, NOW(), NOW()),
  ('b0000002-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Honda', 'https://www.carlogos.org/car-logos/honda-logo-2000.png', true, NOW(), NOW()),
  ('b0000003-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Suzuki', 'https://www.carlogos.org/car-logos/suzuki-logo-2000.png', true, NOW(), NOW()),
  ('b0000004-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Nissan', 'https://www.carlogos.org/car-logos/nissan-logo-2020.png', true, NOW(), NOW()),
  ('b0000005-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'BMW', 'https://www.carlogos.org/car-logos/bmw-logo-2020.png', true, NOW(), NOW()),
  ('b0000006-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Mercedes-Benz', 'https://www.carlogos.org/car-logos/mercedes-benz-logo-2011.png', true, NOW(), NOW()),
  ('b0000007-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Hyundai', 'https://www.carlogos.org/car-logos/hyundai-logo-2011.png', true, NOW(), NOW()),
  ('b0000008-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'KIA', 'https://www.carlogos.org/car-logos/kia-logo-2021.png', true, NOW(), NOW()),
  ('b0000009-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Mitsubishi', 'https://www.carlogos.org/car-logos/mitsubishi-logo-2000.png', true, NOW(), NOW()),
  ('b000000a-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Audi', 'https://www.carlogos.org/car-logos/audi-logo-2016.png', true, NOW(), NOW())
ON CONFLICT (name) DO NOTHING;

-- ============================================================
-- 5 RENTER USERS
-- ============================================================
INSERT INTO users (id, name, email, phone, nationality, id_type, nic, license_no, role, verification_status, status, created_at, updated_at)
VALUES
  ('a1000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Kamal Perera',      'kamal@testceygo.com',   '+94771000001', 'Sri Lankan', 'NIC', '199012345678', 'DL-0001', 'renter', 'approved', 'active', NOW() - INTERVAL '60 days', NOW()),
  ('a1000002-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Nimal Silva',       'nimal@testceygo.com',   '+94771000002', 'Sri Lankan', 'NIC', '199112345678', 'DL-0002', 'renter', 'approved', 'active', NOW() - INTERVAL '55 days', NOW()),
  ('a1000003-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Saman Fernando',    'saman@testceygo.com',   '+94771000003', 'Sri Lankan', 'NIC', '199212345678', 'DL-0003', 'renter', 'approved', 'active', NOW() - INTERVAL '50 days', NOW()),
  ('a1000004-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Ruwan Jayasekara',  'ruwan@testceygo.com',   '+94771000004', 'Sri Lankan', 'NIC', '199312345678', 'DL-0004', 'renter', 'pending',  'active', NOW() - INTERVAL '10 days', NOW()),
  ('a1000005-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Dilshan Rajapaksa', 'dilshan@testceygo.com', '+94771000005', 'Sri Lankan', 'NIC', '199412345678', 'DL-0005', 'renter', 'approved', 'active', NOW() - INTERVAL '45 days', NOW());

-- ============================================================
-- 10 OWNER USERS
-- ============================================================
INSERT INTO users (id, name, email, phone, nationality, id_type, nic, license_no, role, verification_status, status, created_at, updated_at)
VALUES
  ('a2000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Chaminda Vaas',         'chaminda@testceygo.com', '+94772000001', 'Sri Lankan', 'NIC', '198512345678', 'DL-1001', 'owner', 'approved', 'active', NOW() - INTERVAL '90 days', NOW()),
  ('a2000002-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Mahela Jayawardena',    'mahela@testceygo.com',   '+94772000002', 'Sri Lankan', 'NIC', '198612345678', 'DL-1002', 'owner', 'approved', 'active', NOW() - INTERVAL '85 days', NOW()),
  ('a2000003-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Kumar Sangakkara',      'kumar@testceygo.com',    '+94772000003', 'Sri Lankan', 'NIC', '198712345678', 'DL-1003', 'owner', 'approved', 'active', NOW() - INTERVAL '80 days', NOW()),
  ('a2000004-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Lasith Malinga',        'lasith@testceygo.com',   '+94772000004', 'Sri Lankan', 'NIC', '198812345678', 'DL-1004', 'owner', 'approved', 'active', NOW() - INTERVAL '75 days', NOW()),
  ('a2000005-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Tillakaratne Dilshan',  'tilla@testceygo.com',    '+94772000005', 'Sri Lankan', 'NIC', '198912345678', 'DL-1005', 'owner', 'approved', 'active', NOW() - INTERVAL '70 days', NOW()),
  ('a2000006-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Angelo Mathews',        'angelo@testceygo.com',   '+94772000006', 'Sri Lankan', 'NIC', '199012345679', 'DL-1006', 'owner', 'approved', 'active', NOW() - INTERVAL '65 days', NOW()),
  ('a2000007-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Dimuth Karunaratne',    'dimuth@testceygo.com',   '+94772000007', 'Sri Lankan', 'NIC', '199112345679', 'DL-1007', 'owner', 'approved', 'active', NOW() - INTERVAL '60 days', NOW()),
  ('a2000008-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Dhananjaya de Silva',   'dhana@testceygo.com',    '+94772000008', 'Sri Lankan', 'NIC', '199212345679', 'DL-1008', 'owner', 'pending',  'active', NOW() - INTERVAL '20 days', NOW()),
  ('a2000009-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Wanindu Hasaranga',     'wanindu@testceygo.com',  '+94772000009', 'Sri Lankan', 'NIC', '199312345679', 'DL-1009', 'owner', 'approved', 'active', NOW() - INTERVAL '50 days', NOW()),
  ('a200000a-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Pathum Nissanka',       'pathum@testceygo.com',   '+94772000010', 'Sri Lankan', 'NIC', '199412345679', 'DL-1010', 'owner', 'approved', 'active', NOW() - INTERVAL '40 days', NOW());

-- ============================================================
-- 20 VEHICLES (2 per owner)
-- ============================================================
INSERT INTO vehicles (id, name, brand, brand_logo, image_url, price_per_day, seats, transmission, fuel_type, rating, trip_count, owner_id, plate_no, airport_pickup_available, status, verification_status, location, created_at, updated_at)
VALUES
  -- Owner 1: Chaminda
  ('c1000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Corolla',  'Toyota', 'https://www.carlogos.org/car-logos/toyota-logo-2020-europe.png', 'https://images.unsplash.com/photo-1623869675781-80aa31012a5a?w=800', 5000.00, 5, 'Auto', 'Petrol', 4.5, 23, 'a2000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'WP CAB-1234', true,  'available', 'approved', 'Colombo',  NOW() - INTERVAL '80 days', NOW()),
  ('c1000002-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Axio',     'Toyota', 'https://www.carlogos.org/car-logos/toyota-logo-2020-europe.png', 'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800', 4500.00, 5, 'Auto', 'Hybrid', 4.2, 15, 'a2000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'WP KA-5678',  false, 'available', 'approved', 'Negombo',  NOW() - INTERVAL '70 days', NOW()),
  -- Owner 2: Mahela
  ('c1000003-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Civic',    'Honda',  'https://www.carlogos.org/car-logos/honda-logo-2000.png', 'https://images.unsplash.com/photo-1606611013016-969c19ba27d5?w=800', 6000.00, 5, 'Auto', 'Petrol', 4.7, 31, 'a2000002-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'WP CBB-2345', true,  'available', 'approved', 'Colombo',  NOW() - INTERVAL '75 days', NOW()),
  ('c1000004-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Vezel',    'Honda',  'https://www.carlogos.org/car-logos/honda-logo-2000.png', 'https://images.unsplash.com/photo-1568844293986-8d0400f4f36c?w=800', 7500.00, 5, 'Auto', 'Hybrid', 4.8, 18, 'a2000002-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'WP KD-9012',  true,  'rented',    'approved', 'Kandy',    NOW() - INTERVAL '60 days', NOW()),
  -- Owner 3: Kumar
  ('c1000005-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Swift',    'Suzuki', 'https://www.carlogos.org/car-logos/suzuki-logo-2000.png', 'https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=800', 3500.00, 5, 'Manual', 'Petrol', 4.0, 42, 'a2000003-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'SP AB-3456',  false, 'available', 'approved', 'Galle',    NOW() - INTERVAL '70 days', NOW()),
  ('c1000006-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Alto',     'Suzuki', 'https://www.carlogos.org/car-logos/suzuki-logo-2000.png', 'https://images.unsplash.com/photo-1549317661-bd32c8ce0ffe?w=800', 2500.00, 4, 'Manual', 'Petrol', 3.8, 55, 'a2000003-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'SP CD-7890',  false, 'available', 'approved', 'Matara',   NOW() - INTERVAL '65 days', NOW()),
  -- Owner 4: Lasith
  ('c1000007-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'X-Trail',  'Nissan', 'https://www.carlogos.org/car-logos/nissan-logo-2020.png', 'https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=800', 8000.00, 7, 'Auto', 'Diesel', 4.6, 12, 'a2000004-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'WP NB-4567',  true,  'available', 'approved', 'Colombo',  NOW() - INTERVAL '65 days', NOW()),
  ('c1000008-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Leaf',     'Nissan', 'https://www.carlogos.org/car-logos/nissan-logo-2020.png', 'https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=800', 5500.00, 5, 'Auto', 'Electric', 4.3, 8, 'a2000004-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'WP EV-1111',  true,  'available', 'approved', 'Negombo',  NOW() - INTERVAL '50 days', NOW()),
  -- Owner 5: Tillakaratne
  ('c1000009-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '320i',     'BMW',    'https://www.carlogos.org/car-logos/bmw-logo-2020.png', 'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800', 15000.00, 5, 'Auto', 'Petrol', 4.9, 7,  'a2000005-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'WP BM-8888',  true,  'available', 'approved', 'Colombo',  NOW() - INTERVAL '60 days', NOW()),
  ('c100000a-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'X5',       'BMW',    'https://www.carlogos.org/car-logos/bmw-logo-2020.png', 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800', 20000.00, 7, 'Auto', 'Diesel', 4.9, 5,  'a2000005-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'WP BM-9999',  true,  'rented',    'approved', 'Colombo',  NOW() - INTERVAL '55 days', NOW()),
  -- Owner 6: Angelo
  ('c100000b-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'C200',     'Mercedes-Benz', 'https://www.carlogos.org/car-logos/mercedes-benz-logo-2011.png', 'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=800', 18000.00, 5, 'Auto', 'Petrol', 4.8, 9,  'a2000006-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'WP MB-5555',  true,  'available',   'approved', 'Colombo', NOW() - INTERVAL '55 days', NOW()),
  ('c100000c-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'GLA',      'Mercedes-Benz', 'https://www.carlogos.org/car-logos/mercedes-benz-logo-2011.png', 'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=800', 22000.00, 5, 'Auto', 'Diesel', 4.7, 4,  'a2000006-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'WP MB-6666',  true,  'maintenance', 'approved', 'Kandy',   NOW() - INTERVAL '40 days', NOW()),
  -- Owner 7: Dimuth
  ('c100000d-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Tucson',   'Hyundai', 'https://www.carlogos.org/car-logos/hyundai-logo-2011.png', 'https://images.unsplash.com/photo-1629897048514-3dd7414fe72a?w=800', 7000.00, 5, 'Auto', 'Diesel', 4.4, 20, 'a2000007-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'CP TU-1234',  true,  'available', 'approved', 'Kandy',         NOW() - INTERVAL '50 days', NOW()),
  ('c100000e-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'i20',      'Hyundai', 'https://www.carlogos.org/car-logos/hyundai-logo-2011.png', 'https://images.unsplash.com/photo-1583121274602-3e2820c69888?w=800', 3800.00, 5, 'Manual', 'Petrol', 4.1, 28, 'a2000007-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'CP HY-5678',  false, 'available', 'approved', 'Nuwara Eliya', NOW() - INTERVAL '45 days', NOW()),
  -- Owner 8: Dhananjaya (pending)
  ('c100000f-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Seltos',   'KIA',   'https://www.carlogos.org/car-logos/kia-logo-2021.png', 'https://images.unsplash.com/photo-1619767886558-efdc259cde1a?w=800', 6500.00, 5, 'Auto', 'Petrol', 0, 0,   'a2000008-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'NW KI-2222',  true,  'available', 'pending', 'Kurunegala', NOW() - INTERVAL '15 days', NOW()),
  ('c1000010-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Sportage', 'KIA',   'https://www.carlogos.org/car-logos/kia-logo-2021.png', 'https://images.unsplash.com/photo-1605559424843-9e4c228bf1c2?w=800', 8500.00, 5, 'Auto', 'Diesel', 0, 0,   'a2000008-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'NW KI-3333',  true,  'available', 'pending', 'Kurunegala', NOW() - INTERVAL '14 days', NOW()),
  -- Owner 9: Wanindu
  ('c1000011-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Outlander', 'Mitsubishi', 'https://www.carlogos.org/car-logos/mitsubishi-logo-2000.png', 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800', 9000.00, 7, 'Auto', 'Diesel', 4.5, 14, 'a2000009-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'EP MT-4444',  true,  'available', 'approved', 'Trincomalee', NOW() - INTERVAL '45 days', NOW()),
  ('c1000012-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Lancer',    'Mitsubishi', 'https://www.carlogos.org/car-logos/mitsubishi-logo-2000.png', 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=800', 4000.00, 5, 'Manual', 'Petrol', 4.0, 35, 'a2000009-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'EP MT-5555',  false, 'available', 'approved', 'Batticaloa',  NOW() - INTERVAL '40 days', NOW()),
  -- Owner 10: Pathum
  ('c1000013-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'A3',  'Audi', 'https://www.carlogos.org/car-logos/audi-logo-2016.png', 'https://images.unsplash.com/photo-1603584173870-7f23fdae1b7a?w=800', 16000.00, 5, 'Auto', 'Petrol', 4.7, 6,  'a200000a-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'WP AU-7777',  true,  'available', 'approved', 'Colombo', NOW() - INTERVAL '35 days', NOW()),
  ('c1000014-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Q5',  'Audi', 'https://www.carlogos.org/car-logos/audi-logo-2016.png', 'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=800', 25000.00, 5, 'Auto', 'Diesel', 4.8, 3,  'a200000a-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'WP AU-8888',  true,  'rented',    'approved', 'Colombo', NOW() - INTERVAL '30 days', NOW());

-- ============================================================
-- PAYMENTS (create first, then reference in bookings)
-- ============================================================
INSERT INTO payments (id, amount, status, gateway_ref, method, created_at, updated_at)
VALUES
  -- For completed bookings
  ('d1000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 15000.00,  'success', 'PH-2025-001234', 'PayHere', NOW() - INTERVAL '42 days', NOW() - INTERVAL '42 days'),
  ('d1000005-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 17500.00,  'success', 'PH-2025-005678', 'PayHere', NOW() - INTERVAL '37 days', NOW() - INTERVAL '37 days'),
  ('d1000006-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 18000.00,  'success', 'PH-2025-006789', 'Card',    NOW() - INTERVAL '18 days', NOW() - INTERVAL '18 days'),
  ('d1000008-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 40000.00,  'success', 'PH-2025-008901', 'PayHere', NOW() - INTERVAL '28 days', NOW() - INTERVAL '28 days'),
  ('d100000d-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 22500.00,  'success', 'PH-2025-013456', 'PayHere', NOW() - INTERVAL '32 days', NOW() - INTERVAL '32 days'),
  ('d100000f-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 11400.00,  'success', 'PH-2025-015678', 'Card',    NOW() - INTERVAL '20 days', NOW() - INTERVAL '20 days'),
  -- For active (paid) bookings
  ('d1000002-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 37500.00,  'success', 'PH-2025-002345', 'PayHere', NOW() - INTERVAL '5 days',  NOW() - INTERVAL '5 days'),
  ('d1000007-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 100000.00, 'success', 'PH-2025-007890', 'Card',    NOW() - INTERVAL '3 days',  NOW() - INTERVAL '3 days'),
  ('d100000e-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 150000.00, 'success', 'PH-2025-014567', 'PayHere', NOW() - INTERVAL '4 days',  NOW() - INTERVAL '4 days'),
  -- For confirmed booking
  ('d100000a-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 36000.00,  'success', 'PH-2025-010123', 'GPay',    NOW() - INTERVAL '2 days',  NOW() - INTERVAL '2 days'),
  -- Failed payment (cancelled booking)
  ('d1000009-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 54000.00,  'failed',  NULL,              'PayHere', NOW() - INTERVAL '12 days', NOW() - INTERVAL '10 days');

-- ============================================================
-- 15 BOOKINGS
-- ============================================================
INSERT INTO bookings (id, renter_id, vehicle_id, start_date, end_date, pickup_location, dropoff_location, flight_number, total_price, currency, status, payment_id, created_at, updated_at)
VALUES
  -- Renter 1 (Kamal): completed, paid(active), cancelled, pending
  ('e1000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'c1000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '40 days', NOW() - INTERVAL '37 days', 'Bandaranaike Airport', 'Colombo Fort',     'UL302', 15000.00, 'LKR', 'completed', 'd1000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '42 days', NOW() - INTERVAL '37 days'),
  ('e1000002-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'c1000004-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '2 days',  NOW() + INTERVAL '3 days',  'Kandy City Center',    'Kandy City Center', NULL,    37500.00, 'LKR', 'paid',      'd1000002-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '5 days',  NOW()),
  ('e1000003-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'c1000009-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '20 days', NOW() - INTERVAL '17 days', 'Colombo 07',           'Colombo 07',        NULL,    45000.00, 'LKR', 'cancelled', NULL,                                  NOW() - INTERVAL '22 days', NOW() - INTERVAL '20 days'),
  ('e1000004-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'c100000d-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() + INTERVAL '5 days',  NOW() + INTERVAL '8 days',  'Kandy Railway Station', 'Kandy Railway Station', NULL, 21000.00, 'LKR', 'pending',   NULL,                                  NOW() - INTERVAL '1 day',   NOW()),

  -- Renter 2 (Nimal): completed, completed, paid(active)
  ('e1000005-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000002-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'c1000005-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '35 days', NOW() - INTERVAL '30 days', 'Galle Fort',           'Galle Fort',        NULL,    17500.00, 'LKR', 'completed', 'd1000005-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '37 days', NOW() - INTERVAL '30 days'),
  ('e1000006-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000002-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'c1000003-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '15 days', NOW() - INTERVAL '12 days', 'Bandaranaike Airport', 'Mount Lavinia',     'SQ468', 18000.00, 'LKR', 'completed', 'd1000006-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '18 days', NOW() - INTERVAL '12 days'),
  ('e1000007-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000002-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'c100000a-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '1 day',   NOW() + INTERVAL '4 days',  'Colombo 03',           'Colombo 03',        NULL,    100000.00, 'LKR', 'paid',     'd1000007-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '3 days',  NOW()),

  -- Renter 3 (Saman): completed, cancelled, confirmed
  ('e1000008-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000003-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'c1000007-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '25 days', NOW() - INTERVAL '20 days', 'Colombo 07',           'Negombo Beach',     NULL,    40000.00, 'LKR', 'completed', 'd1000008-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '28 days', NOW() - INTERVAL '20 days'),
  ('e1000009-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000003-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'c100000b-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '10 days', NOW() - INTERVAL '7 days',  'Colombo 04',           'Colombo 04',        NULL,    54000.00, 'LKR', 'cancelled', 'd1000009-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '12 days', NOW() - INTERVAL '10 days'),
  ('e100000a-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000003-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'c1000011-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() + INTERVAL '10 days', NOW() + INTERVAL '14 days', 'Trincomalee Harbor',   'Trincomalee Harbor', NULL,   36000.00, 'LKR', 'confirmed', 'd100000a-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '2 days',  NOW()),

  -- Renter 4 (Ruwan): pending, cancelled
  ('e100000b-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000004-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'c1000013-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() + INTERVAL '7 days',  NOW() + INTERVAL '10 days', 'Colombo 02',           'Colombo 02',        NULL,    48000.00, 'LKR', 'pending',   NULL,                                  NOW(),                       NOW()),
  ('e100000c-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000004-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'c1000006-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '5 days',  NOW() - INTERVAL '3 days',  'Matara',               'Matara',            NULL,    5000.00,  'LKR', 'cancelled', NULL,                                  NOW() - INTERVAL '7 days',  NOW() - INTERVAL '5 days'),

  -- Renter 5 (Dilshan): completed, paid(active), completed
  ('e100000d-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000005-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'c1000002-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '30 days', NOW() - INTERVAL '25 days', 'Negombo',              'Negombo',           NULL,    22500.00, 'LKR', 'completed', 'd100000d-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '32 days', NOW() - INTERVAL '25 days'),
  ('e100000e-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000005-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'c1000014-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '1 day',   NOW() + INTERVAL '5 days',  'Colombo 05',           'Bandaranaike Airport', 'EK654', 150000.00, 'LKR', 'paid',   'd100000e-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '4 days',  NOW()),
  ('e100000f-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000005-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'c100000e-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '18 days', NOW() - INTERVAL '15 days', 'Nuwara Eliya',         'Nuwara Eliya',      NULL,    11400.00, 'LKR', 'completed', 'd100000f-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '20 days', NOW() - INTERVAL '15 days');

-- ============================================================
-- 15 FAVORITES
-- ============================================================
INSERT INTO favorites (id, user_id, vehicle_id, created_at)
VALUES
  -- Kamal: 4 favorites
  ('f1000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'c1000009-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '30 days'),
  ('f1000002-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'c100000b-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '25 days'),
  ('f1000003-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'c1000003-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '20 days'),
  ('f1000004-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'c1000013-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '10 days'),
  -- Nimal: 3 favorites
  ('f1000005-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000002-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'c1000007-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '28 days'),
  ('f1000006-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000002-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'c100000a-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '15 days'),
  ('f1000007-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000002-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'c1000014-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '5 days'),
  -- Saman: 3 favorites
  ('f1000008-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000003-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'c1000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '22 days'),
  ('f1000009-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000003-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'c1000005-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '18 days'),
  ('f100000a-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000003-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'c1000011-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '8 days'),
  -- Ruwan: 2 favorites
  ('f100000b-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000004-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'c1000013-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '5 days'),
  ('f100000c-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000004-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'c1000004-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '3 days'),
  -- Dilshan: 3 favorites
  ('f100000d-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000005-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'c1000002-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '25 days'),
  ('f100000e-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000005-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'c100000d-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '12 days'),
  ('f100000f-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000005-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'c100000b-aaaa-4aaa-8aaa-aaaaaaaaaaaa', NOW() - INTERVAL '6 days');

-- ============================================================
-- 42 CHAT MESSAGES
-- ============================================================
INSERT INTO chat_messages (id, sender_id, receiver_id, message, is_read, "timestamp")
VALUES
  -- Kamal <-> Chaminda (Toyota Corolla booking)
  ('aa000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a2000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Hi, is the Toyota Corolla available for airport pickup?', true, NOW() - INTERVAL '43 days'),
  ('aa000002-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a2000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Yes! I can pick you up from Bandaranaike Airport. What time is your flight?', true, NOW() - INTERVAL '43 days' + INTERVAL '10 minutes'),
  ('aa000003-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a2000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Flight UL302 lands at 3:30 PM. Can you be there by 4?', true, NOW() - INTERVAL '43 days' + INTERVAL '20 minutes'),
  ('aa000004-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a2000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Sure, I will be at the arrival terminal at 4 PM. Look for the white Corolla with CAB-1234 plates.', true, NOW() - INTERVAL '43 days' + INTERVAL '30 minutes'),
  ('aa000005-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a2000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Perfect, thanks! Booking confirmed.', true, NOW() - INTERVAL '43 days' + INTERVAL '35 minutes'),

  -- Kamal <-> Mahela (Honda Vezel - active)
  ('aa000006-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a2000002-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Hello, I want to rent the Honda Vezel for a trip to Kandy', true, NOW() - INTERVAL '6 days'),
  ('aa000007-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a2000002-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Hi Kamal! The Vezel is available. Great car for hill country. When do you need it?', true, NOW() - INTERVAL '6 days' + INTERVAL '15 minutes'),
  ('aa000008-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a2000002-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'From tomorrow for 5 days. Is the hybrid fuel efficient for Kandy roads?', true, NOW() - INTERVAL '6 days' + INTERVAL '25 minutes'),
  ('aa000009-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a2000002-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Absolutely! You will get around 20km/l even on mountain roads. I will keep it ready.', true, NOW() - INTERVAL '6 days' + INTERVAL '35 minutes'),
  ('aa00000a-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a2000002-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Great, just made the booking and payment!', true, NOW() - INTERVAL '5 days'),

  -- Nimal <-> Kumar (Suzuki Swift)
  ('aa00000b-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000002-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a2000003-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Is the Suzuki Swift available in Galle?', true, NOW() - INTERVAL '38 days'),
  ('aa00000c-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a2000003-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000002-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Yes, parked near Galle Fort. Very economical for city driving!', true, NOW() - INTERVAL '38 days' + INTERVAL '20 minutes'),
  ('aa00000d-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000002-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a2000003-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Perfect for my needs. I will book for 5 days.', true, NOW() - INTERVAL '38 days' + INTERVAL '30 minutes'),
  ('aa00000e-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a2000003-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000002-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Done! Keys will be at the Galle Fort parking lot. Enjoy!', true, NOW() - INTERVAL '38 days' + INTERVAL '45 minutes'),

  -- Nimal <-> Tillakaratne (BMW X5 - active)
  ('aa00000f-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000002-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a2000005-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Hi, interested in the BMW X5 for a special occasion', true, NOW() - INTERVAL '4 days'),
  ('aa000010-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a2000005-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000002-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Hello! The X5 is our premium SUV. Full leather, sunroof. Rs 20,000/day.', true, NOW() - INTERVAL '4 days' + INTERVAL '30 minutes'),
  ('aa000011-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000002-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a2000005-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'For 5 days starting tomorrow. It is for my wedding anniversary trip!', true, NOW() - INTERVAL '4 days' + INTERVAL '45 minutes'),
  ('aa000012-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a2000005-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000002-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Congratulations! I will make sure it is spotless. Booking confirmed after payment.', true, NOW() - INTERVAL '4 days' + INTERVAL '55 minutes'),
  ('aa000013-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000002-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a2000005-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Payment done! Thank you so much!', true, NOW() - INTERVAL '3 days'),

  -- Saman <-> Lasith (Nissan X-Trail)
  ('aa000014-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000003-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a2000004-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Need a 7-seater for a family trip. Is the X-Trail available?', true, NOW() - INTERVAL '29 days'),
  ('aa000015-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a2000004-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000003-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Yes! Perfect for families. Spacious boot too. When do you need it?', true, NOW() - INTERVAL '29 days' + INTERVAL '10 minutes'),
  ('aa000016-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000003-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a2000004-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '5 days from this weekend. Going to Negombo beach with the kids.', true, NOW() - INTERVAL '29 days' + INTERVAL '20 minutes'),
  ('aa000017-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a2000004-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000003-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Sounds fun! I will drop it off at Colombo 07. Book anytime!', true, NOW() - INTERVAL '29 days' + INTERVAL '30 minutes'),

  -- Saman <-> Wanindu (Outlander - future booking)
  ('aa000018-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000003-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a2000009-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Planning a trip to Trincomalee. Is the Outlander good for long drives?', false, NOW() - INTERVAL '3 days'),
  ('aa000019-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a2000009-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000003-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Absolutely! Diesel engine, great mileage. 7 seats too. When are you coming?', false, NOW() - INTERVAL '3 days' + INTERVAL '40 minutes'),
  ('aa00001a-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000003-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a2000009-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'In about 10 days, for 4 days. Just booked it!', false, NOW() - INTERVAL '2 days'),
  ('aa00001b-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a2000009-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000003-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'I can see the booking. Will have it ready at Trincomalee Harbor. Safe travels!', false, NOW() - INTERVAL '2 days' + INTERVAL '15 minutes'),

  -- Dilshan <-> Chaminda (Toyota Axio)
  ('aa00001c-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000005-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a2000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Is the Axio hybrid? How is the fuel economy?', true, NOW() - INTERVAL '33 days'),
  ('aa00001d-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a2000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000005-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Yes, full hybrid. You can expect 25-30km/l in the city. Very economical!', true, NOW() - INTERVAL '33 days' + INTERVAL '15 minutes'),
  ('aa00001e-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000005-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a2000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Great! Booking it for 5 days in Negombo.', true, NOW() - INTERVAL '33 days' + INTERVAL '25 minutes'),

  -- Dilshan <-> Pathum (Audi Q5 - active)
  ('aa00001f-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000005-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a200000a-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Hello! Is the Audi Q5 available? Need it for a business trip.', true, NOW() - INTERVAL '5 days'),
  ('aa000020-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a200000a-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000005-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Hi Dilshan! Yes, the Q5 is our top-tier SUV. Airport pickup included.', true, NOW() - INTERVAL '5 days' + INTERVAL '20 minutes'),
  ('aa000021-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000005-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a200000a-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Starting tomorrow for 6 days. Flying out on Emirates EK654.', true, NOW() - INTERVAL '5 days' + INTERVAL '30 minutes'),
  ('aa000022-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a200000a-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000005-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'I will deliver the Q5 to your location. Full tank, freshly detailed!', true, NOW() - INTERVAL '5 days' + INTERVAL '40 minutes'),
  ('aa000023-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000005-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a200000a-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Payment done. See you tomorrow!', true, NOW() - INTERVAL '4 days'),

  -- Ruwan <-> Pathum (Audi A3 - pending)
  ('aa000024-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000004-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a200000a-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Hi, I see the Audi A3 is available. What is the condition?', false, NOW() - INTERVAL '1 day'),
  ('aa000025-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a200000a-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000004-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Mint condition! 2023 model, full service history. Only 15,000 km.', false, NOW() - INTERVAL '1 day' + INTERVAL '30 minutes'),
  ('aa000026-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000004-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a200000a-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Looks great! Created a booking for next week. Will pay soon.', false, NOW() - INTERVAL '12 hours'),

  -- Kamal <-> Dimuth (Tucson - pending)
  ('aa000027-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a2000007-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Hi Dimuth, is the Tucson still available for next week?', false, NOW() - INTERVAL '2 days'),
  ('aa000028-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a2000007-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Yes it is! Just finished servicing it. Ready to go anytime.', false, NOW() - INTERVAL '2 days' + INTERVAL '20 minutes'),
  ('aa000029-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a2000007-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Just created a booking. Can you arrange Kandy Railway Station pickup?', false, NOW() - INTERVAL '1 day'),
  ('aa00002a-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a2000007-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a1000001-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'Absolutely! I will be there. Confirm the payment and we are all set.', false, NOW() - INTERVAL '1 day' + INTERVAL '15 minutes');

COMMIT;

-- ============================================================
-- SUMMARY
-- ============================================================
-- 5 Renters (login phones):
--   Kamal Perera       +94771000001
--   Nimal Silva        +94771000002
--   Saman Fernando     +94771000003
--   Ruwan Jayasekara   +94771000004
--   Dilshan Rajapaksa  +94771000005
--
-- 10 Owners (login phones):
--   Chaminda Vaas         +94772000001
--   Mahela Jayawardena    +94772000002
--   Kumar Sangakkara      +94772000003
--   Lasith Malinga        +94772000004
--   Tillakaratne Dilshan  +94772000005
--   Angelo Mathews        +94772000006
--   Dimuth Karunaratne    +94772000007
--   Dhananjaya de Silva   +94772000008 (pending verification)
--   Wanindu Hasaranga     +94772000009
--   Pathum Nissanka       +94772000010
--
-- 20 Vehicles (2 per owner, mix of brands/types/statuses)
-- 15 Bookings: 6 completed, 3 paid(active), 2 pending, 1 confirmed, 3 cancelled
-- 11 Payments: 10 success, 1 failed
-- 15 Favorites across all renters
-- 42 Chat Messages (realistic conversations)
