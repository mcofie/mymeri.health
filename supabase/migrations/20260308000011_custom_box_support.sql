-- Enable A La Carte functionality by adding a Custom tier and storing selected items
-- 1. Add 'Custom' to the box_tier enum in 'mera' schema
-- (Stand-alone as it can't run in a transaction block in some versions, but we'll try)
ALTER TYPE mera.box_tier ADD VALUE IF NOT EXISTS 'Custom';

-- 2. Add a column to store custom item selections for the subscription
ALTER TABLE mera.subscriptions 
ADD COLUMN IF NOT EXISTS custom_items_json JSONB DEFAULT '[]';

COMMENT ON COLUMN mera.subscriptions.custom_items_json IS 'Stores IDs and quantities of individual items for a Custom/A La Carte box.';
