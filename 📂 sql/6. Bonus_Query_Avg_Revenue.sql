-- =============================================================================================
-- ✨ QUERY 11. BONUS QUERY: Branches With Above-Average Revenue Per Country
-- =============================================================================================
--  Compares each branch's revenue against the average revenue of branches in the same country
-- It identifies branches with above average revenue performance
-- Join tables BillingRecord, Branch, Country and Customer
SELECT 
    b.BranchID,
    b.BranchName,
    c.CountryName,
    SUM(br.AmountPaid) AS TotalRevenue
FROM
    Branch b
        JOIN
    Country c ON b.CountryID = c.CountryID
        JOIN
    Customer cu ON cu.BranchID = b.BranchID
        JOIN
    BillingRecord br ON br.CustomerID = cu.CustomerID
GROUP BY b.BranchID , c.CountryName
HAVING TotalRevenue > (SELECT 
        AVG(sub.TotalBranchRevenue)
    FROM
        (SELECT 
            b2.BranchID, SUM(br2.AmountPaid) AS TotalBranchRevenue
        FROM
            Branch b2
        JOIN Country c2 ON b2.CountryID = c2.CountryID
        JOIN Customer cu2 ON cu2.BranchID = b2.BranchID
        JOIN BillingRecord br2 ON br2.CustomerID = cu2.CustomerID
        WHERE
            c2.CountryName = c.CountryName
        GROUP BY b2.BranchID) AS sub)
ORDER BY c.CountryName , TotalRevenue DESC;
