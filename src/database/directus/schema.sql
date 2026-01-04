-- =============================================================================
-- Netsurf Group - Multi-Business Database Schema
-- =============================================================================
-- Supports: Netsurf WISP, Netsurf Power, Netsurf Nature Park
--
-- Usage:
--   docker compose exec postgres psql -U netsurf -d directus < directus/schema.sql
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Business Info (Unified across all businesses)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS business_info (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    business VARCHAR(50) NOT NULL,  -- 'wisp', 'power', 'park'
    key VARCHAR(100) NOT NULL,
    value TEXT NOT NULL,
    description VARCHAR(255),
    date_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(business, key)
);

INSERT INTO directus_collections (collection, icon, note, hidden, singleton, accountability)
VALUES ('business_info', 'business', 'Business information for all Netsurf companies', false, false, 'all')
ON CONFLICT (collection) DO NOTHING;

-- -----------------------------------------------------------------------------
-- WISP - Internet Plans
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS wisp_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    status VARCHAR(50) DEFAULT 'active',
    sort INTEGER,
    date_created TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    date_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    name VARCHAR(255) NOT NULL,
    speed_mbps INTEGER NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'GYD',
    description TEXT,
    features JSONB DEFAULT '[]',
    plan_type VARCHAR(50) DEFAULT 'residential'  -- residential, business, enterprise
);

INSERT INTO directus_collections (collection, icon, note, hidden, singleton, accountability)
VALUES ('wisp_plans', 'wifi', 'Netsurf WISP internet plans', false, false, 'all')
ON CONFLICT (collection) DO NOTHING;

-- -----------------------------------------------------------------------------
-- WISP - FAQ
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS wisp_faq (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    status VARCHAR(50) DEFAULT 'published',
    sort INTEGER,
    date_created TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    date_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    question VARCHAR(500) NOT NULL,
    answer TEXT NOT NULL,
    keywords JSONB DEFAULT '[]'
);

INSERT INTO directus_collections (collection, icon, note, hidden, singleton, accountability)
VALUES ('wisp_faq', 'help', 'FAQ for Netsurf internet service', false, false, 'all')
ON CONFLICT (collection) DO NOTHING;

-- -----------------------------------------------------------------------------
-- Power - Products
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS power_products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    status VARCHAR(50) DEFAULT 'active',
    sort INTEGER,
    date_created TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    date_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100),  -- panels, batteries, inverters, cameras, starlink
    price DECIMAL(10,2),
    currency VARCHAR(10) DEFAULT 'GYD',
    description TEXT,
    features JSONB DEFAULT '[]',
    image UUID  -- Reference to directus_files
);

INSERT INTO directus_collections (collection, icon, note, hidden, singleton, accountability)
VALUES ('power_products', 'solar_power', 'Netsurf Power solar products', false, false, 'all')
ON CONFLICT (collection) DO NOTHING;

-- -----------------------------------------------------------------------------
-- Power - Services
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS power_services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    status VARCHAR(50) DEFAULT 'active',
    sort INTEGER,
    date_created TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    date_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price_type VARCHAR(50),  -- fixed, quote, starting_from
    price_range VARCHAR(255),
    features JSONB DEFAULT '[]'
);

INSERT INTO directus_collections (collection, icon, note, hidden, singleton, accountability)
VALUES ('power_services', 'handyman', 'Netsurf Power installation services', false, false, 'all')
ON CONFLICT (collection) DO NOTHING;

-- -----------------------------------------------------------------------------
-- Power - FAQ
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS power_faq (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    status VARCHAR(50) DEFAULT 'published',
    sort INTEGER,
    date_created TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    date_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    question VARCHAR(500) NOT NULL,
    answer TEXT NOT NULL,
    keywords JSONB DEFAULT '[]'
);

INSERT INTO directus_collections (collection, icon, note, hidden, singleton, accountability)
VALUES ('power_faq', 'help', 'FAQ for Netsurf Power solar services', false, false, 'all')
ON CONFLICT (collection) DO NOTHING;

-- -----------------------------------------------------------------------------
-- Nature Park - Accommodations
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS park_accommodations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    status VARCHAR(50) DEFAULT 'active',
    sort INTEGER,
    date_created TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    date_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    name VARCHAR(255) NOT NULL,
    capacity INTEGER,
    price_day DECIMAL(10,2),
    price_overnight DECIMAL(10,2),
    currency VARCHAR(10) DEFAULT 'GYD',
    description TEXT,
    amenities JSONB DEFAULT '[]',
    images JSONB DEFAULT '[]'  -- Array of image references
);

INSERT INTO directus_collections (collection, icon, note, hidden, singleton, accountability)
VALUES ('park_accommodations', 'cabin', 'Netsurf Nature Park cabins and camping', false, false, 'all')
ON CONFLICT (collection) DO NOTHING;

-- -----------------------------------------------------------------------------
-- Nature Park - Activities
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS park_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    status VARCHAR(50) DEFAULT 'active',
    sort INTEGER,
    date_created TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    date_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    name VARCHAR(255) NOT NULL,
    description TEXT,
    included BOOLEAN DEFAULT true,  -- Included in entry fee?
    additional_cost VARCHAR(255),
    duration VARCHAR(100)
);

INSERT INTO directus_collections (collection, icon, note, hidden, singleton, accountability)
VALUES ('park_activities', 'hiking', 'Activities at Netsurf Nature Park', false, false, 'all')
ON CONFLICT (collection) DO NOTHING;

-- -----------------------------------------------------------------------------
-- Nature Park - FAQ
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS park_faq (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    status VARCHAR(50) DEFAULT 'published',
    sort INTEGER,
    date_created TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    date_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    question VARCHAR(500) NOT NULL,
    answer TEXT NOT NULL,
    keywords JSONB DEFAULT '[]'
);

INSERT INTO directus_collections (collection, icon, note, hidden, singleton, accountability)
VALUES ('park_faq', 'help', 'FAQ for Netsurf Nature Park', false, false, 'all')
ON CONFLICT (collection) DO NOTHING;

-- -----------------------------------------------------------------------------
-- Promotions (All Businesses)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS promotions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    status VARCHAR(50) DEFAULT 'draft',
    date_created TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    date_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    business VARCHAR(50) NOT NULL,  -- 'wisp', 'power', 'park', 'all'
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    discount_percent INTEGER,
    discount_amount DECIMAL(10,2),
    promo_code VARCHAR(50),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    auto_post BOOLEAN DEFAULT false,
    terms TEXT,
    image UUID  -- Reference to directus_files
);

INSERT INTO directus_collections (collection, icon, note, hidden, singleton, accountability)
VALUES ('promotions', 'local_offer', 'Promotions for all Netsurf businesses', false, false, 'all')
ON CONFLICT (collection) DO NOTHING;

-- -----------------------------------------------------------------------------
-- Conversation Logs (Written by n8n)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS conversation_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    business VARCHAR(50),  -- Which business this was for
    conversation_id INTEGER,
    contact_id INTEGER,
    channel VARCHAR(50),
    customer_message TEXT,
    ai_response TEXT,
    escalated BOOLEAN DEFAULT false,
    escalation_reason VARCHAR(255),
    feedback VARCHAR(50),
    staff_notes TEXT
);

INSERT INTO directus_collections (collection, icon, note, hidden, singleton, accountability)
VALUES ('conversation_logs', 'chat', 'AI conversation logs for QA', false, false, 'all')
ON CONFLICT (collection) DO NOTHING;

-- -----------------------------------------------------------------------------
-- Social Post Logs (Written by n8n)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS social_post_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    posted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    business VARCHAR(50),
    promo_id UUID REFERENCES promotions(id),
    promo_title VARCHAR(255),
    facebook_status VARCHAR(50),
    facebook_post_id VARCHAR(255),
    instagram_status VARCHAR(50),
    instagram_post_id VARCHAR(255),
    tiktok_status VARCHAR(50),
    tiktok_caption TEXT
);

INSERT INTO directus_collections (collection, icon, note, hidden, singleton, accountability)
VALUES ('social_post_logs', 'share', 'Social media posting history', false, false, 'all')
ON CONFLICT (collection) DO NOTHING;

-- -----------------------------------------------------------------------------
-- System Controls (Staff-Controllable Kill Switches) - SINGLETON
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS system_controls (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    date_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Master Controls
    bot_enabled BOOLEAN DEFAULT true,              -- Kill switch for all AI responses
    emergency_mode BOOLEAN DEFAULT false,          -- Override all AI with emergency message
    emergency_message TEXT DEFAULT 'We are currently experiencing technical difficulties. A team member will respond shortly.',
    
    -- Per-Business Controls
    wisp_bot_enabled BOOLEAN DEFAULT true,
    power_bot_enabled BOOLEAN DEFAULT true,
    park_bot_enabled BOOLEAN DEFAULT true,
    
    -- Response Settings
    confidence_threshold DECIMAL(3,2) DEFAULT 0.75,  -- Min confidence for AI response
    max_turns_before_escalate INTEGER DEFAULT 6,     -- Force escalation after X turns
    
    -- Promo Mode
    promo_mode BOOLEAN DEFAULT false,
    promo_footer_message TEXT DEFAULT 'Ask about our current promotions!'
);

INSERT INTO directus_collections (collection, icon, note, hidden, singleton, accountability)
VALUES ('system_controls', 'settings', 'Bot kill switches and system settings (SINGLETON)', false, true, 'all')
ON CONFLICT (collection) DO NOTHING;

-- Insert default row
INSERT INTO system_controls (id) VALUES (gen_random_uuid()) ON CONFLICT DO NOTHING;

-- -----------------------------------------------------------------------------
-- Decision Rules (Staff-Defined Business Logic)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS decision_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    status VARCHAR(50) DEFAULT 'active',
    sort INTEGER,
    date_created TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    date_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    business VARCHAR(50),                    -- 'wisp', 'power', 'park', 'all'
    rule_type VARCHAR(100) NOT NULL,         -- 'upsell', 'promo_priority', 'topic_block', 'auto_response'
    name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Condition
    trigger_keywords JSONB DEFAULT '[]',     -- Keywords that activate this rule
    trigger_plan VARCHAR(255),               -- For upsell: current plan
    
    -- Action
    action_type VARCHAR(100),                -- 'suggest_plan', 'show_promo', 'block_topic', 'fixed_response'
    action_value TEXT,                       -- The plan to suggest, promo to show, or response text
    
    -- Priority (higher = checked first)
    priority INTEGER DEFAULT 0
);

INSERT INTO directus_collections (collection, icon, note, hidden, singleton, accountability)
VALUES ('decision_rules', 'rule', 'Business rules staff can configure without developer', false, false, 'all')
ON CONFLICT (collection) DO NOTHING;

-- -----------------------------------------------------------------------------
-- Daily Metrics (Auto-populated by n8n)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS daily_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    date DATE NOT NULL UNIQUE,
    
    -- Volume
    total_conversations INTEGER DEFAULT 0,
    wisp_conversations INTEGER DEFAULT 0,
    power_conversations INTEGER DEFAULT 0,
    park_conversations INTEGER DEFAULT 0,
    
    -- AI Performance
    ai_resolved INTEGER DEFAULT 0,           -- AI handled without escalation
    ai_escalated INTEGER DEFAULT 0,          -- AI escalated to human
    ai_resolution_rate DECIMAL(5,2),         -- Percentage
    
    -- Response Quality
    avg_response_time_seconds INTEGER,
    avg_confidence_score DECIMAL(3,2),
    low_confidence_count INTEGER DEFAULT 0,  -- Below threshold
    
    -- Top Issues (JSON array)
    top_unanswered_questions JSONB DEFAULT '[]',
    top_escalation_reasons JSONB DEFAULT '[]',
    
    -- Business
    sales_inquiries INTEGER DEFAULT 0,
    support_inquiries INTEGER DEFAULT 0,
    booking_inquiries INTEGER DEFAULT 0
);

INSERT INTO directus_collections (collection, icon, note, hidden, singleton, accountability)
VALUES ('daily_metrics', 'analytics', 'Daily performance metrics (auto-populated)', false, false, 'all')
ON CONFLICT (collection) DO NOTHING;

-- -----------------------------------------------------------------------------
-- Customer Tags (Lightweight Memory)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS customer_tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    date_created TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    date_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    chatwoot_contact_id INTEGER NOT NULL,
    business VARCHAR(50),
    
    -- Tags (staff or AI assigned)
    tags JSONB DEFAULT '[]',                 -- ['interested_in_upgrade', 'price_sensitive', 'coverage_issue']
    
    -- Context
    current_plan VARCHAR(255),
    area VARCHAR(255),
    notes TEXT,
    
    -- Follow-up
    needs_callback BOOLEAN DEFAULT false,
    callback_reason TEXT,
    
    UNIQUE(chatwoot_contact_id, business)
);

INSERT INTO directus_collections (collection, icon, note, hidden, singleton, accountability)
VALUES ('customer_tags', 'label', 'Lightweight customer memory tags', false, false, 'all')
ON CONFLICT (collection) DO NOTHING;

-- -----------------------------------------------------------------------------
-- Indexes
-- -----------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_business_info_business ON business_info(business);
CREATE INDEX IF NOT EXISTS idx_wisp_plans_status ON wisp_plans(status);
CREATE INDEX IF NOT EXISTS idx_power_products_category ON power_products(category);
CREATE INDEX IF NOT EXISTS idx_park_accommodations_status ON park_accommodations(status);
CREATE INDEX IF NOT EXISTS idx_promotions_business ON promotions(business);
CREATE INDEX IF NOT EXISTS idx_promotions_dates ON promotions(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_conversation_logs_business ON conversation_logs(business);
CREATE INDEX IF NOT EXISTS idx_conversation_logs_timestamp ON conversation_logs(timestamp);
CREATE INDEX IF NOT EXISTS idx_decision_rules_business ON decision_rules(business);
CREATE INDEX IF NOT EXISTS idx_decision_rules_status ON decision_rules(status);
CREATE INDEX IF NOT EXISTS idx_decision_rules_priority ON decision_rules(priority DESC);
CREATE INDEX IF NOT EXISTS idx_customer_tags_contact ON customer_tags(chatwoot_contact_id);
CREATE INDEX IF NOT EXISTS idx_daily_metrics_date ON daily_metrics(date DESC);

-- -----------------------------------------------------------------------------
-- Done
-- -----------------------------------------------------------------------------
DO $$
BEGIN
    RAISE NOTICE 'Netsurf Group multi-business schema created!';
    RAISE NOTICE 'Tables: business_info, wisp_plans, wisp_faq, power_products, power_services, power_faq, park_accommodations, park_activities, park_faq, promotions, conversation_logs, social_post_logs';
END $$;
