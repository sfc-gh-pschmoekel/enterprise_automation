/*=============================================================================
ENTERPRISE WORKFLOW AUTOMATION - HANDS ON LAB
The Finance Agent 
=============================================================================*/

-- ============================================================================
-- SECTION 1: DATABASE & SCHEMA SETUP
-- ============================================================================

USE ROLE SYSADMIN;

CREATE DATABASE IF NOT EXISTS HOL_AUTOMATION;
CREATE SCHEMA IF NOT EXISTS HOL_AUTOMATION.FINANCE;

USE DATABASE HOL_AUTOMATION;
USE SCHEMA FINANCE;

CREATE OR REPLACE WAREHOUSE HOL_AGENT_WH 
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE;

USE WAREHOUSE HOL_AGENT_WH;

-- ============================================================================
-- SECTION 2: SAMPLE DATA - VENDORS
-- ============================================================================

CREATE OR REPLACE TABLE VENDORS (
    vendor_id VARCHAR(20) PRIMARY KEY,
    vendor_name VARCHAR(100),
    vendor_status VARCHAR(20),  -- ACTIVE, SUSPENDED, INACTIVE
    payment_terms_days INT,
    category VARCHAR(50),
    contact_email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

INSERT INTO VENDORS VALUES
    ('V001', 'Acme Industrial Supply', 'ACTIVE', 30, 'Industrial Parts', 'ar@acmeindustrial.com', CURRENT_TIMESTAMP()),
    ('V002', 'Global Logistics Co', 'ACTIVE', 45, 'Shipping', 'billing@globallogistics.com', CURRENT_TIMESTAMP()),
    ('V003', 'TechParts Unlimited', 'ACTIVE', 30, 'Electronics', 'accounts@techparts.com', CURRENT_TIMESTAMP()),
    ('V004', 'Office Essentials', 'ACTIVE', 15, 'Office Supplies', 'invoices@officeessentials.com', CURRENT_TIMESTAMP()),
    ('V005', 'Premier Packaging', 'SUSPENDED', 30, 'Packaging', 'finance@premierpack.com', CURRENT_TIMESTAMP()),
    ('V006', 'Quality Raw Materials', 'ACTIVE', 60, 'Raw Materials', 'ap@qualityraw.com', CURRENT_TIMESTAMP()),
    ('V007', 'FastShip Express', 'ACTIVE', 15, 'Shipping', 'billing@fastship.com', CURRENT_TIMESTAMP()),
    ('V008', 'Midwest Manufacturing', 'INACTIVE', 30, 'Parts Supply', 'ar@midwestmfg.com', CURRENT_TIMESTAMP());

-- NOTE: Midwest Manufacturing (V008) supplies Industrial Bearing Assemblies (SKU-001)
-- to our Operations warehouses. Their INACTIVE status will cause inventory problems!

-- ============================================================================
-- SECTION 3: SAMPLE DATA - PURCHASE ORDERS
-- ============================================================================

CREATE OR REPLACE TABLE PURCHASE_ORDERS (
    po_number VARCHAR(20) PRIMARY KEY,
    vendor_id VARCHAR(20) REFERENCES VENDORS(vendor_id),
    po_date DATE,
    po_amount DECIMAL(12,2),
    po_status VARCHAR(20),  -- OPEN, PARTIALLY_RECEIVED, CLOSED, CANCELLED
    department VARCHAR(50),
    requester_name VARCHAR(100),
    approved_by VARCHAR(100),
    description VARCHAR(500)
);

INSERT INTO PURCHASE_ORDERS VALUES
    ('PO-2024-001', 'V001', '2024-01-15', 15000.00, 'OPEN', 'Operations', 'Sarah Chen', 'Mike Johnson', 'Industrial bearings and components'),
    ('PO-2024-002', 'V002', '2024-01-20', 8500.00, 'OPEN', 'Logistics', 'Tom Wilson', 'Mike Johnson', 'Q1 shipping services'),
    ('PO-2024-003', 'V003', '2024-02-01', 22000.00, 'PARTIALLY_RECEIVED', 'IT', 'Lisa Park', 'David Brown', 'Server components and networking equipment'),
    ('PO-2024-004', 'V004', '2024-02-10', 1200.00, 'OPEN', 'Admin', 'John Smith', 'Sarah Chen', 'Office supplies - Q1'),
    ('PO-2024-005', 'V005', '2024-02-15', 5000.00, 'OPEN', 'Warehouse', 'Amy Rodriguez', 'Mike Johnson', 'Packaging materials'),
    ('PO-2024-006', 'V006', '2024-02-20', 45000.00, 'OPEN', 'Manufacturing', 'Bob Taylor', 'David Brown', 'Raw materials for production'),
    ('PO-2024-007', 'V001', '2024-03-01', 12000.00, 'CLOSED', 'Operations', 'Sarah Chen', 'Mike Johnson', 'Replacement parts'),
    ('PO-2024-008', 'V007', '2024-03-05', 3500.00, 'OPEN', 'Logistics', 'Tom Wilson', 'Sarah Chen', 'Express shipping services'),
    ('PO-2024-009', 'V003', '2024-03-10', 18500.00, 'OPEN', 'IT', 'Lisa Park', 'David Brown', 'Laptop refresh program'),
    ('PO-2024-010', 'V008', '2024-03-15', 28000.00, 'CANCELLED', 'Manufacturing', 'Bob Taylor', 'David Brown', 'Custom components - cancelled');

-- ============================================================================
-- SECTION 4: SAMPLE DATA - INVOICES
-- ============================================================================

CREATE OR REPLACE TABLE INVOICES (
    invoice_id VARCHAR(20) PRIMARY KEY,
    vendor_id VARCHAR(20) REFERENCES VENDORS(vendor_id),
    po_number VARCHAR(20),
    invoice_date DATE,
    due_date DATE,
    invoice_amount DECIMAL(12,2),
    invoice_status VARCHAR(20),  -- PENDING_VALIDATION, VALIDATED, EXCEPTION, APPROVED, PAID, REJECTED
    validation_notes VARCHAR(1000),
    routed_to VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

INSERT INTO INVOICES VALUES
    ('INV-2024-001', 'V001', 'PO-2024-001', '2024-02-01', '2024-03-02', 25395.45, 'EXCEPTION', NULL, NULL, CURRENT_TIMESTAMP()),
    ('INV-2024-002', 'V002', 'PO-2024-002', '2024-02-05', '2024-03-21', 8500.00, 'PENDING_VALIDATION', NULL, NULL, CURRENT_TIMESTAMP()),
    ('INV-2024-003', 'V003', 'PO-2024-003', '2024-02-15', '2024-03-16', 25000.00, 'PENDING_VALIDATION', NULL, NULL, CURRENT_TIMESTAMP()),  -- Amount exceeds PO!
    ('INV-2024-004', 'V004', 'PO-2024-004', '2024-02-20', '2024-03-06', 1150.00, 'PENDING_VALIDATION', NULL, NULL, CURRENT_TIMESTAMP()),
    ('INV-2024-005', 'V005', 'PO-2024-005', '2024-02-25', '2024-03-26', 5000.00, 'PENDING_VALIDATION', NULL, NULL, CURRENT_TIMESTAMP()),  -- Vendor is SUSPENDED!
    ('INV-2024-006', 'V006', 'PO-2024-006', '2024-03-01', '2024-04-30', 44500.00, 'PENDING_VALIDATION', NULL, NULL, CURRENT_TIMESTAMP()),
    ('INV-2024-007', 'V001', 'PO-2024-007', '2024-03-10', '2024-04-09', 12000.00, 'VALIDATED', 'PO matched, vendor active, amount within tolerance', 'Auto-approved', CURRENT_TIMESTAMP()),
    ('INV-2024-008', 'V007', 'PO-2024-008', '2024-03-12', '2024-03-27', 3800.00, 'PENDING_VALIDATION', NULL, NULL, CURRENT_TIMESTAMP()),  -- Amount exceeds PO by small amount
    ('INV-2024-009', 'V003', NULL, '2024-03-15', '2024-04-14', 2500.00, 'PENDING_VALIDATION', NULL, NULL, CURRENT_TIMESTAMP()),  -- No PO number!
    ('INV-2024-010', 'V008', 'PO-2024-010', '2024-03-18', '2024-04-17', 28000.00, 'PENDING_VALIDATION', NULL, NULL, CURRENT_TIMESTAMP());  -- PO is CANCELLED, Vendor INACTIVE!

-- ============================================================================
-- SECTION 5: SAMPLE DATA - APPROVERS
-- ============================================================================

CREATE OR REPLACE TABLE APPROVERS (
    approver_id VARCHAR(20) PRIMARY KEY,
    approver_name VARCHAR(100),
    email VARCHAR(100),
    approval_limit DECIMAL(12,2),
    department VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE
);

INSERT INTO APPROVERS VALUES
    ('APR001', 'Sarah Chen', 'sarah.chen@company.com', 5000.00, 'Operations', TRUE),
    ('APR002', 'Mike Johnson', 'mike.johnson@company.com', 25000.00, 'Finance', TRUE),
    ('APR003', 'David Brown', 'david.brown@company.com', 100000.00, 'Finance', TRUE),
    ('APR004', 'Lisa Park', 'lisa.park@company.com', 10000.00, 'IT', TRUE),
    ('APR005', 'Emily White', 'emily.white@company.com', 50000.00, 'Executive', TRUE);

-- ============================================================================
-- SECTION 6: AUDIT LOG TABLE
-- ============================================================================

CREATE OR REPLACE TABLE AUDIT_LOG (
    log_id INT AUTOINCREMENT PRIMARY KEY,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
    action_type VARCHAR(50),
    invoice_id VARCHAR(20),
    action_by VARCHAR(100),
    action_details VARCHAR(2000),
    previous_status VARCHAR(50),
    new_status VARCHAR(50)
);

-- ============================================================================
-- SECTION 7: STORED PROCEDURES (AGENT TOOLS)
-- ============================================================================

-- Tool 1: Get Invoice Details
CREATE OR REPLACE PROCEDURE GET_INVOICE_DETAILS(invoice_id VARCHAR)
RETURNS VARIANT
LANGUAGE SQL
AS
$$
DECLARE
    result VARIANT;
BEGIN
    SELECT OBJECT_CONSTRUCT(
        'invoice_id', i.invoice_id,
        'vendor_name', v.vendor_name,
        'vendor_status', v.vendor_status,
        'vendor_id', i.vendor_id,
        'po_number', i.po_number,
        'invoice_date', i.invoice_date,
        'due_date', i.due_date,
        'invoice_amount', i.invoice_amount,
        'invoice_status', i.invoice_status,
        'validation_notes', i.validation_notes,
        'routed_to', i.routed_to
    ) INTO result
    FROM INVOICES i
    JOIN VENDORS v ON i.vendor_id = v.vendor_id
    WHERE i.invoice_id = :invoice_id;
    
    RETURN result;
END;
$$;

-- Tool 2: Validate Invoice Against PO
CREATE OR REPLACE PROCEDURE VALIDATE_INVOICE(invoice_id VARCHAR)
RETURNS VARIANT
LANGUAGE SQL
AS
$$
DECLARE
    result VARIANT;
    inv_amount DECIMAL(12,2);
    po_amt DECIMAL(12,2);
    po_stat VARCHAR(20);
    po_num VARCHAR(20);
    vendor_stat VARCHAR(20);
    vendor_name VARCHAR(100);
    issues ARRAY DEFAULT ARRAY_CONSTRUCT();
    is_valid BOOLEAN DEFAULT TRUE;
BEGIN
    -- Get invoice, PO, and vendor details
    SELECT 
        i.invoice_amount,
        i.po_number,
        p.po_amount,
        p.po_status,
        v.vendor_status,
        v.vendor_name
    INTO inv_amount, po_num, po_amt, po_stat, vendor_stat, vendor_name
    FROM INVOICES i
    LEFT JOIN PURCHASE_ORDERS p ON i.po_number = p.po_number
    JOIN VENDORS v ON i.vendor_id = v.vendor_id
    WHERE i.invoice_id = :invoice_id;
    
    -- Check 1: Missing PO
    IF (po_num IS NULL) THEN
        issues := ARRAY_APPEND(issues, 'MISSING_PO: No purchase order number provided');
        is_valid := FALSE;
    ELSEIF (po_amt IS NULL) THEN
        issues := ARRAY_APPEND(issues, 'INVALID_PO: Purchase order not found in system');
        is_valid := FALSE;
    ELSE
        -- Check 2: PO Status
        IF (po_stat = 'CANCELLED') THEN
            issues := ARRAY_APPEND(issues, 'CANCELLED_PO: Referenced purchase order has been cancelled');
            is_valid := FALSE;
        ELSEIF (po_stat = 'CLOSED') THEN
            issues := ARRAY_APPEND(issues, 'CLOSED_PO: Referenced purchase order is already closed');
            is_valid := FALSE;
        END IF;
        
        -- Check 3: Amount variance
        IF (inv_amount > po_amt * 1.05) THEN
            issues := ARRAY_APPEND(issues, 'AMOUNT_EXCEEDED: Invoice amount ($' || inv_amount || ') exceeds PO amount ($' || po_amt || ') by more than 5% tolerance');
            is_valid := FALSE;
        ELSEIF (inv_amount > po_amt) THEN
            issues := ARRAY_APPEND(issues, 'AMOUNT_OVER_MINOR: Invoice amount slightly exceeds PO (within 5% tolerance) - requires review');
        END IF;
    END IF;
    
    -- Check 4: Vendor status
    IF (vendor_stat = 'SUSPENDED') THEN
        issues := ARRAY_APPEND(issues, 'VENDOR_SUSPENDED: Vendor ' || vendor_name || ' is currently suspended');
        is_valid := FALSE;
    ELSEIF (vendor_stat = 'INACTIVE') THEN
        issues := ARRAY_APPEND(issues, 'VENDOR_INACTIVE: Vendor ' || vendor_name || ' is inactive');
        is_valid := FALSE;
    END IF;
    
    -- Build result
    result := OBJECT_CONSTRUCT(
        'invoice_id', invoice_id,
        'vendor_name', vendor_name,
        'invoice_amount', inv_amount,
        'po_number', po_num,
        'po_amount', po_amt,
        'is_valid', is_valid,
        'issues', issues,
        'issue_count', ARRAY_SIZE(issues),
        'recommendation', CASE 
            WHEN is_valid AND ARRAY_SIZE(issues) = 0 THEN 'AUTO_APPROVE: Invoice passed all validation checks'
            WHEN is_valid THEN 'REVIEW_REQUIRED: Invoice has minor issues requiring human review'
            ELSE 'EXCEPTION: Invoice has critical issues that must be resolved'
        END
    );
    
    RETURN result;
END;
$$;

-- Tool 3: Route Invoice for Approval
CREATE OR REPLACE PROCEDURE ROUTE_INVOICE(p_invoice_id VARCHAR, p_reason VARCHAR)
RETURNS VARIANT
LANGUAGE SQL
AS
$$
DECLARE
    result VARIANT;
    inv_amount DECIMAL(12,2);
    inv_status VARCHAR(20);
    v_approver_name VARCHAR(100);
    v_approver_email VARCHAR(100);
    approver_found BOOLEAN DEFAULT FALSE;
BEGIN
    -- Get invoice amount and status
    SELECT invoice_amount, invoice_status 
    INTO inv_amount, inv_status
    FROM HOL_AUTOMATION.FINANCE.INVOICES 
    WHERE invoice_id = :p_invoice_id;
    
    IF (inv_amount IS NULL) THEN
        RETURN OBJECT_CONSTRUCT(
            'success', FALSE,
            'invoice_id', :p_invoice_id,
            'error', 'Invoice not found'
        );
    END IF;
    
    -- Find appropriate approver based on amount
    SELECT approver_name, email, TRUE
    INTO v_approver_name, v_approver_email, approver_found
    FROM HOL_AUTOMATION.FINANCE.APPROVERS
    WHERE approval_limit >= :inv_amount
    AND is_active = TRUE
    ORDER BY approval_limit ASC
    LIMIT 1;
    
    -- If no approver found with sufficient limit, route to highest authority
    IF (v_approver_name IS NULL) THEN
        SELECT approver_name, email
        INTO v_approver_name, v_approver_email
        FROM HOL_AUTOMATION.FINANCE.APPROVERS
        WHERE is_active = TRUE
        ORDER BY approval_limit DESC
        LIMIT 1;
    END IF;
    
    -- Update invoice
    UPDATE HOL_AUTOMATION.FINANCE.INVOICES 
    SET invoice_status = 'EXCEPTION',
        validation_notes = :p_reason,
        routed_to = :v_approver_name
    WHERE invoice_id = :p_invoice_id;
    
    -- Log the action
    INSERT INTO HOL_AUTOMATION.FINANCE.AUDIT_LOG (action_type, invoice_id, action_by, action_details, previous_status, new_status)
    VALUES ('ROUTE_FOR_APPROVAL', :p_invoice_id, 'Finance Agent', 
            'Routed to ' || :v_approver_name || '. Reason: ' || :p_reason,
            :inv_status, 'EXCEPTION');
    
    result := OBJECT_CONSTRUCT(
        'success', TRUE,
        'invoice_id', :p_invoice_id,
        'routed_to', :v_approver_name,
        'approver_email', :v_approver_email,
        'invoice_amount', :inv_amount,
        'reason', :p_reason,
        'message', 'Invoice has been routed to ' || :v_approver_name || ' for approval'
    );
    
    RETURN result;
END;
$$;

-- Tool 4: Approve Invoice (for valid invoices)
CREATE OR REPLACE PROCEDURE APPROVE_INVOICE(p_invoice_id VARCHAR, p_notes VARCHAR)
RETURNS VARIANT
LANGUAGE SQL
AS
$$
DECLARE
    result VARIANT;
    v_inv_status VARCHAR(20);
BEGIN
    -- Get current status
    SELECT invoice_status INTO v_inv_status
    FROM INVOICES 
    WHERE invoice_id = :p_invoice_id;
    
    -- Update invoice
    UPDATE INVOICES 
    SET invoice_status = 'APPROVED',
        validation_notes = COALESCE(validation_notes || ' | ', '') || :p_notes
    WHERE invoice_id = :p_invoice_id;
    
    -- Log the action
    INSERT INTO AUDIT_LOG (action_type, invoice_id, action_by, action_details, previous_status, new_status)
    VALUES ('APPROVE', :p_invoice_id, 'Finance Agent', :p_notes, :v_inv_status, 'APPROVED');
    
    result := OBJECT_CONSTRUCT(
        'success', TRUE,
        'invoice_id', :p_invoice_id,
        'new_status', 'APPROVED',
        'notes', :p_notes,
        'message', 'Invoice ' || :p_invoice_id || ' has been approved'
    );
    
    RETURN result;
END;
$$;

-- Tool 5: Get Pending Invoices Summary
CREATE OR REPLACE PROCEDURE GET_PENDING_INVOICES()
RETURNS VARIANT
LANGUAGE SQL
AS
$$
DECLARE
    result VARIANT;
BEGIN
    SELECT OBJECT_CONSTRUCT(
        'total_pending', COUNT(*),
        'total_amount', SUM(invoice_amount),
        'invoices', ARRAY_AGG(OBJECT_CONSTRUCT(
            'invoice_id', invoice_id,
            'vendor_id', vendor_id,
            'po_number', po_number,
            'amount', invoice_amount,
            'due_date', due_date
        ))
    ) INTO result
    FROM INVOICES
    WHERE invoice_status = 'PENDING_VALIDATION';
    
    RETURN result;
END;
$$;

-- Tool 6: Get Exceptions Summary
CREATE OR REPLACE PROCEDURE GET_EXCEPTIONS()
RETURNS VARIANT
LANGUAGE SQL
AS
$$
DECLARE
    result VARIANT;
BEGIN
    SELECT OBJECT_CONSTRUCT(
        'total_exceptions', COUNT(*),
        'total_amount', SUM(i.invoice_amount),
        'exceptions', ARRAY_AGG(OBJECT_CONSTRUCT(
            'invoice_id', i.invoice_id,
            'vendor_name', v.vendor_name,
            'amount', i.invoice_amount,
            'routed_to', i.routed_to,
            'notes', i.validation_notes
        ))
    ) INTO result
    FROM INVOICES i
    JOIN VENDORS v ON i.vendor_id = v.vendor_id
    WHERE i.invoice_status = 'EXCEPTION';
    
    RETURN result;
END;
$$;

-- ============================================================================
-- SECTION 8: GRANT PERMISSIONS (OPTIONAL - REQUIRES ACCOUNTADMIN)
-- ============================================================================
-- Uncomment and run with ACCOUNTADMIN if you want a dedicated role for governance
-- For the lab, SYSADMIN is sufficient

-- USE ROLE ACCOUNTADMIN;
-- CREATE ROLE IF NOT EXISTS HOL_AGENT_ROLE;
-- GRANT USAGE ON DATABASE HOL_AUTOMATION TO ROLE HOL_AGENT_ROLE;
-- GRANT USAGE ON SCHEMA HOL_AUTOMATION.FINANCE TO ROLE HOL_AGENT_ROLE;
-- GRANT SELECT ON ALL TABLES IN SCHEMA HOL_AUTOMATION.FINANCE TO ROLE HOL_AGENT_ROLE;
-- GRANT USAGE ON PROCEDURE HOL_AUTOMATION.FINANCE.GET_INVOICE_DETAILS(VARCHAR) TO ROLE HOL_AGENT_ROLE;
-- GRANT USAGE ON PROCEDURE HOL_AUTOMATION.FINANCE.VALIDATE_INVOICE(VARCHAR) TO ROLE HOL_AGENT_ROLE;
-- GRANT USAGE ON PROCEDURE HOL_AUTOMATION.FINANCE.ROUTE_INVOICE(VARCHAR, VARCHAR) TO ROLE HOL_AGENT_ROLE;
-- GRANT USAGE ON PROCEDURE HOL_AUTOMATION.FINANCE.APPROVE_INVOICE(VARCHAR, VARCHAR) TO ROLE HOL_AGENT_ROLE;
-- GRANT USAGE ON PROCEDURE HOL_AUTOMATION.FINANCE.GET_PENDING_INVOICES() TO ROLE HOL_AGENT_ROLE;
-- GRANT USAGE ON PROCEDURE HOL_AUTOMATION.FINANCE.GET_EXCEPTIONS() TO ROLE HOL_AGENT_ROLE;
-- GRANT USAGE ON WAREHOUSE HOL_AGENT_WH TO ROLE HOL_AGENT_ROLE;
-- USE ROLE SYSADMIN;

-- ============================================================================
-- SECTION 9: CREATE THE FINANCE AGENT (with 5 of 6 tools pre-configured)
-- ============================================================================
-- Attendees will add the 6th tool (GET_EXCEPTIONS) themselves in the lab

CREATE OR REPLACE AGENT HOL_AUTOMATION.FINANCE.FINANCE_AGENT
  COMMENT = 'Finance Agent for invoice validation and exception routing'
  PROFILE = '{"display_name": "Finance Agent", "color": "blue"}'
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
      You are a Finance Agent responsible for validating invoices and managing exceptions. 
      You help finance teams automate invoice processing by:
      1. VALIDATING invoices against purchase orders
      2. IDENTIFYING issues like amount mismatches, invalid POs, or vendor problems
      3. ROUTING exceptions to the appropriate approver
      4. APPROVING valid invoices automatically

      WORKFLOW:
      - When asked to validate an invoice, use the validate_invoice tool first
      - If validation passes with no issues, use approve_invoice to approve it
      - If validation fails or has issues, use route_invoice to send it for human review
      - Always explain your reasoning in plain English

      IMPORTANT:
      - Be thorough but concise in your explanations
      - Always cite specific numbers and issues found
      - When routing for approval, summarize all issues clearly
      - For questions about pending work, use get_pending_invoices
    
    orchestration: |
      Use validate_invoice to check invoices for issues.
      Use get_pending_invoices to see the work queue.
      Use route_invoice when validation finds problems.
      Use approve_invoice only when validation passes.
    
    response: |
      Respond in a friendly, professional manner.
      Always explain your reasoning clearly.
      Include specific numbers and details from the data.

    sample_questions:
      - question: "What invoices need my attention today?"
        answer: "I'll check the pending invoices queue for you."
      - question: "Validate invoice INV-2024-001"
        answer: "I'll validate that invoice against its PO and vendor status."

  tools:
    - tool_spec:
        type: generic
        name: get_invoice_details
        description: "Retrieves detailed information about a specific invoice including vendor info, PO reference, amounts, and current status. Use this when you need to look up information about a specific invoice."
        input_schema:
          type: object
          properties:
            invoice_id:
              type: string
              description: "The unique invoice identifier. Format: INV-YYYY-NNN (e.g., INV-2024-001)"
          required:
            - invoice_id

    - tool_spec:
        type: generic
        name: validate_invoice
        description: "Validates an invoice against its purchase order and vendor status. Checks for: PO existence, PO status (not cancelled/closed), amount variance (5% tolerance), and vendor status (active). Returns validation result with specific issues found."
        input_schema:
          type: object
          properties:
            invoice_id:
              type: string
              description: "The unique invoice identifier. Format: INV-YYYY-NNN (e.g., INV-2024-001)"
          required:
            - invoice_id

    - tool_spec:
        type: generic
        name: route_invoice
        description: "Routes an invoice with exceptions to the appropriate approver based on invoice amount. Updates invoice status to EXCEPTION and assigns to approver. Use this after validation finds issues that need human review."
        input_schema:
          type: object
          properties:
            p_invoice_id:
              type: string
              description: "The unique invoice identifier to route. Format: INV-YYYY-NNN"
            p_reason:
              type: string
              description: "The reason for routing - summarize the validation issues found"
          required:
            - p_invoice_id
            - p_reason

    - tool_spec:
        type: generic
        name: approve_invoice
        description: "Approves an invoice that has passed validation. Updates status to APPROVED and logs the action. Only use this for invoices that have passed all validation checks."
        input_schema:
          type: object
          properties:
            p_invoice_id:
              type: string
              description: "The unique invoice identifier to approve. Format: INV-YYYY-NNN"
            p_notes:
              type: string
              description: "Approval notes explaining why the invoice was approved"
          required:
            - p_invoice_id
            - p_notes

    - tool_spec:
        type: generic
        name: get_pending_invoices
        description: "Returns a summary of all invoices currently pending validation, including count, total amount, and list of invoice details. Use this to see what work is in the queue."
        input_schema:
          type: object
          properties: {}

  tool_resources:
    get_invoice_details:
      type: procedure
      execution_environment:
        type: warehouse
        warehouse: HOL_AGENT_WH
      identifier: HOL_AUTOMATION.FINANCE.GET_INVOICE_DETAILS
    validate_invoice:
      type: procedure
      execution_environment:
        type: warehouse
        warehouse: HOL_AGENT_WH
      identifier: HOL_AUTOMATION.FINANCE.VALIDATE_INVOICE
    route_invoice:
      type: procedure
      execution_environment:
        type: warehouse
        warehouse: HOL_AGENT_WH
      identifier: HOL_AUTOMATION.FINANCE.ROUTE_INVOICE
    approve_invoice:
      type: procedure
      execution_environment:
        type: warehouse
        warehouse: HOL_AGENT_WH
      identifier: HOL_AUTOMATION.FINANCE.APPROVE_INVOICE
    get_pending_invoices:
      type: procedure
      execution_environment:
        type: warehouse
        warehouse: HOL_AGENT_WH
      identifier: HOL_AUTOMATION.FINANCE.GET_PENDING_INVOICES
  $$;

-- ============================================================================
-- SECTION 10: VERIFICATION QUERIES
-- ============================================================================

-- Verify data was loaded
SELECT 'Vendors' as table_name, COUNT(*) as row_count FROM VENDORS
UNION ALL
SELECT 'Purchase Orders', COUNT(*) FROM PURCHASE_ORDERS
UNION ALL
SELECT 'Invoices', COUNT(*) FROM INVOICES
UNION ALL
SELECT 'Approvers', COUNT(*) FROM APPROVERS;

-- Show sample invoice with validation scenario
SELECT 
    i.invoice_id,
    v.vendor_name,
    v.vendor_status,
    i.po_number,
    p.po_status,
    i.invoice_amount,
    p.po_amount,
    i.invoice_status,
    CASE 
        WHEN i.po_number IS NULL THEN '⚠️ Missing PO'
        WHEN p.po_status = 'CANCELLED' THEN '❌ PO Cancelled'
        WHEN v.vendor_status = 'SUSPENDED' THEN '⚠️ Vendor Suspended'
        WHEN v.vendor_status = 'INACTIVE' THEN '❌ Vendor Inactive'
        WHEN i.invoice_amount > p.po_amount * 1.05 THEN '⚠️ Amount Exceeds PO'
        ELSE '✅ Ready for validation'
    END as expected_result
FROM INVOICES i
JOIN VENDORS v ON i.vendor_id = v.vendor_id
LEFT JOIN PURCHASE_ORDERS p ON i.po_number = p.po_number
ORDER BY i.invoice_id;

SELECT '✅ Pre-lab setup complete!' as status;
SELECT 'Finance Agent created with 5 tools. Attendees will add GET_EXCEPTIONS tool in the lab.' as next_step;

--DROP DATABASE hol_automation;