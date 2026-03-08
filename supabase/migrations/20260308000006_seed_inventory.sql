-- Seed Initial Inventory for MyMeri.health
-- Ghana (GHS)
INSERT INTO mera.inventory (name, description, category, price, currency, stock_level, country_code)
VALUES 
('Eco-Flex Pads (12ct)', 'Biodegradable, ultra-thin bamboo pads.', 'Pads', 45.00, 'GHS', 150, 'GH'),
('Comfort Plus Night Pads (8ct)', 'Extra long for maximum overnight protection.', 'Pads', 55.00, 'GHS', 120, 'GH'),
('Cramp-Relief Herbal Tea', 'Soothing blend of ginger and raspberry leaf.', 'Treats', 30.00, 'GHS', 45, 'GH'),
('Ibuprofen 200mg (10ct)', 'Fast-acting pain relief for menstrual cramps.', 'Meds', 15.00, 'GHS', 200, 'GH');

-- Nigeria (NGN)
INSERT INTO mera.inventory (name, description, category, price, currency, stock_level, country_code)
VALUES 
('Eco-Flex Pads (12ct)', 'Biodegradable, ultra-thin bamboo pads.', 'Pads', 2500.00, 'NGN', 200, 'NG'),
('Comfort Plus Night Pads (8ct)', 'Extra long for maximum overnight protection.', 'Pads', 3200.00, 'NGN', 180, 'NG'),
('Dark Chocolate Energy Bar', 'Magnesium-rich dark chocolate with sea salt.', 'Treats', 1500.00, 'NGN', 100, 'NG');

-- Kenya (KES)
INSERT INTO mera.inventory (name, description, category, price, currency, stock_level, country_code)
VALUES 
('Eco-Flex Pads (12ct)', 'Biodegradable, ultra-thin bamboo pads.', 'Pads', 850.00, 'KES', 100, 'KE'),
('Period Comfort Heat Patch', 'Air-activated heating patch for cramps.', 'Treats', 600.00, 'KES', 50, 'KE');
