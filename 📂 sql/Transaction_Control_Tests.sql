-- =============================================================================================
-- 							🔍 PHASE 2.4 Transactional Simulation Checks 
-- =============================================================================================
-- BILL PAYMENT with START TRANSACTION, UPDATE, INSERT INTO, and COMMIT:
-- Simulate a bill payment to confirm if the database behaves as expected.
-- =============================================================================================
START TRANSACTION;
-- 1. Customer pays a bill
UPDATE BillingRecord 
SET 
    AmountPaid = AmountDue,
    PaymentStatus = 'Paid'
WHERE
    BillID = 210;
-- 2. Insert a log entry
INSERT INTO ProcessLog (LogID, ProcessType, CustomerID, BranchID, StartTime, EndTime, DurationSec, Status)
VALUES (1005, 'Billing', 25, 102, NOW(), NOW(), 45, 'Completed');
COMMIT;
-- =============================================================================================
-- 			🚦 Atomicity check 1: Transaction Block with Rollback and Savepoint
-- =============================================================================================
-- USING PRE-CHECK FOR CUSTOMER ID AND IF STATEMENTS TO COMPLETE TRANSACTIONS
-- Confirms if the customer exists before moving forward with the transaction.
-- Customer does not exist, so the transaction comes back to initial point.
-- =============================================================================================
DROP PROCEDURE IF EXISTS safe_plan_and_billing;
DELIMITER $$
CREATE PROCEDURE safe_plan_and_billing()
BEGIN
    DECLARE customer_exists INT DEFAULT 0;
    START TRANSACTION;
    -- Update plan price
    UPDATE ServicePlan 
    SET MonthlyFee = MonthlyFee + 5.00 WHERE PlanID = 2;
    SAVEPOINT sp_before_log;
    -- Check for existence of customer 150
    SELECT COUNT(*) INTO customer_exists 
    FROM Customer 
    WHERE CustomerID = 150 FOR UPDATE;
    -- Conditionally insert billing record
    IF customer_exists = 1 THEN
        INSERT INTO BillingRecord (BillID, CustomerID, PlanID, TimeID, AmountDue, AmountPaid, PaymentStatus)
        VALUES (999, 150, 2, 4, 25.00, 25.00, 'Paid');
    ELSE
        ROLLBACK TO sp_before_log;
    END IF;
    COMMIT;
END$$
DELIMITER ;
CALL safe_plan_and_billing();

-- =============================================================================================
-- 🚦 				Atomicity check 2: Stored Procedure: Usage Deduction
-- =============================================================================================
-- Conditional case to confirm if the Customer has Data Available for usage
-- If the customer does not have available data, it would show a message "Quota exceeded. Operation aborted."
-- Else it will say 'Data deducted successfully'
-- =============================================================================================
DROP PROCEDURE IF EXISTS sp_deduct_data; 
DELIMITER $$

CREATE PROCEDURE sp_deduct_data(
    IN p_customer_id INT,
    IN p_time_id INT,
    IN p_data_used DECIMAL(10,2)
)
BEGIN
    DECLARE current_usage DECIMAL(10,2);
    DECLARE data_limit INT;

    START TRANSACTION;
    -- Lock record
SELECT 
    ur.DataUsedGB
INTO current_usage FROM
    UsageRecord ur
WHERE
    ur.CustomerID = p_customer_id
        AND ur.TimeID = p_time_id
FOR UPDATE;

SELECT 
    sp.DataLimitGB
INTO data_limit FROM
    Customer c
        JOIN
    ServicePlan sp ON c.PlanID = sp.PlanID
WHERE
    c.CustomerID = p_customer_id;
    -- Check quota
    IF current_usage + p_data_used > data_limit THEN
        ROLLBACK;
SELECT 'Quota exceeded. Operation aborted.' AS Message;
    ELSE
        UPDATE UsageRecord
        SET DataUsedGB = DataUsedGB + p_data_used
        WHERE CustomerID = p_customer_id AND TimeID = p_time_id;

        COMMIT;
SELECT 'Data deducted successfully.' AS Message;
    END IF;

END $$

DELIMITER ;

-- =============================================================================================
-- 🚦 				Atomicity check 3: Row Locking and Concurrency
-- =============================================================================================
-- Simulated Scenario: Support Agent A locks TicketID = 1 to update its ResolutionTime.
-- Meanwhile, Support Agent B tries to update the same ticket (but is blocked until A finishes).
-- =============================================================================================
-- Session A: Start a transaction and lock the row
START TRANSACTION;
-- Lock the ticket row by selecting with FOR UPDATE
SELECT 
    *
FROM
    SupportTicket
WHERE
    TicketID = 1
FOR UPDATE;

-- Simulate agent processing delay
SELECT SLEEP(10);

-- Now update ResolutionTime after "working" on the ticket
UPDATE SupportTicket 
SET 
    ResolutionTime = ResolutionTime + 10
WHERE
    TicketID = 1;

-- Finish the transaction
COMMIT;
-- =============================================================================================
-- Session B: Start a transaction and attempt to update the same row
-- =============================================================================================
START TRANSACTION;

-- This will block until Session A commits
UPDATE SupportTicket 
SET 
    ResolutionTime = ResolutionTime + 5
WHERE
    TicketID = 1;

COMMIT;
-- =============================================================================================
--  		Atomicity check 4: Set Isolation to REPEATABLE READ (Phantom Read Test)
-- =============================================================================================
-- Simulated Scenario:
--  two transactions that attempted to update the same pair of records in reverse order.
-- =============================================================================================
--  STEP 1: Set Isolation to REPEATABLE READ (Phantom Read Test)
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;

-- Count support tickets for 'Billing Issues'
SELECT 
    COUNT(*) AS before_count
FROM
    SupportTicket
WHERE
    IssueType = 'Billing Issues';

-- Wait (simulate  delay)
SELECT SLEEP(10);

-- Count again (expecting no change under REPEATABLE READ)
SELECT 
    COUNT(*) AS after_count
FROM
    SupportTicket
WHERE
    IssueType = 'Billing Issues';
-- Do not commit yet, session two should be run meanwhile

-- ===============================================================
-- STEP 2: Insert a new phantom row (SESSION B ) while SESSION A is sleeping
-- THIS SHOULD BE RUN IN A DIFFERENT QUERY TAB TO APPLY.
-- =============================================================================================
START TRANSACTION;

-- Insert a new ticket for the same issue type
INSERT INTO SupportTicket (
    TicketID, CustomerID, BranchID, EmployeeID, TimeID, IssueType, Channel, 
    ResolutionTime, CustomerSatisfaction, InteractionHistory, createdAt, updatedAt ) 
    VALUES ( 999, 1, 101, 2, 1, 'Billing Issues', 'App', 20, 5, 
    '{"messages":[{"time":"2025-12-01T10:00:00","text":"New billing issue added."}]}',
    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
);

COMMIT;

