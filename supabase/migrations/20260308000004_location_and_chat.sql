-- Add Google Maps and Internal Notes to Profiles
ALTER TABLE mera.profiles 
ADD COLUMN IF NOT EXISTS google_maps_link TEXT,
ADD COLUMN IF NOT EXISTS internal_notes TEXT;

-- Create a table for WhatsApp Messages if we want to store them for a dashboard chat
CREATE TABLE IF NOT EXISTS mera.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    whatsapp_id TEXT NOT NULL,
    direction TEXT NOT NULL, -- 'INBOUND' (from user) or 'OUTBOUND' (from admin)
    content TEXT NOT NULL,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE mera.messages ENABLE ROW LEVEL SECURITY;

-- Admins can see all messages
DROP POLICY IF EXISTS "Admins can view messages" ON mera.messages;
CREATE POLICY "Admins can view messages" ON mera.messages
    FOR SELECT USING (auth.jwt() ->> 'role' = 'service_role');
