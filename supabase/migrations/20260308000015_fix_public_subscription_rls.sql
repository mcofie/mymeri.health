-- Refactor Profiles to support non-auth users (leads)
-- 1. Drop the direct reference to auth.users on the primary key
ALTER TABLE mera.profiles DROP CONSTRAINT IF EXISTS profiles_id_fkey;

-- 2. Ensure ID is auto-generated
ALTER TABLE mera.profiles ALTER COLUMN id SET DEFAULT gen_random_uuid();

-- 3. Add an optional column for the linked Auth User (for when they eventually sign up)
ALTER TABLE mera.profiles ADD COLUMN IF NOT EXISTS auth_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL;

-- 4. Relax RLS permissions for anonymous subscription flow
DROP POLICY IF EXISTS "Public can insert profiles" ON mera.profiles;
CREATE POLICY "Public can insert profiles" ON mera.profiles FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Public can select all profiles" ON mera.profiles;
CREATE POLICY "Public can select all profiles" ON mera.profiles FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public can update all profiles" ON mera.profiles;
CREATE POLICY "Public can update all profiles" ON mera.profiles FOR UPDATE USING (true);

-- 5. Subscriptions: Allow anyone to create a subscription
DROP POLICY IF EXISTS "Anyone can create subscription" ON mera.subscriptions;
CREATE POLICY "Anyone can create subscription" ON mera.subscriptions FOR INSERT WITH CHECK (true);

-- 6. Subscriptions: Allow public viewing for confirmation
DROP POLICY IF EXISTS "Public can view own subscriptions" ON mera.subscriptions;
CREATE POLICY "Public can view own subscriptions" ON mera.subscriptions FOR SELECT USING (true);
