-- Update RLS for Messages table
-- Allow authenticated users (Admins) to insert and view messages

-- 1. Selection policy for Admins (using standard auth check)
DROP POLICY IF EXISTS "Admins can view messages" ON mera.messages;
CREATE POLICY "Admins can view messages" ON mera.messages
    FOR SELECT TO authenticated USING (true);

-- 2. Insertion policy for Admins
DROP POLICY IF EXISTS "Admins can send messages" ON mera.messages;
CREATE POLICY "Admins can send messages" ON mera.messages
    FOR INSERT TO authenticated WITH CHECK (true);

-- 3. Service role bypass (explicitly allow everything for service role just in case)
DROP POLICY IF EXISTS "Service role bypass" ON mera.messages;
CREATE POLICY "Service role bypass" ON mera.messages
    FOR ALL TO service_role USING (true) WITH CHECK (true);
