-- Create Schema
CREATE SCHEMA IF NOT EXISTS mera;

-- Create Enums in 'mera' schema if they don't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'box_tier' AND typnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'mera')) THEN
        CREATE TYPE mera.box_tier AS ENUM ('Essential', 'Comfort', 'Eco');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'subscription_status' AND typnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'mera')) THEN
        CREATE TYPE mera.subscription_status AS ENUM ('Active', 'Paused', 'Cancelled');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'order_status' AND typnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'mera')) THEN
        CREATE TYPE mera.order_status AS ENUM ('Pending', 'Paid', 'Dispatched');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'item_category' AND typnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'mera')) THEN
        CREATE TYPE mera.item_category AS ENUM ('Pads', 'Meds', 'Treats');
    END IF;
END
$$;

-- Profiles Table
CREATE TABLE IF NOT EXISTS mera.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    whatsapp_id TEXT UNIQUE NOT NULL,
    full_name TEXT,
    address TEXT,
    country_code TEXT NOT NULL, -- 'GH', 'NG', 'KE'
    timezone TEXT DEFAULT 'UTC',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Subscriptions Table
CREATE TABLE IF NOT EXISTS mera.subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES mera.profiles(id) ON DELETE CASCADE,
    box_tier mera.box_tier NOT NULL DEFAULT 'Essential',
    last_period_date DATE NOT NULL,
    cycle_length INTEGER NOT NULL DEFAULT 28,
    next_period_date DATE NOT NULL, -- Calculated based on last_period_date + cycle_length
    status mera.subscription_status NOT NULL DEFAULT 'Active',
    country_code TEXT NOT NULL,
    currency TEXT NOT NULL, -- 'GHS', 'NGN', 'KES'
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Inventory Table
CREATE TABLE IF NOT EXISTS mera.inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    category mera.item_category NOT NULL,
    price DECIMAL(12, 2) NOT NULL,
    currency TEXT NOT NULL,
    stock_level INTEGER NOT NULL DEFAULT 0,
    country_code TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Orders Table
CREATE TABLE IF NOT EXISTS mera.orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscription_id UUID REFERENCES mera.subscriptions(id) ON DELETE SET NULL,
    user_id UUID NOT NULL REFERENCES mera.profiles(id) ON DELETE CASCADE,
    paystack_reference TEXT UNIQUE,
    status mera.order_status NOT NULL DEFAULT 'Pending',
    total_amount DECIMAL(12, 2) NOT NULL,
    currency TEXT NOT NULL,
    is_discreet_packaging BOOLEAN NOT NULL DEFAULT TRUE,
    country_code TEXT NOT NULL,
    scheduled_for_date DATE NOT NULL, -- The date this order was triggered by the cycle
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Order Items (Linking orders to specific items for fulfillment)
CREATE TABLE IF NOT EXISTS mera.order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES mera.orders(id) ON DELETE CASCADE,
    inventory_id UUID NOT NULL REFERENCES mera.inventory(id),
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(12, 2) NOT NULL
);

-- RLS Policies (Basic Multi-tenant enforcement)
ALTER TABLE mera.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE mera.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE mera.inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE mera.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE mera.order_items ENABLE ROW LEVEL SECURITY;

-- Profiles: Users can only see/edit their own profile
DROP POLICY IF EXISTS "Users can view own profile" ON mera.profiles;
CREATE POLICY "Users can view own profile" ON mera.profiles
    FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON mera.profiles;
CREATE POLICY "Users can update own profile" ON mera.profiles
    FOR UPDATE USING (auth.uid() = id);

-- Subscriptions: Users can only see/edit their own subscriptions
DROP POLICY IF EXISTS "Users can view own subscriptions" ON mera.subscriptions;
CREATE POLICY "Users can view own subscriptions" ON mera.subscriptions
    FOR SELECT USING (auth.uid() = user_id);

-- Orders: Users can only see their own orders
DROP POLICY IF EXISTS "Users can view own orders" ON mera.orders;
CREATE POLICY "Users can view own orders" ON mera.orders
    FOR SELECT USING (auth.uid() = user_id);

-- Inventory: All authenticated users can view inventory for their country
DROP POLICY IF EXISTS "Users can view inventory in their country" ON mera.inventory;
CREATE POLICY "Users can view inventory in their country" ON mera.inventory
    FOR SELECT USING (true); -- Filter by country_code in application logic or add more complex RLS

-- Functions & Triggers
-- Function to automatically calculate next_period_date
CREATE OR REPLACE FUNCTION mera.calculate_next_period_date()
RETURNS TRIGGER AS $$
BEGIN
    NEW.next_period_date := NEW.last_period_date + (NEW.cycle_length * INTERVAL '1 day');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_calculate_next_period_date ON mera.subscriptions;
CREATE TRIGGER trigger_calculate_next_period_date
BEFORE INSERT OR UPDATE OF last_period_date, cycle_length
ON mera.subscriptions
FOR EACH ROW
EXECUTE FUNCTION mera.calculate_next_period_date();
