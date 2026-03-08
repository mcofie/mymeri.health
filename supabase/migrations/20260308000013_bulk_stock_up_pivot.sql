-- Support Bulk "Stock-Up" Business Model
-- 1. Add billing_cycle and custom alert buffers
ALTER TYPE mera.subscription_status ADD VALUE IF NOT EXISTS 'Paused';

-- Create billing_cycle enum if not exists
DO $$ BEGIN
    CREATE TYPE mera.billing_cycle AS ENUM ('Monthly', 'Quarterly');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

ALTER TABLE mera.subscriptions 
ADD COLUMN IF NOT EXISTS billing_cycle mera.billing_cycle DEFAULT 'Monthly',
ADD COLUMN IF NOT EXISTS nudge_buffer_days INTEGER DEFAULT 7;

COMMENT ON COLUMN mera.subscriptions.nudge_buffer_days IS 'Days before cycle to send the nudge. 7 for monthly, 14 for bulk users.';

-- 2. Update Inventory with High-Volume "Stock-Up" Anchors
INSERT INTO mera.inventory (name, description, category, price, currency, stock_level, country_code)
VALUES 
('Always Ultra Slim (92ct)', 'Bulk anchor: Massive volume for full cycle security.', 'Pads', 450.00, 'GHS', 50, 'GH'),
('Always Maxi Overnight (54ct)', 'Advance security for heavy flow nights.', 'Pads', 450.00, 'GHS', 40, 'GH'),
('Yazz Bulk Pack (120ct)', 'The economy choice for full long-term stock.', 'Pads', 280.00, 'GHS', 30, 'GH');
