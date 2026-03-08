-- Add is_discreet to subscriptions to ensure fulfillment knows about privacy needs
ALTER TABLE mera.subscriptions ADD COLUMN IF NOT EXISTS is_discreet BOOLEAN DEFAULT FALSE;

COMMENT ON COLUMN mera.subscriptions.is_discreet IS 'Enables plain packaging for this user by default.';
