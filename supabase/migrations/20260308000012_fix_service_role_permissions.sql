-- Ensure the service_role and other internal roles have full access to the 'mera' schema
-- This is often required for custom schemas even when using the service_role key

-- 1. Grant Usage
GRANT USAGE ON SCHEMA mera TO service_role;
GRANT USAGE ON SCHEMA mera TO postgres;
GRANT USAGE ON SCHEMA mera TO dashboard_user;

-- 2. Grant Table Access
GRANT ALL ON ALL TABLES IN SCHEMA mera TO service_role;
GRANT ALL ON ALL TABLES IN SCHEMA mera TO postgres;
GRANT ALL ON ALL TABLES IN SCHEMA mera TO dashboard_user;

-- 3. Grant Sequence Access (for IDs)
GRANT ALL ON ALL SEQUENCES IN SCHEMA mera TO service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA mera TO postgres;
GRANT ALL ON ALL SEQUENCES IN SCHEMA mera TO dashboard_user;

-- 4. Set Default Privileges for future items
ALTER DEFAULT PRIVILEGES IN SCHEMA mera GRANT ALL ON TABLES TO service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA mera GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES IN SCHEMA mera GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA mera GRANT ALL ON TABLES TO anon;
