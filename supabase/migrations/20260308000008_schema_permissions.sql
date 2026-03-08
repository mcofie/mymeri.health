-- Grant Schema Usage to API roles
GRANT USAGE ON SCHEMA mera TO anon;
GRANT USAGE ON SCHEMA mera TO authenticated;

-- Grant access to all tables in the schema
GRANT ALL ON ALL TABLES IN SCHEMA mera TO anon;
GRANT ALL ON ALL TABLES IN SCHEMA mera TO authenticated;

-- Grant access to sequences (for IDs)
GRANT ALL ON ALL SEQUENCES IN SCHEMA mera TO anon;
GRANT ALL ON ALL SEQUENCES IN SCHEMA mera TO authenticated;

-- Grant access to the fulfillment view specifically
GRANT SELECT ON mera.fulfillment_view TO authenticated;
GRANT SELECT ON mera.fulfillment_view TO anon; -- Optional: usually only authenticated
