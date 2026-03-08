-- Make profiles flexible for onboarding before auth
-- This allows us to create a profile with just a WhatsApp ID before the user signs up for an admin/customer account

-- 1. Drop the constraint that forces ID to be a FK to auth.users (if it exists)
-- This is a bit tricky if we don't know the constraint name, but usually it's 'profiles_id_fkey'
ALTER TABLE mera.profiles DROP CONSTRAINT IF EXISTS profiles_id_fkey;

-- 2. Add a separate column for the Auth link, and make ID auto-generate
ALTER TABLE mera.profiles 
    ALTER COLUMN id SET DEFAULT gen_random_uuid(),
    ADD COLUMN IF NOT EXISTS auth_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL;

-- 3. Ensure whatsapp_id is still unique so we can upsert by it
-- (Already exists, but adding a comment/check)
COMMENT ON COLUMN mera.profiles.whatsapp_id IS 'Primary identifier for WhatsApp-led onboarding.';

-- 4. Update RLS policies to allow anonymous inserts for the subscribe page
DROP POLICY IF EXISTS "Enable insert for onboarding" ON mera.profiles;
CREATE POLICY "Enable insert for onboarding" ON mera.profiles
    FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Enable anon select for own profile check" ON mera.profiles;
CREATE POLICY "Enable anon select for own profile check" ON mera.profiles
    FOR SELECT USING (true);

-- 5. Subscriptions: Enable same for the subscription record itself
DROP POLICY IF EXISTS "Enable insert for onboarding sub" ON mera.subscriptions;
CREATE POLICY "Enable insert for onboarding sub" ON mera.subscriptions
    FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Enable anon select for sub check" ON mera.subscriptions;
CREATE POLICY "Enable anon select for sub check" ON mera.subscriptions
    FOR SELECT USING (true);
