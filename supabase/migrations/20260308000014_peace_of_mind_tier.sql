-- Sync Enums with new MyMeri "Stock-Up" Branding
-- 1. Sync box_tier enum with 'Peace of Mind'
ALTER TYPE mera.box_tier ADD VALUE IF NOT EXISTS 'Peace of Mind';

-- 2. Sync item_category with premium names 'Choice' and 'Relief'
ALTER TYPE mera.item_category ADD VALUE IF NOT EXISTS 'Choice';
ALTER TYPE mera.item_category ADD VALUE IF NOT EXISTS 'Relief';

-- 3. Sync order_status with dashboard states
ALTER TYPE mera.order_status ADD VALUE IF NOT EXISTS 'Failed';
ALTER TYPE mera.order_status ADD VALUE IF NOT EXISTS 'Delivered';
