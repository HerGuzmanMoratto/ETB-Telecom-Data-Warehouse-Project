-- =============================================================================================
-- 								 PHASE 3. QUERY DEVELOPMENT.
-- =============================================================================================
-- Purpose: Queries were designed to evaluate performance across operations, financial metrics, and customer interactions. 
-- Each query reflects business-relevant KPIs and aligns with the dimensional model.
-- The queries implement various join types (INNER, LEFT), aggregation, filtering, and grouping techniques for analysis.
-- ------------------------------------------------------------------------------------------------
-- =============================================================================================
-- 						🔍 QUERY 1. Total Customer per Country and Branch
-- =============================================================================================
-- Summarizes total customers by country and business unit
-- Join tables Customer, Branch, Country
SELECT 
    c.CountryName,
    b.BranchName,
    COUNT(cu.CustomerID) AS TotalCustomers,
    ROUND((COUNT(cu.CustomerID) * 100.0) / (SELECT 
                    COUNT(*)
                FROM Customer), 2) AS PercentageOfTotal
FROM
    Customer cu
        JOIN
    Branch b ON cu.BranchID = b.BranchID
        JOIN
    Country c ON b.CountryID = c.CountryID
GROUP BY c.CountryName , b.BranchName
ORDER BY PercentageOfTotal DESC;

-- =============================================================================================
-- 					🔍 QUERY 2. Service Plan Popularity by Country and Branch
-- =============================================================================================
-- Tracks the most subscribed service plans for marketing evaluation
-- Joins tables Customer, BillingRecord, ServicePlan, Branch, Country
SELECT 
    c.CountryName,
    b.BranchName,
    sp.PlanName,
    COUNT(*) AS Subscriptions
FROM
    BillingRecord br
        JOIN
    Customer cu ON br.CustomerID = cu.CustomerID
        JOIN
    ServicePlan sp ON br.PlanID = sp.PlanID
        JOIN
    Branch b ON cu.BranchID = b.BranchID
        JOIN
    Country c ON b.CountryID = c.CountryID
GROUP BY c.CountryName , b.BranchName , sp.PlanName
ORDER BY Subscriptions DESC;
-- =============================================================================================
-- 					🔍 QUERY 3. Revenue Collected by Month per Branch and Total Customers.
-- =============================================================================================
-- Tracks monthly revenue trends across branches, identifies seasonal patterns
-- Join tables BillingRecord, Time, Customer, Branch
SELECT 
    t.TimeID,
    t.Month,
    b.BranchName,
    COUNT(DISTINCT cu.CustomerID) AS TotalCustomers,
    SUM(br.AmountPaid) AS TotalRevenue
FROM
    BillingRecord br
        JOIN
    Time t ON br.TimeID = t.TimeID
        JOIN
    Customer cu ON br.CustomerID = cu.CustomerID
        JOIN
    Branch b ON cu.BranchID = b.BranchID
GROUP BY t.Month , b.BranchName , t.TimeID
ORDER BY t.Month DESC;
-- =============================================================================================
-- 					🔍 QUERY 4. Payment Status by Country and Branch
-- =============================================================================================
-- Checks billing performance by status (Paid, Pending, Late) across countries and branches
-- Joins BillingRecord, Customer, Branch, Country
SELECT 
    c.CountryName,
    b.BranchName,
    br.PaymentStatus,
    COUNT(*) AS CountStatus
FROM
    BillingRecord br
        JOIN
    Customer cu ON br.CustomerID = cu.CustomerID
        JOIN
    Branch b ON cu.BranchID = b.BranchID
        JOIN
    Country c ON b.CountryID = c.CountryID
GROUP BY c.CountryName , b.BranchName , br.PaymentStatus;
-- =============================================================================================
-- 					🔍 QUERY 5. Average Usage per Plan by Month
-- =============================================================================================
-- Supports marketing and infrastructure decisions by analyzing usage trends
-- Join tables UsageRecord, Customer, BillingRecord, ServicePlan, Time
SELECT 
    t.TimeID,
    t.Month,
    sp.PlanName,
    ROUND(AVG(ur.DataUsedGB), 2) AS AvgDataGB,
    ROUND(AVG(ur.VoiceMinutesUsed), 2) AS AvgMinutes,
    ROUND(AVG(ur.SMSUsed), 2) AS AvgSMS
FROM
    UsageRecord ur
        JOIN
    Customer cu ON ur.CustomerID = cu.CustomerID
        JOIN
    BillingRecord br ON cu.CustomerID = br.CustomerID
        AND ur.TimeID = br.TimeID
        JOIN
    ServicePlan sp ON br.PlanID = sp.PlanID
        JOIN
    Time t ON ur.TimeID = t.TimeID
GROUP BY t.Month , sp.PlanName , t.TimeID
ORDER BY t.Month;
-- =============================================================================================
-- 					🔍 QUERY 6. Revenue Target vs Actual Revenue by Plan Type
-- =============================================================================================
-- Evaluates if branches are meeting revenue targets
-- this is a core KPI for performance management to track if they meet expected sells
-- Join tables RevenueTarget, BillingRecord, Customer, Branch, Time
SELECT 
    p.PlanName,
    t.Month,
    b.BranchName,
    rt.MonthlyTarget,
    SUM(br.AmountPaid) AS ActualRevenue,
    (SUM(br.AmountPaid) - rt.MonthlyTarget) AS Deviation
FROM
    RevenueTarget rt
        JOIN
    serviceplan p ON p.PlanID = rt.PlanID
        JOIN
    Branch b ON rt.BranchID = b.BranchID
        JOIN
    BillingRecord br ON b.BranchID = (SELECT 
            BranchID
        FROM
            Customer
        WHERE
            CustomerID = br.CustomerID
        LIMIT 1)
        JOIN
    Time t ON br.TimeID = t.TimeID
        AND t.TimeID = rt.TimeID
GROUP BY t.Month , b.BranchName , p.PlanName , rt.MonthlyTarget
ORDER BY t.Month;
-- =============================================================================================
-- 					🔍 QUERY 7. Average Ticket Resolution Time by Channel
-- =============================================================================================
-- Assesses which support channels resolve customer issues fastest.
-- It helps streamline support operations.
-- Join tables SupportTicket and Branch
SELECT 
    Channel,
    BranchName,
    ROUND(AVG(ResolutionTime), 2) AS AvgResolutionTime
FROM
    SupportTicket st
        JOIN
    Branch b ON b.BranchID = st.BranchID
GROUP BY Channel , BranchName
ORDER BY AvgResolutionTime ASC;
-- =============================================================================================
-- 					🔍 QUERY 8.  High-Activity Customers by branch (≥3 Tickets)
-- =============================================================================================
-- Identifies customers with high numbers of support interactions
-- Useful to track potential churn risks or VIP customers based on ticket volume.
-- Join tables SupportTicket, Customer, and Branch
SELECT 
    BranchName,
    cu.Name,
    cu.Last_name,
    COUNT(st.TicketID) AS TicketCount
FROM
    SupportTicket st
        JOIN
    Customer cu ON st.CustomerID = cu.CustomerID
        JOIN
    Branch b ON b.BranchID = cu.BranchID
GROUP BY cu.CustomerID
HAVING TicketCount >= 3
ORDER BY TicketCount DESC;
-- =============================================================================================
-- 					🏆 QUERY 9.  Top Performing Customer Service Satisfaction
-- =============================================================================================
-- Recognizes top branches in customer satisfaction.
-- It measures the average rep sat score and highligts top 3 branches above it.
-- Join tables SupportTicket, Employee, Branch
SELECT 
    b.BranchName,
    ROUND(AVG(st.CustomerSatisfaction), 2) AS AvgSatisfaction
FROM
    SupportTicket st
        JOIN
    Employee e ON st.EmployeeID = e.EmployeeID
        JOIN
    Branch b ON e.BranchID = b.BranchID
GROUP BY b.BranchName
ORDER BY AvgSatisfaction DESC
LIMIT 3;
-- =============================================================================================
-- 					⚠️ QUERY 10.  Bottom Performing Customer Service Satisfaction
-- =============================================================================================
-- Recognizes bottom branches in customer satisfaction.
-- It measures the average rep sat score and highligts bottom 3 branches below it.
-- Join tables SupportTicket, Employee, Branch
SELECT 
    b.BranchName,
    ROUND(AVG(st.CustomerSatisfaction), 2) AS AvgSatisfaction
FROM
    SupportTicket st
        JOIN
    Employee e ON st.EmployeeID = e.EmployeeID
        JOIN
    Branch b ON e.BranchID = b.BranchID
GROUP BY b.BranchName
ORDER BY AvgSatisfaction ASC
LIMIT 3;