-- Packing Slips Table for fulfillment
CREATE TABLE IF NOT EXISTS mera.packing_slips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES mera.orders(id) ON DELETE CASCADE,
    packed_by UUID REFERENCES auth.users(id), -- Admin/Warehouse staff
    status TEXT NOT NULL DEFAULT 'To Pack', -- 'To Pack', 'In Progress', 'Packed'
    items_json JSONB NOT NULL, -- Frozen copy of items to pack
    is_discreet BOOLEAN NOT NULL DEFAULT TRUE,
    country_code TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for faster lookup
CREATE INDEX IF NOT EXISTS idx_packing_slips_order_id ON mera.packing_slips(order_id);
CREATE INDEX IF NOT EXISTS idx_packing_slips_status ON mera.packing_slips(status);
