-- Update box_tier enum to match frontend labels
-- Note: ALTER TYPE ... ADD VALUE cannot be run inside a transaction block in some Postgres versions,
-- so we usually run it as a standalone migration.

ALTER TYPE mera.box_tier ADD VALUE IF NOT EXISTS 'Eco Premium';

-- Ensure we have the same for any other potential mismatched labels
-- (Checking if we need 'Premium' or others, but 'Eco Premium' is the current blocker)
