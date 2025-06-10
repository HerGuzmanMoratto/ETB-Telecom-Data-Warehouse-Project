-- ======================================================
-- 🔍 PHASE 2.3 Referential Integrity Validation Checks
-- =====================================================
-- Purpose: Ensure that Every entry in the different table has a corresponding entry in their refereced tables.
-- These checks confirm that no orphaned references exist and that the database upholds ACID-compliant design principles.
-- ------------------------------------------------------------------------------------------------
-- 1. BillingRecord → Customer
SELECT COUNT(*) AS orphaned_customer_refs_in_billing
FROM BillingRecord b
LEFT JOIN Customer c ON b.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL;

-- 2. BillingRecord → ServicePlan
SELECT COUNT(*) AS orphaned_plan_refs_in_billing
FROM BillingRecord b
LEFT JOIN ServicePlan sp ON b.PlanID = sp.PlanID
WHERE b.PlanID IS NOT NULL AND sp.PlanID IS NULL;

-- 3. BillingRecord → Time
SELECT COUNT(*) AS orphaned_time_refs_in_billing
FROM BillingRecord b
LEFT JOIN Time t ON b.TimeID = t.TimeID
WHERE t.TimeID IS NULL;

-- 4. UsageRecord → Customer
SELECT COUNT(*) AS orphaned_customer_refs_in_usage
FROM UsageRecord u
LEFT JOIN Customer c ON u.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL;

-- 5. UsageRecord → ServicePlan
SELECT COUNT(*) AS orphaned_plan_refs_in_usage
FROM UsageRecord u
LEFT JOIN ServicePlan sp ON u.PlanID = sp.PlanID
WHERE u.PlanID IS NOT NULL AND sp.PlanID IS NULL;

-- 6. UsageRecord → Time
SELECT COUNT(*) AS orphaned_time_refs_in_usage
FROM UsageRecord u
LEFT JOIN Time t ON u.TimeID = t.TimeID
WHERE t.TimeID IS NULL;

-- 7. SupportTicket → Customer
SELECT COUNT(*) AS orphaned_customer_refs_in_tickets
FROM SupportTicket s
LEFT JOIN Customer c ON s.CustomerID = c.CustomerID
WHERE s.CustomerID IS NOT NULL AND c.CustomerID IS NULL;

-- 8. SupportTicket → Employee
SELECT COUNT(*) AS orphaned_employee_refs_in_tickets
FROM SupportTicket s
LEFT JOIN Employee e ON s.EmployeeID = e.EmployeeID
WHERE s.EmployeeID IS NOT NULL AND e.EmployeeID IS NULL;

-- 9. SupportTicket → Branch
SELECT COUNT(*) AS orphaned_branch_refs_in_tickets
FROM SupportTicket s
LEFT JOIN Branch b ON s.BranchID = b.BranchID
WHERE b.BranchID IS NULL;

-- 10. SupportTicket → Time
SELECT COUNT(*) AS orphaned_time_refs_in_tickets
FROM SupportTicket s
LEFT JOIN Time t ON s.TimeID = t.TimeID
WHERE t.TimeID IS NULL;

-- 11. RevenueTarget → Branch
SELECT COUNT(*) AS orphaned_branch_refs_in_revenue
FROM RevenueTarget r
LEFT JOIN Branch b ON r.BranchID = b.BranchID
WHERE b.BranchID IS NULL;

-- 12. RevenueTarget → ServicePlan
SELECT COUNT(*) AS orphaned_plan_refs_in_revenue
FROM RevenueTarget r
LEFT JOIN ServicePlan sp ON r.PlanID = sp.PlanID
WHERE r.PlanID IS NOT NULL AND sp.PlanID IS NULL;

-- 13. RevenueTarget → Time
SELECT COUNT(*) AS orphaned_time_refs_in_revenue
FROM RevenueTarget r
LEFT JOIN Time t ON r.TimeID = t.TimeID
WHERE t.TimeID IS NULL;

-- 14. ProcessLog → Customer
SELECT COUNT(*) AS orphaned_customer_refs_in_processlog
FROM ProcessLog p
LEFT JOIN Customer c ON p.CustomerID = c.CustomerID
WHERE p.CustomerID IS NOT NULL AND c.CustomerID IS NULL;

-- 15. ProcessLog → Branch
SELECT COUNT(*) AS orphaned_branch_refs_in_processlog
FROM ProcessLog p
LEFT JOIN Branch b ON p.BranchID = b.BranchID
WHERE b.BranchID IS NULL;