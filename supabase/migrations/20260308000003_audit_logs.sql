-- Audit Logs for Health Data Access
CREATE TABLE IF NOT EXISTS mera.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id UUID REFERENCES auth.users(id),
    action TEXT NOT NULL, -- e.g., 'READ_SUBSCRIPTION_HEALTH', 'UPDATE_CYCLE'
    target_id UUID, -- ID of the subscription or profile accessed
    metadata JSONB, -- Additional details (IP, User Agent, etc.)
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on audit logs
ALTER TABLE mera.audit_logs ENABLE ROW LEVEL SECURITY;

-- Only admins should see audit logs (assuming a role or specific UID for simplicity here)
DROP POLICY IF EXISTS "Admins can view audit logs" ON mera.audit_logs;
CREATE POLICY "Admins can view audit logs" ON mera.audit_logs
    FOR SELECT USING (auth.jwt() ->> 'role' = 'service_role');

-- Add a column for encrypted health data if we were using pg_sodium (demo purposes)
-- ALTER TABLE mera.subscriptions ADD COLUMN encrypted_notes TEXT;
-- COMMENT ON COLUMN mera.subscriptions.encrypted_notes IS 'Encrypted using pg_sodium for GDPR compliance.';
