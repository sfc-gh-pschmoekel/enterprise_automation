/*=============================================================================
  ENTERPRISE WORKFLOW AUTOMATION - HANDS ON LAB
  Demo 2: The Ops Monitor
=============================================================================*/

USE ROLE SYSADMIN;
USE DATABASE HOL_AUTOMATION;

CREATE SCHEMA IF NOT EXISTS HOL_AUTOMATION.OPERATIONS;
USE SCHEMA OPERATIONS;

USE WAREHOUSE HOL_AGENT_WH;

-- ============================================================================
-- SECTION 1: WAREHOUSES
-- ============================================================================

CREATE OR REPLACE TABLE WAREHOUSES (
    warehouse_id VARCHAR(10) PRIMARY KEY,
    warehouse_name VARCHAR(100),
    location VARCHAR(100),
    region VARCHAR(50),
    capacity_units INT,
    manager_name VARCHAR(100),
    manager_email VARCHAR(100),
    manager_phone VARCHAR(20),
    status VARCHAR(20) DEFAULT 'ACTIVE'
);

INSERT INTO WAREHOUSES VALUES
    ('WH001', 'East Coast Distribution', 'Newark, NJ', 'Northeast', 50000, 'Maria Santos', 'maria.santos@company.com', '555-0101', 'ACTIVE'),
    ('WH002', 'Midwest Hub', 'Chicago, IL', 'Midwest', 75000, 'James Wilson', 'james.wilson@company.com', '555-0102', 'ACTIVE'),
    ('WH003', 'West Coast Fulfillment', 'Los Angeles, CA', 'West', 60000, 'Kevin Chen', 'kevin.chen@company.com', '555-0103', 'ACTIVE'),
    ('WH004', 'Southeast Center', 'Atlanta, GA', 'Southeast', 40000, 'Patricia Johnson', 'patricia.johnson@company.com', '555-0104', 'ACTIVE'),
    ('WH005', 'Pacific Northwest', 'Seattle, WA', 'West', 35000, 'Robert Kim', 'robert.kim@company.com', '555-0105', 'ACTIVE');

-- ============================================================================
-- SECTION 2: PRODUCTS
-- ============================================================================

CREATE OR REPLACE TABLE PRODUCTS (
    product_id VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(200),
    category VARCHAR(50),
    unit_cost DECIMAL(10,2),
    unit_price DECIMAL(10,2),
    reorder_point INT,
    reorder_quantity INT,
    lead_time_days INT,
    supplier_name VARCHAR(100),
    supplier_status VARCHAR(20)
);

-- NOTE: SKU-001 is supplied by Midwest Manufacturing (INACTIVE in Finance system!)
INSERT INTO PRODUCTS VALUES
    ('SKU-001', 'Industrial Bearing Assembly', 'Parts', 45.00, 89.00, 500, 1000, 7, 'Midwest Manufacturing', 'INACTIVE'),
    ('SKU-002', 'Heavy Duty Motor', 'Equipment', 350.00, 649.00, 100, 200, 14, 'Atlas Motors', 'ACTIVE'),
    ('SKU-003', 'Steel Mounting Bracket', 'Parts', 12.50, 24.00, 1000, 2000, 5, 'SteelCo Industries', 'ACTIVE'),
    ('SKU-004', 'Hydraulic Pump Unit', 'Equipment', 890.00, 1599.00, 50, 100, 21, 'HydraForce Inc', 'ACTIVE'),
    ('SKU-005', 'Control Panel Display', 'Electronics', 225.00, 449.00, 150, 300, 10, 'TechDisplay Corp', 'ACTIVE'),
    ('SKU-006', 'Safety Sensor Kit', 'Electronics', 175.00, 329.00, 200, 400, 7, 'SafeTech Solutions', 'ACTIVE'),
    ('SKU-007', 'Conveyor Belt Section', 'Parts', 85.00, 159.00, 300, 600, 12, 'ConveyorMax', 'ACTIVE'),
    ('SKU-008', 'Pneumatic Valve Set', 'Parts', 65.00, 119.00, 400, 800, 6, 'AirFlow Systems', 'ACTIVE');

-- ============================================================================
-- SECTION 3: INVENTORY
-- ============================================================================

CREATE OR REPLACE TABLE INVENTORY (
    inventory_id INT AUTOINCREMENT PRIMARY KEY,
    warehouse_id VARCHAR(10) REFERENCES WAREHOUSES(warehouse_id),
    product_id VARCHAR(20) REFERENCES PRODUCTS(product_id),
    quantity_on_hand INT,
    quantity_reserved INT DEFAULT 0,
    last_count_date DATE,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

INSERT INTO INVENTORY (warehouse_id, product_id, quantity_on_hand, quantity_reserved, last_count_date) VALUES
    ('WH001', 'SKU-001', 850, 50, '2024-03-15'),
    ('WH001', 'SKU-002', 180, 20, '2024-03-15'),
    ('WH001', 'SKU-003', 1800, 200, '2024-03-15'),
    ('WH001', 'SKU-004', 75, 10, '2024-03-15'),
    ('WH001', 'SKU-005', 45, 5, '2024-03-15'),
    ('WH001', 'SKU-006', 350, 30, '2024-03-15'),
    ('WH002', 'SKU-001', 150, 0, '2024-03-15'),
    ('WH002', 'SKU-002', 220, 40, '2024-03-15'),
    ('WH002', 'SKU-003', 2500, 100, '2024-03-15'),
    ('WH002', 'SKU-004', 95, 15, '2024-03-15'),
    ('WH002', 'SKU-007', 450, 50, '2024-03-15'),
    ('WH002', 'SKU-008', 600, 80, '2024-03-15'),
    ('WH003', 'SKU-001', 400, 100, '2024-03-15'),
    ('WH003', 'SKU-002', 85, 25, '2024-03-15'),
    ('WH003', 'SKU-005', 280, 30, '2024-03-15'),
    ('WH003', 'SKU-006', 180, 20, '2024-03-15'),
    ('WH003', 'SKU-007', 550, 100, '2024-03-15'),
    ('WH004', 'SKU-002', 150, 20, '2024-03-15'),
    ('WH004', 'SKU-003', 1500, 150, '2024-03-15'),
    ('WH004', 'SKU-004', 80, 10, '2024-03-15'),
    ('WH004', 'SKU-008', 900, 100, '2024-03-15'),
    ('WH005', 'SKU-001', 600, 50, '2024-03-15'),
    ('WH005', 'SKU-005', 20, 15, '2024-03-15'),
    ('WH005', 'SKU-006', 400, 40, '2024-03-15'),
    ('WH005', 'SKU-007', 200, 50, '2024-03-15');

-- ============================================================================
-- SECTION 4: INVENTORY HISTORY (For Anomaly Detection)
-- ============================================================================

CREATE OR REPLACE TABLE INVENTORY_HISTORY (
    history_id INT AUTOINCREMENT PRIMARY KEY,
    warehouse_id VARCHAR(10),
    product_id VARCHAR(20),
    quantity INT,
    recorded_date DATE
);

-- The ANOMALY: WH002 SKU-001 dropped 87% overnight
-- ROOT CAUSE: Midwest Manufacturing (supplier) went INACTIVE - no new shipments!
INSERT INTO INVENTORY_HISTORY (warehouse_id, product_id, quantity, recorded_date) VALUES
    ('WH002', 'SKU-001', 1250, '2024-03-10'),
    ('WH002', 'SKU-001', 1230, '2024-03-11'),
    ('WH002', 'SKU-001', 1210, '2024-03-12'),
    ('WH002', 'SKU-001', 1200, '2024-03-13'),
    ('WH002', 'SKU-001', 1180, '2024-03-14'),
    ('WH002', 'SKU-001', 150, '2024-03-15'),
    ('WH001', 'SKU-001', 920, '2024-03-10'),
    ('WH001', 'SKU-001', 900, '2024-03-11'),
    ('WH001', 'SKU-001', 880, '2024-03-12'),
    ('WH001', 'SKU-001', 865, '2024-03-13'),
    ('WH001', 'SKU-001', 855, '2024-03-14'),
    ('WH001', 'SKU-001', 850, '2024-03-15');

-- ============================================================================
-- SECTION 5: CUSTOMERS
-- ============================================================================

CREATE OR REPLACE TABLE CUSTOMERS (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100),
    customer_type VARCHAR(50),
    account_tier VARCHAR(20),
    primary_contact VARCHAR(100),
    contact_email VARCHAR(100)
);

INSERT INTO CUSTOMERS VALUES
    ('CUST-001', 'Caterpillar Inc', 'Manufacturing', 'PLATINUM', 'Sarah Miller', 'sarah.miller@cat.com'),
    ('CUST-002', 'John Deere', 'Manufacturing', 'GOLD', 'Tom Brown', 'tom.brown@deere.com'),
    ('CUST-003', 'Boeing', 'Aerospace', 'PLATINUM', 'Jennifer Lee', 'jennifer.lee@boeing.com'),
    ('CUST-004', 'Tesla', 'Automotive', 'PLATINUM', 'Mike Chen', 'mike.chen@tesla.com'),
    ('CUST-005', 'Ford Motor', 'Automotive', 'GOLD', 'Lisa Park', 'lisa.park@ford.com'),
    ('CUST-006', 'Amazon Robotics', 'Technology', 'PLATINUM', 'David Kim', 'david.kim@amazon.com'),
    ('CUST-007', 'SpaceX', 'Aerospace', 'PLATINUM', 'Emily White', 'emily.white@spacex.com');

-- ============================================================================
-- SECTION 6: ORDERS
-- ============================================================================

CREATE OR REPLACE TABLE ORDERS (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) REFERENCES CUSTOMERS(customer_id),
    order_date DATE,
    required_date DATE,
    warehouse_id VARCHAR(10) REFERENCES WAREHOUSES(warehouse_id),
    status VARCHAR(20),
    total_amount DECIMAL(12,2),
    priority VARCHAR(10) DEFAULT 'NORMAL'
);

INSERT INTO ORDERS VALUES
    ('ORD-2024-001', 'CUST-001', '2024-03-14', '2024-03-20', 'WH002', 'PROCESSING', 45000.00, 'HIGH'),
    ('ORD-2024-002', 'CUST-002', '2024-03-14', '2024-03-25', 'WH002', 'PENDING', 28000.00, 'NORMAL'),
    ('ORD-2024-003', 'CUST-003', '2024-03-15', '2024-03-18', 'WH003', 'PENDING', 125000.00, 'URGENT'),
    ('ORD-2024-004', 'CUST-004', '2024-03-15', '2024-03-22', 'WH001', 'PROCESSING', 67000.00, 'HIGH'),
    ('ORD-2024-005', 'CUST-005', '2024-03-15', '2024-03-28', 'WH004', 'PENDING', 33000.00, 'NORMAL'),
    ('ORD-2024-006', 'CUST-006', '2024-03-15', '2024-03-17', 'WH002', 'PENDING', 89000.00, 'URGENT'),
    ('ORD-2024-007', 'CUST-007', '2024-03-15', '2024-03-19', 'WH003', 'PENDING', 156000.00, 'URGENT');

-- ============================================================================
-- SECTION 7: ORDER ITEMS
-- ============================================================================

CREATE OR REPLACE TABLE ORDER_ITEMS (
    item_id INT AUTOINCREMENT PRIMARY KEY,
    order_id VARCHAR(20) REFERENCES ORDERS(order_id),
    product_id VARCHAR(20) REFERENCES PRODUCTS(product_id),
    quantity INT,
    unit_price DECIMAL(10,2),
    line_total DECIMAL(12,2)
);

INSERT INTO ORDER_ITEMS (order_id, product_id, quantity, unit_price, line_total) VALUES
    ('ORD-2024-001', 'SKU-001', 500, 89.00, 44500.00),
    ('ORD-2024-001', 'SKU-003', 100, 24.00, 2400.00),
    ('ORD-2024-002', 'SKU-001', 300, 89.00, 26700.00),
    ('ORD-2024-002', 'SKU-003', 500, 24.00, 12000.00),
    ('ORD-2024-003', 'SKU-004', 80, 1599.00, 127920.00),
    ('ORD-2024-006', 'SKU-001', 800, 89.00, 71200.00),
    ('ORD-2024-006', 'SKU-006', 150, 329.00, 49350.00),
    ('ORD-2024-007', 'SKU-004', 100, 1599.00, 159900.00);

-- ============================================================================
-- SECTION 8: ANALYSIS VIEWS
-- ============================================================================

CREATE OR REPLACE VIEW INVENTORY_STATUS AS
SELECT 
    i.warehouse_id,
    w.warehouse_name,
    w.location,
    w.region,
    w.manager_name,
    w.manager_email,
    w.manager_phone,
    i.product_id,
    p.product_name,
    p.category as product_category,
    p.unit_cost,
    p.supplier_name,
    p.supplier_status,
    i.quantity_on_hand,
    i.quantity_reserved,
    i.quantity_on_hand - i.quantity_reserved as quantity_available,
    p.reorder_point,
    (i.quantity_on_hand * p.unit_cost) as inventory_value,
    CASE 
        WHEN i.quantity_on_hand - i.quantity_reserved < p.reorder_point * 0.5 THEN 'CRITICAL'
        WHEN i.quantity_on_hand - i.quantity_reserved < p.reorder_point THEN 'LOW'
        ELSE 'HEALTHY'
    END as stock_status,
    CASE 
        WHEN p.supplier_status = 'INACTIVE' THEN 'SUPPLIER_ISSUE'
        ELSE 'OK'
    END as supply_chain_status
FROM INVENTORY i
JOIN WAREHOUSES w ON i.warehouse_id = w.warehouse_id
JOIN PRODUCTS p ON i.product_id = p.product_id;

CREATE OR REPLACE VIEW INVENTORY_CHANGES AS
SELECT 
    h1.warehouse_id,
    w.warehouse_name,
    w.manager_name,
    w.manager_email,
    h1.product_id,
    p.product_name,
    h2.quantity as previous_quantity,
    h1.quantity as current_quantity,
    h2.quantity - h1.quantity as quantity_change,
    ROUND(((h2.quantity - h1.quantity)::FLOAT / NULLIF(h2.quantity, 0) * 100), 1) as pct_change,
    h2.recorded_date as previous_date,
    h1.recorded_date as current_date,
    CASE 
        WHEN ((h2.quantity - h1.quantity)::FLOAT / NULLIF(h2.quantity, 0) * 100) > 50 THEN 'CRITICAL'
        WHEN ((h2.quantity - h1.quantity)::FLOAT / NULLIF(h2.quantity, 0) * 100) > 25 THEN 'HIGH'
        ELSE 'NORMAL'
    END as change_severity
FROM INVENTORY_HISTORY h1
JOIN INVENTORY_HISTORY h2 
    ON h1.warehouse_id = h2.warehouse_id 
    AND h1.product_id = h2.product_id
    AND h2.recorded_date = (
        SELECT MAX(recorded_date) 
        FROM INVENTORY_HISTORY 
        WHERE warehouse_id = h1.warehouse_id 
        AND product_id = h1.product_id 
        AND recorded_date < h1.recorded_date
    )
JOIN WAREHOUSES w ON h1.warehouse_id = w.warehouse_id
JOIN PRODUCTS p ON h1.product_id = p.product_id
WHERE h1.recorded_date = (
    SELECT MAX(recorded_date) 
    FROM INVENTORY_HISTORY 
    WHERE warehouse_id = h1.warehouse_id 
    AND product_id = h1.product_id
);

CREATE OR REPLACE VIEW ORDERS_AT_RISK AS
SELECT 
    o.order_id,
    c.customer_name,
    c.account_tier,
    o.order_date,
    o.required_date,
    o.status as order_status,
    o.priority,
    o.total_amount,
    w.warehouse_id,
    w.warehouse_name,
    w.manager_name as warehouse_manager,
    w.manager_email as warehouse_manager_email,
    oi.product_id,
    p.product_name,
    oi.quantity as quantity_needed,
    COALESCE(inv.quantity_on_hand - inv.quantity_reserved, 0) as quantity_available,
    CASE 
        WHEN oi.quantity > COALESCE(inv.quantity_on_hand - inv.quantity_reserved, 0) THEN 'AT RISK'
        ELSE 'CAN FULFILL'
    END as fulfillment_status,
    oi.quantity - COALESCE(inv.quantity_on_hand - inv.quantity_reserved, 0) as quantity_shortfall
FROM ORDERS o
JOIN CUSTOMERS c ON o.customer_id = c.customer_id
JOIN ORDER_ITEMS oi ON o.order_id = oi.order_id
JOIN PRODUCTS p ON oi.product_id = p.product_id
JOIN WAREHOUSES w ON o.warehouse_id = w.warehouse_id
LEFT JOIN INVENTORY inv ON o.warehouse_id = inv.warehouse_id AND oi.product_id = inv.product_id
WHERE o.status IN ('PENDING', 'PROCESSING');

-- ============================================================================
-- SECTION 9: VERIFICATION
-- ============================================================================

SELECT 'Warehouses' as table_name, COUNT(*) as row_count FROM WAREHOUSES
UNION ALL
SELECT 'Products', COUNT(*) FROM PRODUCTS
UNION ALL
SELECT 'Inventory', COUNT(*) FROM INVENTORY
UNION ALL
SELECT 'Orders', COUNT(*) FROM ORDERS
UNION ALL
SELECT 'Order Items', COUNT(*) FROM ORDER_ITEMS;

SELECT '--- THE ANOMALY (for demo) ---' as note;
SELECT 
    warehouse_name,
    product_name,
    previous_quantity,
    current_quantity,
    quantity_change as units_lost,
    pct_change || '%' as percent_drop,
    change_severity
FROM INVENTORY_CHANGES
WHERE pct_change > 20;

SELECT '✅ Ops Monitor data setup complete!' as status;

-- ============================================================================
-- SECTION 10: SEMANTIC VIEW (For Cortex Analyst)
-- ============================================================================

-- Create the semantic view using the stored procedure
CALL SYSTEM$CREATE_SEMANTIC_VIEW_FROM_YAML(
    'HOL_AUTOMATION.OPERATIONS',
    '
name: ops_analytics
description: "Operations analytics for inventory monitoring and order fulfillment"

tables:
  - name: inventory_status
    description: "Current inventory levels across all warehouses"
    base_table:
      database: HOL_AUTOMATION
      schema: OPERATIONS
      table: INVENTORY_STATUS
    
    dimensions:
      - name: warehouse_name
        synonyms:
          - warehouse
          - distribution center
        description: "Name of the warehouse"
        expr: warehouse_name
        data_type: VARCHAR
      
      - name: warehouse_id
        description: "Warehouse identifier"
        expr: warehouse_id
        data_type: VARCHAR
      
      - name: manager_name
        synonyms:
          - warehouse manager
          - manager
        description: "Name of the warehouse manager"
        expr: manager_name
        data_type: VARCHAR
      
      - name: manager_email
        description: "Email of the warehouse manager"
        expr: manager_email
        data_type: VARCHAR
      
      - name: product_name
        synonyms:
          - product
          - item
          - SKU
        description: "Name of the product"
        expr: product_name
        data_type: VARCHAR
      
      - name: product_id
        description: "Product identifier"
        expr: product_id
        data_type: VARCHAR
      
      - name: stock_status
        synonyms:
          - inventory status
          - status
        description: "Stock status: CRITICAL, LOW, or HEALTHY"
        expr: stock_status
        data_type: VARCHAR
      
      - name: supplier_name
        synonyms:
          - supplier
          - vendor
        description: "Name of the product supplier"
        expr: supplier_name
        data_type: VARCHAR
      
      - name: supplier_status
        synonyms:
          - vendor status
        description: "Supplier status: ACTIVE or INACTIVE"
        expr: supplier_status
        data_type: VARCHAR
      
      - name: supply_chain_status
        synonyms:
          - supply status
          - supply chain
        description: "Supply chain status: OK or SUPPLIER_ISSUE"
        expr: supply_chain_status
        data_type: VARCHAR

    facts:
      - name: quantity_on_hand
        synonyms:
          - on hand
          - current stock
        description: "Current quantity in warehouse"
        expr: quantity_on_hand
        data_type: NUMBER
      
      - name: quantity_available
        synonyms:
          - available
          - available stock
        description: "Quantity available for orders"
        expr: quantity_available
        data_type: NUMBER
      
      - name: reorder_point
        description: "Minimum stock level before reorder"
        expr: reorder_point
        data_type: NUMBER
      
      - name: inventory_value
        synonyms:
          - stock value
        description: "Dollar value of inventory"
        expr: inventory_value
        data_type: NUMBER

    metrics:
      - name: total_inventory_value
        description: "Total dollar value of inventory"
        expr: SUM(inventory_value)

  - name: inventory_changes
    description: "Day-over-day inventory changes for anomaly detection"
    base_table:
      database: HOL_AUTOMATION
      schema: OPERATIONS
      table: INVENTORY_CHANGES
    
    dimensions:
      - name: warehouse_name
        description: "Warehouse name"
        expr: warehouse_name
        data_type: VARCHAR
      
      - name: manager_name
        description: "Warehouse manager"
        expr: manager_name
        data_type: VARCHAR
      
      - name: manager_email
        description: "Manager email"
        expr: manager_email
        data_type: VARCHAR
      
      - name: product_name
        description: "Product name"
        expr: product_name
        data_type: VARCHAR
      
      - name: change_severity
        synonyms:
          - severity
          - anomaly severity
        description: "Severity of change: CRITICAL, HIGH, or NORMAL"
        expr: change_severity
        data_type: VARCHAR

    facts:
      - name: previous_quantity
        description: "Quantity from previous day"
        expr: previous_quantity
        data_type: NUMBER
      
      - name: current_quantity
        description: "Current quantity"
        expr: current_quantity
        data_type: NUMBER
      
      - name: quantity_change
        synonyms:
          - change
          - drop
        description: "Change in quantity (positive = decrease)"
        expr: quantity_change
        data_type: NUMBER
      
      - name: pct_change
        synonyms:
          - percent change
        description: "Percentage change"
        expr: pct_change
        data_type: NUMBER

  - name: orders_at_risk
    description: "Orders that may not be fulfilled due to inventory shortages"
    base_table:
      database: HOL_AUTOMATION
      schema: OPERATIONS
      table: ORDERS_AT_RISK
    
    dimensions:
      - name: order_id
        description: "Order identifier"
        expr: order_id
        data_type: VARCHAR
      
      - name: customer_name
        synonyms:
          - customer
          - client
        description: "Customer name"
        expr: customer_name
        data_type: VARCHAR
      
      - name: priority
        synonyms:
          - urgency
        description: "Order priority: URGENT, HIGH, NORMAL"
        expr: priority
        data_type: VARCHAR
      
      - name: warehouse_name
        description: "Fulfillment warehouse"
        expr: warehouse_name
        data_type: VARCHAR
      
      - name: warehouse_manager
        description: "Warehouse manager name"
        expr: warehouse_manager
        data_type: VARCHAR
      
      - name: fulfillment_status
        description: "AT RISK or CAN FULFILL"
        expr: fulfillment_status
        data_type: VARCHAR

    facts:
      - name: total_amount
        synonyms:
          - order value
          - order total
        description: "Total order value"
        expr: total_amount
        data_type: NUMBER
      
      - name: quantity_needed
        description: "Quantity needed for order"
        expr: quantity_needed
        data_type: NUMBER
      
      - name: quantity_shortfall
        synonyms:
          - shortfall
          - shortage
        description: "Units short"
        expr: quantity_shortfall
        data_type: NUMBER

    metrics:
      - name: total_at_risk_value
        synonyms:
          - at risk value
          - risk exposure
        description: "Total value of orders at risk"
        expr: SUM(CASE WHEN fulfillment_status = ''AT RISK'' THEN total_amount ELSE 0 END)

verified_queries:
  - name: inventory_anomalies
    question: "Are there any inventory anomalies?"
    use_as_onboarding_question: true
    sql: |
      SELECT warehouse_name, product_name, previous_quantity, current_quantity, 
             quantity_change, pct_change, change_severity, manager_name, manager_email
      FROM HOL_AUTOMATION.OPERATIONS.INVENTORY_CHANGES
      WHERE pct_change > 20
      ORDER BY pct_change DESC

  - name: orders_at_risk
    question: "What orders are at risk?"
    use_as_onboarding_question: true
    sql: |
      SELECT order_id, customer_name, priority, total_amount, product_name,
             quantity_needed, quantity_available, quantity_shortfall,
             warehouse_name, warehouse_manager
      FROM HOL_AUTOMATION.OPERATIONS.ORDERS_AT_RISK
      WHERE fulfillment_status = ''AT RISK''
      ORDER BY priority DESC, total_amount DESC
'
);

SELECT '✅ Semantic view created: HOL_AUTOMATION.OPERATIONS.OPS_ANALYTICS' as status;

-- ============================================================================
-- SECTION 11: CREATE OPS AGENT (UI Instructions)
-- ============================================================================
-- ⚠️ IMPORTANT: Create this agent BEFORE running the Marketing setup script!
-- The Marketing Commander calls OPS_AGENT to check inventory for promotions.
-- Agent name MUST be: OPS_AGENT (in HOL_AUTOMATION.OPERATIONS schema)
/*
CREATING THE OPS AGENT IN SNOWFLAKE UI
======================================

1. NAVIGATE TO CORTEX AGENT
   - Click on "AI & ML" in the left navigation
   - Select "Cortex Agent" 
   - Click "+ Create" button

2. BASIC CONFIGURATION
   Name: Ops_Agent
   
   Description:
   Operations monitoring agent for inventory management and order fulfillment 
   analysis. Helps track stock levels, identify at-risk orders, and monitor 
   warehouse performance.

3. INSTRUCTIONS (paste this into the Instructions field):
   You are an operations analyst assistant. Help users with:
   - Inventory status and stock level queries
   - Order fulfillment tracking and at-risk order identification
   - Warehouse performance analysis
   - Supplier delivery monitoring
   
   When answering questions:
   - Always include relevant context like warehouse names and dates
   - Highlight critical issues (low stock, delayed orders) prominently
   - Suggest actionable next steps when problems are identified
   - Use clear, concise language suitable for operations managers

4. CONNECT THE SEMANTIC MODEL
   - In the "Data Sources" section, click "Add"
   - Select "Semantic View" 
   - Choose: HOL_AUTOMATION.OPERATIONS.OPS_ANALYTICS
   - Answers questions about operations data including inventory levels, order fulfillment status, warehouse performance, and supplier deliveries. Use this tool for any questions about stock quantities, at-risk orders, product availability, or operational metrics.
   - Click "Add" to confirm

5. OPTIONAL SETTINGS
   - Warehouse: HOL_AGENT_WH (or your preferred warehouse)
   - Enable "Show SQL" if users should see generated queries

6. Click "Create" to finish

TESTING THE AGENT
-----------------
Try these sample questions:
- "What products are low on stock?"
- "Show me orders at risk of not being fulfilled"
- "Which warehouses have the most inventory issues?"
- "What's the current status of high-priority orders?"
*/
