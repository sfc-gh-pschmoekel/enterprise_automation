/*=============================================================================
  ENTERPRISE WORKFLOW AUTOMATION - HANDS ON LAB
  Demo 3: The Marketing Campaign Agent
=============================================================================*/

USE ROLE SYSADMIN;
USE DATABASE HOL_AUTOMATION;

CREATE SCHEMA IF NOT EXISTS HOL_AUTOMATION.MARKETING;
USE SCHEMA MARKETING;

USE WAREHOUSE HOL_AGENT_WH;

-- ============================================================================
-- SECTION 1: MARKETING CHANNELS
-- ============================================================================

CREATE OR REPLACE TABLE CHANNELS (
    channel_id VARCHAR(20) PRIMARY KEY,
    channel_name VARCHAR(50),
    channel_type VARCHAR(30),
    cost_model VARCHAR(20),
    typical_cpm DECIMAL(8,2)
);

INSERT INTO CHANNELS VALUES
    ('CH001', 'Google Search', 'Paid Search', 'CPC', 2.50),
    ('CH002', 'Meta Ads', 'Paid Social', 'CPM', 12.00),
    ('CH003', 'LinkedIn Ads', 'Paid Social', 'CPC', 8.50),
    ('CH004', 'TikTok Ads', 'Paid Social', 'CPM', 6.00),
    ('CH005', 'Email Marketing', 'Owned', 'FLAT', 0.10),
    ('CH006', 'Display Network', 'Programmatic', 'CPM', 4.00),
    ('CH007', 'YouTube Pre-roll', 'Video', 'CPV', 0.15),
    ('CH008', 'Organic Social', 'Owned', 'FLAT', 0.00);

-- ============================================================================
-- SECTION 2: CAMPAIGNS
-- ============================================================================

CREATE OR REPLACE TABLE CAMPAIGNS (
    campaign_id VARCHAR(20) PRIMARY KEY,
    campaign_name VARCHAR(200),
    campaign_type VARCHAR(50),
    objective VARCHAR(50),
    target_audience VARCHAR(100),
    start_date DATE,
    end_date DATE,
    budget DECIMAL(12,2),
    status VARCHAR(20)
);

INSERT INTO CAMPAIGNS VALUES
    ('CMP-2024-001', 'Q1 Brand Awareness Push', 'Brand', 'Awareness', 'Manufacturing decision makers', '2024-01-15', '2024-03-31', 150000.00, 'COMPLETED'),
    ('CMP-2024-002', 'Spring Trade Show Promo', 'Event', 'Lead Gen', 'Trade show attendees', '2024-03-01', '2024-03-20', 45000.00, 'COMPLETED'),
    ('CMP-2024-003', 'New Hydraulic Pump Launch', 'Product', 'Conversion', 'Industrial buyers', '2024-02-01', '2024-04-30', 80000.00, 'ACTIVE'),
    ('CMP-2024-004', 'Q2 Retargeting Blast', 'Retargeting', 'Conversion', 'Website visitors', '2024-04-01', '2024-06-30', 35000.00, 'ACTIVE'),
    ('CMP-2024-005', 'Summer Flash Sale', 'Promotional', 'Conversion', 'Email subscribers', '2024-06-15', '2024-06-22', 25000.00, 'PLANNED'),
    ('CMP-2024-006', 'LinkedIn Thought Leadership', 'Content', 'Awareness', 'C-suite manufacturing', '2024-01-01', '2024-12-31', 60000.00, 'ACTIVE'),
    ('CMP-2024-007', 'TikTok Gen Z Recruitment', 'Employer Brand', 'Awareness', 'Young engineers', '2024-03-01', '2024-05-31', 40000.00, 'ACTIVE');

-- ============================================================================
-- SECTION 3: CAMPAIGN PERFORMANCE (Daily Metrics)
-- ============================================================================

CREATE OR REPLACE TABLE CAMPAIGN_PERFORMANCE (
    performance_id INT AUTOINCREMENT PRIMARY KEY,
    campaign_id VARCHAR(20) REFERENCES CAMPAIGNS(campaign_id),
    channel_id VARCHAR(20) REFERENCES CHANNELS(channel_id),
    report_date DATE,
    impressions INT,
    clicks INT,
    conversions INT,
    spend DECIMAL(10,2),
    revenue DECIMAL(12,2)
);

-- Q1 Brand Awareness (CMP-2024-001) - Good performance
INSERT INTO CAMPAIGN_PERFORMANCE (campaign_id, channel_id, report_date, impressions, clicks, conversions, spend, revenue) VALUES
    ('CMP-2024-001', 'CH002', '2024-03-25', 450000, 8500, 120, 5400.00, 48000.00),
    ('CMP-2024-001', 'CH006', '2024-03-25', 680000, 4200, 85, 2720.00, 34000.00),
    ('CMP-2024-001', 'CH007', '2024-03-25', 320000, 6400, 95, 4800.00, 38000.00),
    ('CMP-2024-001', 'CH002', '2024-03-26', 465000, 8800, 125, 5580.00, 50000.00),
    ('CMP-2024-001', 'CH006', '2024-03-26', 695000, 4350, 88, 2780.00, 35200.00),
    ('CMP-2024-001', 'CH007', '2024-03-26', 335000, 6700, 100, 5025.00, 40000.00);

-- Hydraulic Pump Launch (CMP-2024-003) - Great performance
INSERT INTO CAMPAIGN_PERFORMANCE (campaign_id, channel_id, report_date, impressions, clicks, conversions, spend, revenue) VALUES
    ('CMP-2024-003', 'CH001', '2024-03-25', 85000, 4250, 180, 10625.00, 144000.00),
    ('CMP-2024-003', 'CH003', '2024-03-25', 45000, 900, 45, 7650.00, 36000.00),
    ('CMP-2024-003', 'CH005', '2024-03-25', 120000, 9600, 220, 1200.00, 176000.00),
    ('CMP-2024-003', 'CH001', '2024-03-26', 88000, 4400, 185, 11000.00, 148000.00),
    ('CMP-2024-003', 'CH003', '2024-03-26', 46500, 930, 48, 7905.00, 38400.00),
    ('CMP-2024-003', 'CH005', '2024-03-26', 125000, 10000, 230, 1250.00, 184000.00);

-- TikTok Campaign (CMP-2024-007) - PROBLEM: High spend, low conversion
INSERT INTO CAMPAIGN_PERFORMANCE (campaign_id, channel_id, report_date, impressions, clicks, conversions, spend, revenue) VALUES
    ('CMP-2024-007', 'CH004', '2024-03-25', 1200000, 24000, 8, 7200.00, 3200.00),
    ('CMP-2024-007', 'CH004', '2024-03-26', 1350000, 27000, 10, 8100.00, 4000.00),
    ('CMP-2024-007', 'CH004', '2024-03-27', 1100000, 22000, 6, 6600.00, 2400.00),
    ('CMP-2024-007', 'CH004', '2024-03-28', 1280000, 25600, 9, 7680.00, 3600.00);

-- LinkedIn Thought Leadership (CMP-2024-006) - Steady brand building
INSERT INTO CAMPAIGN_PERFORMANCE (campaign_id, channel_id, report_date, impressions, clicks, conversions, spend, revenue) VALUES
    ('CMP-2024-006', 'CH003', '2024-03-25', 28000, 840, 12, 7140.00, 9600.00),
    ('CMP-2024-006', 'CH008', '2024-03-25', 15000, 450, 5, 0.00, 4000.00),
    ('CMP-2024-006', 'CH003', '2024-03-26', 29500, 885, 14, 7522.50, 11200.00),
    ('CMP-2024-006', 'CH008', '2024-03-26', 16200, 486, 6, 0.00, 4800.00);

-- Q2 Retargeting (CMP-2024-004) - Solid ROAS
INSERT INTO CAMPAIGN_PERFORMANCE (campaign_id, channel_id, report_date, impressions, clicks, conversions, spend, revenue) VALUES
    ('CMP-2024-004', 'CH002', '2024-04-01', 180000, 5400, 95, 2160.00, 38000.00),
    ('CMP-2024-004', 'CH006', '2024-04-01', 220000, 4400, 78, 880.00, 31200.00),
    ('CMP-2024-004', 'CH002', '2024-04-02', 175000, 5250, 92, 2100.00, 36800.00),
    ('CMP-2024-004', 'CH006', '2024-04-02', 215000, 4300, 75, 860.00, 30000.00);

-- ============================================================================
-- SECTION 4: A/B TEST RESULTS
-- ============================================================================

CREATE OR REPLACE TABLE AB_TESTS (
    test_id VARCHAR(20) PRIMARY KEY,
    campaign_id VARCHAR(20) REFERENCES CAMPAIGNS(campaign_id),
    test_name VARCHAR(200),
    variant_a_description VARCHAR(500),
    variant_b_description VARCHAR(500),
    winner VARCHAR(10),
    lift_percentage DECIMAL(5,2),
    statistical_significance DECIMAL(5,2),
    test_start DATE,
    test_end DATE,
    insights VARCHAR(1000)
);

INSERT INTO AB_TESTS VALUES
    ('ABT-001', 'CMP-2024-003', 'Headline Test - Pump Launch', 
     'Power Your Production with Next-Gen Hydraulics', 
     'Cut Downtime 40% with Our New Hydraulic Pump',
     'B', 23.50, 95.00, '2024-02-15', '2024-02-28',
     'Performance-focused messaging outperformed feature messaging. Downtime reduction resonated strongly with operations buyers.'),
    ('ABT-002', 'CMP-2024-001', 'Creative Format Test', 
     'Static image with product showcase', 
     'Video testimonial from customer',
     'B', 18.20, 92.00, '2024-02-01', '2024-02-14',
     'Video content drove higher engagement. Customer testimonials built trust. Recommend increasing video budget.'),
    ('ABT-003', 'CMP-2024-007', 'TikTok Hook Test', 
     'Day in the life of an engineer', 
     'Behind the scenes factory tour',
     'A', 8.50, 78.00, '2024-03-15', '2024-03-28',
     'Authenticity won. Day-in-life content felt more genuine than polished factory tours. Consider employee-generated content.');

-- ============================================================================
-- SECTION 5: BRAND DOCUMENTS (For Cortex Search)
-- ============================================================================

CREATE OR REPLACE TABLE BRAND_DOCUMENTS (
    doc_id INT AUTOINCREMENT PRIMARY KEY,
    doc_title VARCHAR(200),
    doc_category VARCHAR(50),
    doc_version VARCHAR(20),
    last_updated DATE,
    doc_content VARCHAR(16000)
);

INSERT INTO BRAND_DOCUMENTS (doc_title, doc_category, doc_version, last_updated, doc_content) VALUES

('Apex Industrial Brand Guidelines', 'BRAND_GUIDE', '3.0', '2024-01-15',
'APEX INDUSTRIAL BRAND GUIDELINES
Version 3.0 | Effective January 2024

BRAND VOICE & TONE
Our voice is confident, expert, and approachable. We speak as trusted advisors to manufacturing professionals.

DO:
- Use active voice ("Our pumps reduce downtime" not "Downtime is reduced by our pumps")
- Lead with customer benefits, not features
- Include specific metrics and proof points when available
- Address the reader directly as "you"

DO NOT:
- Use ALL CAPS for emphasis (use bold instead)
- Use exclamation points in headlines
- Make unsubstantiated claims
- Use jargon without explanation

HEADLINE GUIDELINES
- Maximum 10 words for display ads
- Lead with the benefit or outcome
- Include numbers when possible (40% faster, 3x more reliable)
- Avoid superlatives without proof (best, fastest, #1)

COLOR PALETTE
Primary: Apex Blue (#0A3D62)
Secondary: Industrial Orange (#E55B3C)
Accent: Steel Gray (#5D6D7E)
Never use: Bright red, neon colors, gradients with more than 2 colors

IMAGERY GUIDELINES
- Real photos preferred over illustrations
- Show products in use, not isolated
- Include diverse representation
- Avoid stock photo clichés (handshakes, pointing at screens)

LOGO USAGE
- Minimum clear space: 20px on all sides
- Never stretch, rotate, or modify colors
- On dark backgrounds, use white version
- Minimum size: 120px wide for digital'),

('Q1 2024 Campaign Brief - Brand Awareness', 'CAMPAIGN_BRIEF', '1.0', '2024-01-10',
'Q1 2024 BRAND AWARENESS CAMPAIGN BRIEF

CAMPAIGN OBJECTIVE
Increase unaided brand awareness among manufacturing decision-makers by 15% by end of Q1.

TARGET AUDIENCE
Primary: Operations Directors and VPs at mid-market manufacturing companies (500-5000 employees)
Secondary: Procurement managers with equipment purchasing authority
Geography: North America, with focus on Midwest manufacturing belt

KEY MESSAGES
1. Apex Industrial has 40+ years of reliability
2. Our products reduce unplanned downtime by average 35%
3. Same-day shipping on 90% of parts

COMPETITIVE POSITIONING
We are NOT competing on price. Our positioning is premium reliability.
Competitors to monitor: Parker Hannifin, Eaton, Bosch Rexroth

CHANNELS
- LinkedIn (primary - decision maker reach)
- YouTube pre-roll (awareness/education)
- Display retargeting (frequency)
- Trade publications (credibility)

BUDGET: $150,000
TIMELINE: January 15 - March 31, 2024

SUCCESS METRICS
- 2M+ impressions
- 15% lift in branded search volume
- 10% increase in website traffic from target industries'),

('Competitor Analysis Q1 2024', 'COMPETITIVE_INTEL', '1.2', '2024-02-20',
'COMPETITOR ANALYSIS - Q1 2024

PARKER HANNIFIN
- Positioning: Engineering leadership, broadest portfolio
- Recent moves: Heavy investment in electrification messaging
- Weakness: Perceived as expensive, slow to quote
- Ad spend estimate: $2M/quarter digital

EATON
- Positioning: Power management expertise
- Recent moves: Sustainability/efficiency focus in all creative
- Weakness: Complex buying process, generalist perception
- Ad spend estimate: $1.5M/quarter digital

BOSCH REXROTH
- Positioning: German engineering, precision
- Recent moves: Pushing Industry 4.0 / IoT connectivity
- Weakness: Seen as over-engineered for simple applications
- Ad spend estimate: $1M/quarter digital

OUR OPPORTUNITY
None of the major competitors are effectively targeting the mid-market sweet spot.
They all skew enterprise. We can own the 500-2000 employee segment with:
- Faster response times
- Simpler buying process
- Better value positioning (not cheap, but fair)

RECOMMENDED RESPONSE
- Emphasize speed and simplicity in Q2 messaging
- Create comparison content (without naming competitors directly)
- Target their branded search terms with our value prop'),

('Promotional Messaging Guidelines', 'BRAND_GUIDE', '2.1', '2024-01-20',
'PROMOTIONAL MESSAGING GUIDELINES

FLASH SALES & DISCOUNTS
We run limited promotions to drive urgency, but we protect brand value.

APPROVED PROMOTIONAL LANGUAGE:
- "Limited time offer"
- "Save [X]% through [date]"
- "Exclusive pricing for [segment]"
- "Free shipping on orders over $500"

NOT APPROVED:
- "Lowest prices ever" (devalues brand)
- "Blowout sale" (too aggressive)
- "Everything must go" (clearance perception)
- BOGO offers (cheapens premium positioning)

DISCOUNT LIMITS
- Maximum advertised discount: 25%
- Never discount new products in first 90 days
- Bundling preferred over straight discounts

URGENCY MESSAGING
- Use real deadlines only (no fake countdown timers)
- "Ends [specific date]" preferred over "Limited time"
- Stock scarcity must be real ("Only 12 left in stock")

EMAIL PROMOTIONAL FREQUENCY
- Maximum 1 promotional email per week to any subscriber
- Promotional emails must be balanced with educational content
- Never send more than 2 promotional emails about the same offer

SOCIAL MEDIA PROMOTIONS
- Promotions should be max 20% of social content calendar
- Always include regular price for context
- Use platform-native formats (no text-heavy images)'),

('Summer Flash Sale Campaign Brief', 'CAMPAIGN_BRIEF', '1.0', '2024-05-15',
'SUMMER FLASH SALE CAMPAIGN BRIEF

CAMPAIGN DATES: June 15-22, 2024

OBJECTIVE
Drive $500K in revenue during a typically slow period.
Clear Q2 inventory to make room for new product launches.

PRODUCTS INCLUDED
- Industrial Bearing Assembly (SKU-001) - 15% off
- Steel Mounting Brackets (SKU-003) - 20% off
- Pneumatic Valve Sets (SKU-008) - 15% off

NOT INCLUDED (per brand guidelines - no discounts on new products):
- Hydraulic Pump Unit (SKU-004) - launched February

TARGET AUDIENCE
- Existing customers (email list)
- Website visitors (retargeting)
- Past purchasers who haven''t ordered in 6+ months

CHANNELS
- Email (primary): 3-email sequence
- Retargeting display
- Organic social (announcement only, no paid boost)

KEY MESSAGES
- Summer maintenance season = stock up now
- Limited quantities at these prices
- Free expedited shipping for orders over $1,000

BUDGET: $25,000

CREATIVE REQUIREMENTS
- Email: Clean, product-focused, clear CTA
- Display: 300x250 and 728x90 required
- Follow promotional messaging guidelines (no "blowout" language)');

-- ============================================================================
-- SECTION 6: CORTEX SEARCH SERVICE
-- ============================================================================

CREATE OR REPLACE CORTEX SEARCH SERVICE BRAND_SEARCH_SERVICE
  ON doc_content
  ATTRIBUTES doc_title, doc_category
  WAREHOUSE = HOL_AGENT_WH
  TARGET_LAG = '1 day'
  AS (
    SELECT 
      doc_content,
      doc_title,
      doc_category
    FROM BRAND_DOCUMENTS
  );

SELECT '✅ Cortex Search service created (indexing in background)' as status;

-- ============================================================================
-- SECTION 7: ANALYSIS VIEWS
-- ============================================================================

CREATE OR REPLACE VIEW CAMPAIGN_SUMMARY AS
SELECT 
    c.campaign_id,
    c.campaign_name,
    c.campaign_type,
    c.objective,
    c.target_audience,
    c.start_date,
    c.end_date,
    c.budget,
    c.status,
    COALESCE(SUM(p.impressions), 0) as total_impressions,
    COALESCE(SUM(p.clicks), 0) as total_clicks,
    COALESCE(SUM(p.conversions), 0) as total_conversions,
    COALESCE(SUM(p.spend), 0) as total_spend,
    COALESCE(SUM(p.revenue), 0) as total_revenue,
    CASE WHEN SUM(p.impressions) > 0 
         THEN ROUND(SUM(p.clicks)::FLOAT / SUM(p.impressions) * 100, 2) 
         ELSE 0 END as ctr,
    CASE WHEN SUM(p.clicks) > 0 
         THEN ROUND(SUM(p.conversions)::FLOAT / SUM(p.clicks) * 100, 2) 
         ELSE 0 END as conversion_rate,
    CASE WHEN SUM(p.spend) > 0 
         THEN ROUND(SUM(p.revenue) / SUM(p.spend), 2) 
         ELSE 0 END as roas,
    CASE WHEN SUM(p.conversions) > 0 
         THEN ROUND(SUM(p.spend) / SUM(p.conversions), 2) 
         ELSE 0 END as cost_per_conversion
FROM CAMPAIGNS c
LEFT JOIN CAMPAIGN_PERFORMANCE p ON c.campaign_id = p.campaign_id
GROUP BY c.campaign_id, c.campaign_name, c.campaign_type, c.objective, 
         c.target_audience, c.start_date, c.end_date, c.budget, c.status;

CREATE OR REPLACE VIEW CHANNEL_PERFORMANCE AS
SELECT 
    ch.channel_id,
    ch.channel_name,
    ch.channel_type,
    c.campaign_id,
    c.campaign_name,
    SUM(p.impressions) as total_impressions,
    SUM(p.clicks) as total_clicks,
    SUM(p.conversions) as total_conversions,
    SUM(p.spend) as total_spend,
    SUM(p.revenue) as total_revenue,
    CASE WHEN SUM(p.impressions) > 0 
         THEN ROUND(SUM(p.clicks)::FLOAT / SUM(p.impressions) * 100, 2) 
         ELSE 0 END as ctr,
    CASE WHEN SUM(p.spend) > 0 
         THEN ROUND(SUM(p.revenue) / SUM(p.spend), 2) 
         ELSE 0 END as roas
FROM CAMPAIGN_PERFORMANCE p
JOIN CHANNELS ch ON p.channel_id = ch.channel_id
JOIN CAMPAIGNS c ON p.campaign_id = c.campaign_id
GROUP BY ch.channel_id, ch.channel_name, ch.channel_type, c.campaign_id, c.campaign_name;

-- ============================================================================
-- SECTION 8: SEMANTIC MODEL FOR CAMPAIGN DATA AGENT
-- ============================================================================

CALL SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML(
    'HOL_AUTOMATION.MARKETING',
    '
name: CAMPAIGN_ANALYTICS_MODEL
description: "Marketing campaign performance analytics - spend, impressions, conversions, ROAS"

tables:
  - name: campaigns
    description: "Marketing campaign performance summary with key metrics"
    base_table:
      database: HOL_AUTOMATION
      schema: MARKETING
      table: CAMPAIGN_SUMMARY
    
    dimensions:
      - name: campaign_id
        description: "Unique campaign identifier"
        expr: campaign_id
        data_type: VARCHAR
        unique: true
      
      - name: campaign_name
        synonyms: ["campaign", "name"]
        description: "Name of the marketing campaign"
        expr: campaign_name
        data_type: VARCHAR
      
      - name: campaign_type
        synonyms: ["type", "category"]
        description: "Type of campaign: Brand, Product, Event, Retargeting, Content, Promotional, Employer Brand"
        expr: campaign_type
        data_type: VARCHAR
        is_enum: true
      
      - name: objective
        synonyms: ["goal"]
        description: "Campaign objective: Awareness, Lead Gen, Conversion"
        expr: objective
        data_type: VARCHAR
        is_enum: true
      
      - name: target_audience
        synonyms: ["audience", "target"]
        description: "Target audience for the campaign"
        expr: target_audience
        data_type: VARCHAR
      
      - name: status
        synonyms: ["campaign status"]
        description: "Campaign status: PLANNED, ACTIVE, COMPLETED, PAUSED"
        expr: status
        data_type: VARCHAR
        is_enum: true

    time_dimensions:
      - name: start_date
        description: "Campaign start date"
        expr: start_date
        data_type: DATE
      
      - name: end_date
        description: "Campaign end date"
        expr: end_date
        data_type: DATE

    facts:
      - name: budget
        synonyms: ["allocated budget"]
        description: "Total budget allocated to campaign"
        expr: budget
        data_type: NUMBER
      
      - name: total_impressions
        synonyms: ["impressions", "views"]
        description: "Total ad impressions"
        expr: total_impressions
        data_type: NUMBER
      
      - name: total_clicks
        synonyms: ["clicks"]
        description: "Total clicks on ads"
        expr: total_clicks
        data_type: NUMBER
      
      - name: total_conversions
        synonyms: ["conversions", "sales"]
        description: "Total conversions/purchases"
        expr: total_conversions
        data_type: NUMBER
      
      - name: total_spend
        synonyms: ["spend", "cost", "ad spend"]
        description: "Total amount spent"
        expr: total_spend
        data_type: NUMBER
      
      - name: total_revenue
        synonyms: ["revenue", "sales revenue"]
        description: "Total revenue generated"
        expr: total_revenue
        data_type: NUMBER
      
      - name: ctr
        synonyms: ["click through rate", "click rate"]
        description: "Click-through rate as percentage"
        expr: ctr
        data_type: NUMBER
      
      - name: conversion_rate
        synonyms: ["cvr"]
        description: "Conversion rate as percentage"
        expr: conversion_rate
        data_type: NUMBER
      
      - name: roas
        synonyms: ["return on ad spend", "roi"]
        description: "Return on ad spend (revenue/spend)"
        expr: roas
        data_type: NUMBER
      
      - name: cost_per_conversion
        synonyms: ["cpa", "cost per acquisition"]
        description: "Cost per conversion"
        expr: cost_per_conversion
        data_type: NUMBER

    metrics:
      - name: total_campaign_spend
        description: "Sum of all campaign spend"
        expr: SUM(total_spend)
      
      - name: total_campaign_revenue
        description: "Sum of all campaign revenue"
        expr: SUM(total_revenue)
      
      - name: average_roas
        description: "Average return on ad spend"
        expr: AVG(roas)

  - name: channel_performance
    description: "Performance breakdown by marketing channel"
    base_table:
      database: HOL_AUTOMATION
      schema: MARKETING
      table: CHANNEL_PERFORMANCE
    
    dimensions:
      - name: channel_name
        synonyms: ["channel", "platform"]
        description: "Marketing channel name"
        expr: channel_name
        data_type: VARCHAR
      
      - name: channel_type
        description: "Channel type: Paid Search, Paid Social, Owned, Programmatic, Video"
        expr: channel_type
        data_type: VARCHAR
        is_enum: true
      
      - name: campaign_name
        description: "Associated campaign"
        expr: campaign_name
        data_type: VARCHAR

    facts:
      - name: impressions
        description: "Channel impressions"
        expr: total_impressions
        data_type: NUMBER
      
      - name: clicks
        description: "Channel clicks"
        expr: total_clicks
        data_type: NUMBER
      
      - name: conversions
        description: "Channel conversions"
        expr: total_conversions
        data_type: NUMBER
      
      - name: spend
        description: "Channel spend"
        expr: total_spend
        data_type: NUMBER
      
      - name: revenue
        description: "Channel revenue"
        expr: total_revenue
        data_type: NUMBER
      
      - name: channel_roas
        synonyms: ["roas"]
        description: "Channel return on ad spend"
        expr: roas
        data_type: NUMBER

verified_queries:
  - name: "campaign_performance_overview"
    question: "How are our campaigns performing?"
    use_as_onboarding_question: true
    sql: |
      SELECT campaign_name, campaign_type, status, total_spend, total_revenue, 
             roas, conversion_rate, total_conversions
      FROM __campaigns
      ORDER BY total_spend DESC

  - name: "underperforming_campaigns"
    question: "Which campaigns are underperforming?"
    use_as_onboarding_question: true
    sql: |
      SELECT campaign_name, campaign_type, total_spend, total_revenue, roas,
             conversion_rate, total_conversions
      FROM __campaigns
      WHERE roas < 2 OR conversion_rate < 1
      ORDER BY roas ASC

  - name: "channel_breakdown"
    question: "How are different channels performing?"
    use_as_onboarding_question: true
    sql: |
      SELECT channel_name, channel_type, 
             SUM(impressions) as total_impressions,
             SUM(spend) as total_spend, 
             SUM(revenue) as total_revenue,
             ROUND(SUM(revenue) / NULLIF(SUM(spend), 0), 2) as roas
      FROM __channel_performance
      GROUP BY channel_name, channel_type
      ORDER BY total_spend DESC

  - name: "top_performing"
    question: "What are our best performing campaigns?"
    sql: |
      SELECT campaign_name, total_spend, total_revenue, roas, conversion_rate
      FROM __campaigns
      WHERE status IN (''ACTIVE'', ''COMPLETED'')
      ORDER BY roas DESC
      LIMIT 5
'
);

SELECT '✅ Semantic view created: HOL_AUTOMATION.MARKETING.CAMPAIGN_ANALYTICS_MODEL' as status;

-- ============================================================================
-- SECTION 9: MARKETING COMMANDER AGENT
-- ============================================================================
-- Single agent with three capabilities:
-- 1. Cortex Analyst - campaign performance metrics
-- 2. Cortex Search - brand guidelines and documents
-- 3. Ops Agent - check inventory before promoting products

CREATE OR REPLACE AGENT HOL_AUTOMATION.MARKETING.MARKETING_ASSISTANT
  COMMENT = 'Marketing Campaign Assistant - data, brand knowledge, and inventory checks'
  FROM SPECIFICATION
  $$
  models:
    orchestration: claude-3-5-sonnet

  orchestration:
    budget:
      seconds: 60
      tokens: 16000

  instructions:
    system: |
      You are the Marketing Campaign Commander at Apex Industrial - a senior 
      marketing strategist assistant with access to three powerful capabilities:
      
      1. CAMPAIGN ANALYTICS: Query campaign performance data - spend, impressions, 
         clicks, conversions, ROAS, channel effectiveness.
      
      2. BRAND KNOWLEDGE: Search brand guidelines, campaign briefs, promotional 
         rules, and competitive intelligence documents.
      
      3. INVENTORY CHECK: Query operations data to check inventory levels, stock 
         status, and supplier information before recommending promotions.
      
      WHEN TO USE WHICH:
      - "How is TikTok performing?" → Campaign Analytics
      - "What are promo guidelines?" → Brand Knowledge Search
      - "Do we have inventory for bearings?" → Inventory Check
      - "Can we promote SKU-001?" → Inventory Check + Brand Knowledge
      
      CRITICAL: Before recommending any product promotion, ALWAYS:
      1. Check inventory levels (use ops_inventory tool)
      2. Check promotional restrictions (use brand_knowledge tool)
      
      Be actionable. Give specific numbers. Quote guidelines when relevant.
      If inventory is low or supplier is INACTIVE, warn clearly before recommending.
    
    response: |
      - Include specific metrics when discussing performance (ROAS, spend, conversions)
      - Quote brand guidelines directly when answering policy questions
      - When recommending promotions, confirm inventory status first
      - Warn about supplier issues (INACTIVE status) when found

  tools:
    - tool_spec:
        type: cortex_analyst_text_to_sql
        name: campaign_analytics
        description: "Query marketing campaign performance data including spend, impressions, clicks, conversions, ROAS, CTR, and channel-level metrics. Use for any question about campaign numbers or performance."
    
    - tool_spec:
        type: cortex_search
        name: brand_knowledge
        description: "Search brand guidelines, promotional messaging rules, campaign briefs, and competitive intelligence. Use for questions about what we can/cannot say, brand voice, campaign strategy, or competitor analysis."
    
    - tool_spec:
        type: cortex_analyst_text_to_sql
        name: ops_inventory
        description: "Check inventory levels, stock status, product availability, and supplier information. ALWAYS use this before recommending product promotions to ensure we have stock to sell. Can identify supplier issues (INACTIVE suppliers)."


  $$;

-- ============================================================================
-- SECTION 10: VERIFICATION
-- ============================================================================

SELECT 'Campaigns' as table_name, COUNT(*) as row_count FROM CAMPAIGNS
UNION ALL
SELECT 'Performance Records', COUNT(*) FROM CAMPAIGN_PERFORMANCE
UNION ALL
SELECT 'Channels', COUNT(*) FROM CHANNELS
UNION ALL
SELECT 'Brand Documents', COUNT(*) FROM BRAND_DOCUMENTS
UNION ALL
SELECT 'A/B Tests', COUNT(*) FROM AB_TESTS;

-- Show the problem campaign for demo
SELECT '--- UNDERPERFORMING CAMPAIGN FOR DEMO ---' as note;
SELECT campaign_name, total_spend, total_revenue, roas, conversion_rate
FROM CAMPAIGN_SUMMARY
WHERE roas < 1
ORDER BY roas;

-- Verify agents
SHOW AGENTS IN SCHEMA HOL_AUTOMATION.MARKETING;

SELECT '✅ Marketing Campaign Commander setup complete!' as status;
SELECT 'Agent capabilities: Campaign Analytics + Brand Search + Ops Agent' as note;
SELECT '' as note;
SELECT '🎯 KEY DEMO QUESTION:' as note;
SELECT 'I want to run a flash sale on Industrial Bearing Assemblies. Check if we have inventory and what promotional rules I need to follow.' as demo_prompt;
