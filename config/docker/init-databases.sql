-- =============================================================================
-- Netsurf Stack - Database Initialization
-- =============================================================================
-- This script runs on first PostgreSQL start to create separate databases
-- for each service and automation tables.
-- =============================================================================

-- Create databases for each service
CREATE DATABASE n8n;
CREATE DATABASE directus;
CREATE DATABASE chatwoot;

-- Grant all privileges to the main user
GRANT ALL PRIVILEGES ON DATABASE n8n TO netsurf;
GRANT ALL PRIVILEGES ON DATABASE directus TO netsurf;
GRANT ALL PRIVILEGES ON DATABASE chatwoot TO netsurf;

-- =============================================================================
-- Automation Tables (in default netsurf database)
-- =============================================================================

-- Leads table for WhatsApp and web captures
CREATE TABLE IF NOT EXISTS leads (
    id SERIAL PRIMARY KEY,
    phone VARCHAR(20),
    name VARCHAR(255),
    email VARCHAR(255),
    message TEXT,
    business VARCHAR(50) DEFAULT 'general',
    priority VARCHAR(20) DEFAULT 'normal',
    source VARCHAR(50) DEFAULT 'web',
    status VARCHAR(20) DEFAULT 'new',
    assigned_to VARCHAR(255),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_leads_business ON leads(business);
CREATE INDEX IF NOT EXISTS idx_leads_created ON leads(created_at);

-- Bookings table for Nature Park
CREATE TABLE IF NOT EXISTS bookings (
    id SERIAL PRIMARY KEY,
    reference VARCHAR(20) UNIQUE NOT NULL,
    customer_name VARCHAR(255) NOT NULL,
    customer_phone VARCHAR(20) NOT NULL,
    customer_email VARCHAR(255),
    package_type VARCHAR(50) NOT NULL,
    check_in DATE NOT NULL,
    check_out DATE,
    nights INTEGER DEFAULT 1,
    guests INTEGER DEFAULT 1,
    total_gyd DECIMAL(10, 2),
    status VARCHAR(20) DEFAULT 'pending',
    special_requests TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_bookings_checkin ON bookings(check_in);

-- Ticket analytics for Chatwoot
CREATE TABLE IF NOT EXISTS ticket_analytics (
    id SERIAL PRIMARY KEY,
    conversation_id INTEGER NOT NULL,
    categories VARCHAR(255),
    priority VARCHAR(20),
    auto_responded BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Daily reports archive
CREATE TABLE IF NOT EXISTS daily_reports (
    id SERIAL PRIMARY KEY,
    report_date DATE UNIQUE NOT NULL,
    leads_total INTEGER DEFAULT 0,
    bookings_total INTEGER DEFAULT 0,
    revenue_gyd DECIMAL(12, 2) DEFAULT 0,
    tickets_total INTEGER DEFAULT 0,
    report_content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products catalog
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    sku VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(50) NOT NULL,
    description TEXT,
    price_gyd DECIMAL(12, 2),
    stock_quantity INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    specifications JSONB
);

-- Insert default products
INSERT INTO products (sku, name, category, price_gyd, stock_quantity, specifications) VALUES
('SOL-PANEL-100W', '100W Solar Panel', 'solar', 35000, 20, '{"watts": 100}'),
('SOL-PANEL-250W', '250W Solar Panel', 'solar', 75000, 15, '{"watts": 250}'),
('SOL-BATT-100AH', '100Ah Lithium Battery', 'battery', 180000, 10, '{"capacity_ah": 100}'),
('SOL-INV-3KW', '3KW Hybrid Inverter', 'inverter', 250000, 8, '{"power_kw": 3}'),
('SOL-INV-5KW', '5KW Hybrid Inverter', 'inverter', 380000, 5, '{"power_kw": 5}'),
('STAR-KIT-STD', 'Starlink Standard Kit', 'starlink', 450000, 3, '{"type": "standard"}'),
('STAR-INST', 'Starlink Installation', 'service', 25000, 999, '{"type": "service"}')
ON CONFLICT (sku) DO NOTHING;

-- Business info
CREATE TABLE IF NOT EXISTS business_info (
    id SERIAL PRIMARY KEY,
    business_code VARCHAR(50) UNIQUE NOT NULL,
    business_name VARCHAR(255) NOT NULL,
    phone_numbers JSONB,
    address TEXT,
    hours JSONB
);

INSERT INTO business_info (business_code, business_name, phone_numbers, address, hours) VALUES
('netsurf_power', 'Netsurf Power', '["592-644-6840", "592-611-9443"]', '56 Chalmers Place, Georgetown', '{"weekdays": "8:00-17:00"}'),
('netsurf_nature_park', 'Netsurf Nature Park', '["592-611-9443", "592-621-8271"]', 'Linden Highway', '{"daily": "7:00-18:00"}')
ON CONFLICT (business_code) DO NOTHING;

-- Log completion
DO $$
BEGIN
    RAISE NOTICE 'Netsurf databases and automation tables created successfully';
END $$;
