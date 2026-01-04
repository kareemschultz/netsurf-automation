-- =============================================================================
-- Netsurf Stack - Database Initialization
-- =============================================================================
-- This script runs on first PostgreSQL start to create separate databases
-- for each service. Each service gets its own isolated database.
-- =============================================================================

-- Create databases for each service
CREATE DATABASE n8n;
CREATE DATABASE directus;
CREATE DATABASE chatwoot;

-- Grant all privileges to the main user
GRANT ALL PRIVILEGES ON DATABASE n8n TO netsurf;
GRANT ALL PRIVILEGES ON DATABASE directus TO netsurf;
GRANT ALL PRIVILEGES ON DATABASE chatwoot TO netsurf;

-- Log completion
DO $$
BEGIN
    RAISE NOTICE 'Netsurf databases created successfully: n8n, directus, chatwoot';
END $$;
