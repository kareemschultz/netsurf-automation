-- =============================================================================
-- Netsurf Group - Sample Data for All Businesses
-- =============================================================================
-- Based on research of Netsurf WISP, Netsurf Power, and Netsurf Nature Park
-- Owner: Stephen Thompson
--
-- Usage:
--   docker compose exec postgres psql -U netsurf -d directus < directus/seed-data.sql
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Business Info (All 3 Businesses)
-- -----------------------------------------------------------------------------
INSERT INTO business_info (business, key, value, description) VALUES
-- WISP
('wisp', 'business_name', 'Netsurf Network', 'Company name'),
('wisp', 'business_hours', 'Monday - Friday: 8:00 AM - 5:00 PM
Saturday: 9:00 AM - 1:00 PM
Sunday: Closed', 'Office hours'),
('wisp', 'phone_main', '+592 XXX XXXX', 'Main support line'),
('wisp', 'whatsapp', '+592 XXX XXXX', 'WhatsApp support'),
('wisp', 'email', 'support@netsurfnetwork.com', 'Support email'),
('wisp', 'website', 'netsurfnetwork.com', 'Website'),
('wisp', 'coverage_areas', 'Georgetown, East Coast Demerara, West Coast Demerara, East Bank Demerara, Linden area', 'Service coverage'),

-- Power
('power', 'business_name', 'Netsurf Power', 'Company name'),
('power', 'tagline', 'Making Solar Power Affordable in Guyana', 'Business tagline'),
('power', 'business_hours', 'Monday - Friday: 8:00 AM - 5:00 PM
Saturday: 9:00 AM - 1:00 PM', 'Office hours'),
('power', 'phone_main', '+592 XXX XXXX', 'Sales line'),
('power', 'whatsapp', '+592 XXX XXXX', 'WhatsApp'),
('power', 'email', 'sales@netsurfpower.com', 'Sales email'),
('power', 'website', 'netsurfpower.com', 'Website'),
('power', 'address', '56 Chalmers Place, Stabroek, Georgetown', 'Office address'),
('power', 'since', '2018', 'Year established'),

-- Nature Park
('park', 'business_name', 'Netsurf Nature Park', 'Company name'),
('park', 'tagline', 'For The Most Ultimate Camping Experience', 'Business tagline'),
('park', 'business_hours', 'Daily: 8:00 AM - 5:00 PM', 'Park hours'),
('park', 'phone_reservations', '+592 611-9443', 'Reservation line'),
('park', 'phone_secondary', '+592 621-8271', 'Secondary line'),
('park', 'whatsapp', '+592 611-9443', 'WhatsApp bookings'),
('park', 'location', 'Soesdyke Linden Highway, near Linden', 'Park location'),
('park', 'location_code', '3PPJ+RW7', 'Google Plus Code'),
('park', 'taxi_fare', '3000-4000 GYD from Georgetown', 'Estimated taxi fare'),
('park', 'instagram', '@netsurfnatureparkgy', 'Instagram handle'),
('park', 'facebook', '/netsurfnaturepark', 'Facebook page')
ON CONFLICT (business, key) DO UPDATE SET value = EXCLUDED.value;

-- -----------------------------------------------------------------------------
-- WISP Internet Plans
-- -----------------------------------------------------------------------------
INSERT INTO wisp_plans (name, speed_mbps, price, currency, description, features, plan_type, status, sort) VALUES
('Netsurf Basic', 10, 5000, 'GYD', 
 'Perfect for light browsing and social media. Great for individuals.',
 '["10 Mbps Download", "5 Mbps Upload", "Unlimited Data", "Free Installation", "24/7 Support"]',
 'residential', 'active', 1),
 
('Netsurf Standard', 25, 8000, 'GYD',
 'Ideal for families. Stream videos, work from home, and game online.',
 '["25 Mbps Download", "10 Mbps Upload", "Unlimited Data", "Free Installation", "Free Router", "24/7 Support"]',
 'residential', 'active', 2),
 
('Netsurf Premium', 50, 12000, 'GYD',
 'Our fastest residential plan. Perfect for power users and large households.',
 '["50 Mbps Download", "25 Mbps Upload", "Unlimited Data", "Free Installation", "Premium Router", "Priority Support"]',
 'residential', 'active', 3),
 
('Netsurf Business', 100, 25000, 'GYD',
 'Dedicated connection for small to medium businesses.',
 '["100 Mbps Download", "50 Mbps Upload", "Unlimited Data", "Static IP", "SLA Guaranteed", "Dedicated Support Line"]',
 'business', 'active', 4)
ON CONFLICT DO NOTHING;

-- -----------------------------------------------------------------------------
-- Netsurf Power - Products
-- -----------------------------------------------------------------------------
INSERT INTO power_products (name, category, price, currency, description, features, status, sort) VALUES
('Solar Panel 335W', 'panels', 21000, 'GYD',
 'High-efficiency 335 watt solar panel for residential and commercial use.',
 '["335W Output", "High Efficiency", "25 Year Warranty", "Weather Resistant"]',
 'active', 1),

('Solar Panel 400W', 'panels', 28000, 'GYD',
 'Premium 400 watt solar panel for maximum power generation.',
 '["400W Output", "Monocrystalline", "25 Year Warranty", "Low Light Performance"]',
 'active', 2),

('Netsurf Lithium Battery 100Ah 48V', 'batteries', 150000, 'GYD',
 'Long-lasting lithium battery for solar storage systems.',
 '["100Ah Capacity", "48V System", "10+ Year Lifespan", "BMS Included", "Deep Cycle"]',
 'active', 3),

('EPEVER Hybrid Inverter 3000W', 'inverters', 85000, 'GYD',
 'Hybrid inverter charger for off-grid and grid-tied systems.',
 '["3000W Output", "Pure Sine Wave", "MPPT Charger", "Grid-Tie Ready", "LCD Display"]',
 'active', 4),

('Security Camera System', 'cameras', 13500, 'GYD',
 'Solar-powered security camera for remote monitoring.',
 '["Solar Powered", "WiFi Connected", "Night Vision", "Motion Detection", "Mobile App"]',
 'active', 5),

('Starlink Internet Kit', 'starlink', 0, 'GYD',
 'High-speed satellite internet for anywhere in Guyana. Contact for pricing.',
 '["Up to 200 Mbps", "Low Latency", "Easy Setup", "Rural Coverage", "No Phone Line Needed"]',
 'active', 6)
ON CONFLICT DO NOTHING;

-- -----------------------------------------------------------------------------
-- Netsurf Power - Services
-- -----------------------------------------------------------------------------
INSERT INTO power_services (name, description, price_type, price_range, features, status) VALUES
('Residential Solar Installation', 
 'Complete solar system installation for homes. Includes panels, inverter, battery, and all materials.',
 'quote', 'Starting from GYD $300,000',
 '["Site Assessment", "Custom Design", "Professional Installation", "System Testing", "Warranty Support"]',
 'active'),

('Commercial Solar Installation',
 'Large-scale solar solutions for businesses and organizations.',
 'quote', 'Contact for quote',
 '["Energy Audit", "ROI Analysis", "Turnkey Installation", "Maintenance Plan", "Grid-Tie Options"]',
 'active'),

('Solar System Maintenance',
 'Regular maintenance and cleaning for existing solar systems.',
 'fixed', 'GYD $15,000 per visit',
 '["Panel Cleaning", "Connection Check", "Inverter Inspection", "Battery Health Check", "Performance Report"]',
 'active'),

('Starlink Installation',
 'Professional Starlink satellite internet setup and installation.',
 'fixed', 'GYD $25,000',
 '["Optimal Placement", "Cable Routing", "Network Setup", "Speed Testing", "Usage Training"]',
 'active')
ON CONFLICT DO NOTHING;

-- -----------------------------------------------------------------------------
-- Netsurf Nature Park - Accommodations
-- -----------------------------------------------------------------------------
INSERT INTO park_accommodations (name, capacity, price_day, price_overnight, currency, description, amenities, status, sort) VALUES
('Small Cabin', 4, 5000, 12000, 'GYD',
 'Cozy cabin perfect for couples or small families.',
 '["Sleeps 4", "Basic Furnishing", "Creek Access", "BBQ Area Access"]',
 'active', 1),

('Medium Cabin', 6, 8000, 18000, 'GYD',
 'Spacious cabin for families or small groups.',
 '["Sleeps 6", "Kitchen Area", "Creek Access", "Private BBQ Spot", "Outdoor Seating"]',
 'active', 2),

('Large Cabin', 10, 12000, 25000, 'GYD',
 'Our largest cabin, ideal for big families or group retreats.',
 '["Sleeps 10", "Full Kitchen", "Multiple Rooms", "Creek Access", "Private Area"]',
 'active', 3),

('Camping Site', 4, 2500, 5000, 'GYD',
 'Bring your own tent and enjoy the authentic camping experience.',
 '["Tent Space", "Fire Pit Access", "Restroom Access", "Creek Access"]',
 'active', 4),

('Day Pass', 0, 1500, 0, 'GYD',
 'Enjoy the park for a day without overnight stay.',
 '["Park Access", "Creek Swimming", "Nature Walks", "Volleyball Court", "Picnic Areas"]',
 'active', 5)
ON CONFLICT DO NOTHING;

-- -----------------------------------------------------------------------------
-- Netsurf Nature Park - Activities
-- -----------------------------------------------------------------------------
INSERT INTO park_activities (name, description, included, additional_cost, duration) VALUES
('Creek Swimming', 
 'Cool off in our beautiful blackwater creek. Natural, refreshing, and perfect for all ages.',
 true, NULL, 'Unlimited'),

('Nature Walks',
 'Explore our trails through the lush rainforest. Spot local wildlife and enjoy scenic views.',
 true, NULL, '30 min - 2 hours'),

('Birdwatching',
 'The park is home to many local and migratory bird species. Bring your binoculars!',
 true, NULL, 'Unlimited'),

('Volleyball',
 'Our court is ready for friendly games. Balls provided.',
 true, NULL, 'Unlimited'),

('Campfire',
 'Gather around the campfire in the evening. Firewood provided.',
 true, NULL, 'Evening'),

('Fishing',
 'Try your luck in our creek. Bring your own gear or rent basic equipment.',
 false, 'GYD $500 equipment rental', 'Unlimited'),

('Cooking/BBQ',
 'Cook your own meals with our BBQ facilities. Bring your own food and supplies.',
 true, NULL, 'Self-service'),

('Group Events',
 'Host your corporate retreat, birthday party, or family reunion at the park.',
 false, 'Contact for quote', 'Customizable')
ON CONFLICT DO NOTHING;

-- -----------------------------------------------------------------------------
-- FAQ - WISP
-- -----------------------------------------------------------------------------
INSERT INTO wisp_faq (question, answer, keywords, status, sort) VALUES
('What internet plans do you offer?',
 'We offer four main plans:\n\n• **Basic** (10 Mbps) - GYD $5,000/month - Perfect for browsing and social media\n• **Standard** (25 Mbps) - GYD $8,000/month - Great for families, streaming, and gaming\n• **Premium** (50 Mbps) - GYD $12,000/month - Our fastest for power users\n• **Business** (100 Mbps) - GYD $25,000/month - For businesses with SLA guarantee\n\nAll plans include unlimited data and free installation!',
 '["plans", "packages", "pricing", "speed", "cost", "price", "mbps"]',
 'published', 1),

('What areas do you cover?',
 'We currently provide service in:\n\n• Georgetown (all areas)\n• East Coast Demerara\n• West Coast Demerara\n• East Bank Demerara\n• Parts of the Linden area\n\nWe''re constantly expanding! Contact us to check if your specific location is covered.',
 '["coverage", "area", "location", "available", "service"]',
 'published', 2),

('How do I reset my router?',
 'To reset your router:\n\n1. Locate the small reset button on the back\n2. Use a paperclip to press and hold for 10 seconds\n3. Wait 2-3 minutes for restart\n4. Reconnect your devices\n\nIf issues persist, contact our support team.',
 '["reset", "router", "restart", "reboot", "not working"]',
 'published', 3),

('My internet is slow. What should I do?',
 'Try these steps:\n\n1. **Restart your router** - Unplug for 30 seconds\n2. **Check your device** - Try a different device\n3. **Move closer to router** - Walls reduce WiFi signal\n4. **Close background apps** - Downloads can slow things down\n5. **Check for interference** - Keep router away from microwaves\n\nStill having issues? Contact us for a line check.',
 '["slow", "speed", "buffering", "lag", "latency"]',
 'published', 4),

('How do I pay my bill?',
 'Payment options:\n\n• **Online Banking** - Pay directly from your bank\n• **Mobile Money** - Use your mobile wallet\n• **Our Office** - Visit during business hours\n• **Authorized Agents** - Select locations\n\nAsk us about automatic payments!',
 '["pay", "payment", "bill", "invoice"]',
 'published', 5)
ON CONFLICT DO NOTHING;

-- -----------------------------------------------------------------------------
-- FAQ - Power
-- -----------------------------------------------------------------------------
INSERT INTO power_faq (question, answer, keywords, status, sort) VALUES
('How much does a solar system cost?',
 'Solar system costs depend on your energy needs:\n\n• **Small System** (1-2kW) - Starting GYD $300,000\n• **Medium System** (3-5kW) - Starting GYD $600,000\n• **Large System** (5kW+) - Contact for quote\n\nWe offer free site assessments to recommend the right system for your needs. Financing options available!',
 '["cost", "price", "solar", "system", "how much"]',
 'published', 1),

('Do you install Starlink?',
 'Yes! We are authorized Starlink installers in Guyana.\n\nOur service includes:\n• Professional installation\n• Optimal antenna placement\n• Complete network setup\n• Speed testing\n\nStarlink provides high-speed internet anywhere in Guyana - even remote areas!',
 '["starlink", "satellite", "internet", "install"]',
 'published', 2),

('What warranty do you offer?',
 'Our warranty coverage:\n\n• **Solar Panels** - 25 year manufacturer warranty\n• **Inverters** - 5-10 year warranty (varies by model)\n• **Batteries** - 5-10 year warranty\n• **Installation** - 2 year workmanship warranty\n\nWe also offer extended maintenance plans.',
 '["warranty", "guarantee", "coverage"]',
 'published', 3),

('How long does installation take?',
 'Typical installation timelines:\n\n• **Residential** - 1-3 days\n• **Commercial** - 3-7 days (depending on size)\n• **Starlink** - Same day (usually 2-4 hours)\n\nWe''ll give you an exact timeline after the site assessment.',
 '["installation", "how long", "time", "install"]',
 'published', 4),

('Do you offer financing?',
 'Yes! We understand solar is an investment. We offer:\n\n• Payment plans\n• Financing options through partner banks\n• Corporate/business payment terms\n\nContact us to discuss options that work for your budget.',
 '["financing", "payment plan", "credit", "loan"]',
 'published', 5)
ON CONFLICT DO NOTHING;

-- -----------------------------------------------------------------------------
-- FAQ - Nature Park
-- -----------------------------------------------------------------------------
INSERT INTO park_faq (question, answer, keywords, status, sort) VALUES
('How do I make a reservation?',
 'Booking is easy!\n\n**Call or WhatsApp:**\n• +592 611-9443\n• +592 621-8271\n\nWe recommend booking at least 1-2 days in advance for weekends and holidays.',
 '["reservation", "booking", "reserve", "book"]',
 'published', 1),

('What should I bring?',
 'We recommend:\n\n**Essentials:**\n• Comfortable clothes & shoes\n• Swimwear\n• Insect repellent\n• Sunscreen\n• Camera\n\n**If cooking:**\n• Food & drinks\n• Cooking utensils (or rent from us)\n• Ice/cooler\n\n**For overnight:**\n• Bedding/sleeping bags (cabins have beds but bring sheets)\n• Toiletries\n• Flashlight',
 '["bring", "pack", "what to bring", "items"]',
 'published', 2),

('What are your prices?',
 '**Day Trips:**\n• Day Pass: GYD $1,500 per person\n• Small Cabin (day): GYD $5,000\n• Medium Cabin (day): GYD $8,000\n• Large Cabin (day): GYD $12,000\n\n**Overnight:**\n• Small Cabin: GYD $12,000\n• Medium Cabin: GYD $18,000\n• Large Cabin: GYD $25,000\n• Camping: GYD $5,000',
 '["price", "cost", "how much", "rates"]',
 'published', 3),

('How do I get there?',
 '**Location:** Soesdyke Linden Highway, near Linden\n**GPS Code:** 3PPJ+RW7\n\n**By Bus:**\nFrom Georgetown Bus Park, take a Linden bus. Ask driver to stop near 3PPJ+RW7. Bus fare ~GYD $500.\n\n**By Taxi:**\nFrom Georgetown, ~GYD $3,000-4,000. Tell driver "Netsurf Nature Park on Soesdyke Linden Highway."',
 '["directions", "location", "get there", "address", "how to get"]',
 'published', 4),

('Can I swim in the creek?',
 'Yes! Our blackwater creek is one of the main attractions.\n\n• Natural, refreshing water\n• Safe for all ages\n• Shallow areas for children\n• Deep spots for swimming\n\nThe creek runs through the property and is perfect for cooling off after nature walks!',
 '["swim", "creek", "water", "swimming"]',
 'published', 5),

('Do you host events?',
 'Absolutely! The park is perfect for:\n\n• Corporate retreats\n• Birthday parties\n• Family reunions\n• Church groups\n• School trips\n• Team building\n\nContact us for group rates and event packages.',
 '["events", "party", "group", "reunion", "corporate"]',
 'published', 6),

('What are your hours?',
 '**Park Hours:** Daily 8:00 AM - 5:00 PM\n\nOvernight guests have 24-hour access to their cabin and the grounds.',
 '["hours", "open", "time", "when"]',
 'published', 7)
ON CONFLICT DO NOTHING;

-- -----------------------------------------------------------------------------
-- Promotions (All Businesses)
-- -----------------------------------------------------------------------------
INSERT INTO promotions (business, title, description, discount_percent, start_date, end_date, status, auto_post, terms) VALUES
('wisp', 'New Year 2026 Special', 
 'Start the new year with blazing fast internet! Get 50% off your first 3 months on any residential plan.',
 50, '2026-01-01', '2026-01-31', 'active', true,
 'Valid for new residential customers only. Minimum 6-month contract required.'),

('power', 'Solar New Year Sale',
 'Go solar in 2026! 15% off all residential solar system installations this month.',
 15, '2026-01-01', '2026-01-31', 'active', true,
 'Applies to complete system installations. Cannot combine with other offers.'),

('park', 'Midweek Escape',
 'Book a cabin Monday-Thursday and get 20% off! Perfect for a peaceful nature retreat.',
 20, '2026-01-01', '2026-03-31', 'active', true,
 'Valid for cabin bookings Monday-Thursday only. Advance booking required.')
ON CONFLICT DO NOTHING;

-- -----------------------------------------------------------------------------
-- Done
-- -----------------------------------------------------------------------------
DO $$
BEGIN
    RAISE NOTICE 'Netsurf Group sample data inserted successfully!';
    RAISE NOTICE 'Businesses configured: WISP, Power, Nature Park';
END $$;

-- =============================================================================
-- SYSTEM CONTROLS & DECISION RULES (Added based on Gemini/ChatGPT review)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- System Controls (Singleton - Staff Kill Switches)
-- -----------------------------------------------------------------------------
INSERT INTO system_controls (
    bot_enabled,
    emergency_mode,
    emergency_message,
    wisp_bot_enabled,
    power_bot_enabled,
    park_bot_enabled,
    confidence_threshold,
    max_turns_before_escalate,
    promo_mode,
    promo_footer_message
) VALUES (
    true,
    false,
    'We are currently experiencing technical difficulties. A team member will respond to your message shortly. We apologize for the inconvenience.',
    true,
    true,
    true,
    0.75,
    6,
    false,
    '🎉 Ask about our current promotions!'
) ON CONFLICT DO NOTHING;

-- -----------------------------------------------------------------------------
-- Decision Rules (Staff-Configurable Business Logic)
-- -----------------------------------------------------------------------------
INSERT INTO decision_rules (business, rule_type, name, description, trigger_keywords, trigger_plan, action_type, action_value, priority, status, sort) VALUES

-- WISP Upsell Rules
('wisp', 'upsell', 'Basic to Standard Upsell',
 'When customer on Basic plan mentions slow speeds, suggest Standard',
 '["slow", "buffering", "lagging", "upgrade"]',
 'Basic',
 'suggest_plan',
 'Standard',
 10, 'active', 1),

('wisp', 'upsell', 'Standard to Premium Upsell',
 'When customer on Standard mentions gaming or streaming issues',
 '["gaming", "streaming", "4k", "multiple devices", "work from home"]',
 'Standard',
 'suggest_plan',
 'Premium',
 10, 'active', 2),

-- Promo Priority Rules
('wisp', 'promo_priority', 'New Customer Promo Priority',
 'Always mention new customer promo first',
 '["new customer", "switching", "moving", "new connection"]',
 NULL,
 'show_promo',
 'New Year 2026 Special',
 20, 'active', 3),

-- Topic Blocks
('all', 'topic_block', 'Block Competitor Discussions',
 'Do not compare to other ISPs',
 '["GTT", "Digicel", "E-Networks", "other providers", "competition"]',
 NULL,
 'fixed_response',
 'I can only provide information about Netsurf services. Would you like to know about our plans and features?',
 100, 'active', 4),

-- Power Rules
('power', 'upsell', 'Basic Solar to Full System',
 'When asking about panels only, suggest full system',
 '["just panels", "only panels", "panel price"]',
 NULL,
 'fixed_response',
 'While we do sell panels individually, a complete system (panels + inverter + battery) provides the best value and reliability. Would you like a free quote for a full system?',
 10, 'active', 5),

('power', 'auto_response', 'Starlink Interest Capture',
 'When customer asks about Starlink, get their location',
 '["starlink", "satellite internet", "rural internet"]',
 NULL,
 'fixed_response',
 'Great news! We install Starlink in Guyana. For a quote, I just need to know: 1) Your location/address, 2) Is this for home or business? A team member will follow up with pricing.',
 15, 'active', 6),

-- Park Rules  
('park', 'promo_priority', 'Midweek Discount',
 'Always mention midweek discount for weekday inquiries',
 '["monday", "tuesday", "wednesday", "thursday", "weekday"]',
 NULL,
 'show_promo',
 'Midweek Escape',
 10, 'active', 7),

('park', 'auto_response', 'Group Booking Capture',
 'For group inquiries, capture details for callback',
 '["group", "company", "team building", "birthday", "event", "party", "reunion"]',
 NULL,
 'fixed_response',
 'We love hosting groups! For the best rates, please share: 1) Approximate group size, 2) Preferred date(s), 3) Day trip or overnight?, 4) Best phone number for callback. Our team will prepare a custom quote!',
 20, 'active', 8),

-- Emergency Override (inactive by default)
('all', 'auto_response', 'Outage Response Override',
 'Override all responses during major outage (activate via Directus)',
 '[]',
 NULL,
 'fixed_response',
 'We are aware of a service issue in your area and technicians are actively working to resolve it. For urgent matters, please call our hotline. We apologize for the inconvenience.',
 1000, 'inactive', 99)

ON CONFLICT DO NOTHING;
