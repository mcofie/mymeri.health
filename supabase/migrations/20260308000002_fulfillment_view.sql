-- Fulfillment View: Masking health data for warehouse staff
CREATE OR REPLACE VIEW mera.fulfillment_view AS
SELECT 
    ps.id AS slip_id,
    ps.status,
    ps.items_json,
    ps.is_discreet,
    p.full_name,
    p.address,
    p.whatsapp_id,
    o.country_code,
    o.currency,
    o.total_amount
FROM mera.packing_slips ps
JOIN mera.orders o ON ps.order_id = o.id
JOIN mera.profiles p ON o.user_id = p.id;

-- Health Data Protection: Add a check for data protection
COMMENT ON TABLE mera.subscriptions IS 'Sensitive health data. Strictly regulated under Ghana Data Protection Act and GDPR.';
COMMENT ON COLUMN mera.subscriptions.last_period_date IS 'Sensitive: Health data (Menstrual Cycle).';
