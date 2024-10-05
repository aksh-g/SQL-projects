--- Shows top 3 transaction generating branches and their respective merchants for every year ---

WITH RankedBranches AS (
    SELECT 
        t.branch_id, 
        COUNT(t.transaction_id) AS total_order, 
        m.merchant_name, 
        YEAR(t.transaction_date) AS year_of_sale,
        ROW_NUMBER() OVER (PARTITION BY YEAR(t.transaction_date) ORDER BY COUNT(t.transaction_id) DESC) AS rank_
    FROM 
        new_schema.transactions t 
    JOIN 
        new_schema.branches b 
    ON 
        t.branch_id = b.branch_id 
    JOIN 
        new_schema.merchants m 
    ON 
        m.merchant_id = b.merchant_id
    GROUP BY 
        t.branch_id, m.merchant_name, YEAR(t.transaction_date)
)
SELECT 
    branch_id, 
    merchant_name, 
    total_order, 
    year_of_sale
FROM 
    RankedBranches
WHERE 
    rank_ <= 3
ORDER BY 
    year_of_sale DESC , rank_, total_order DESC 



--- Branches with their total number of transactions for the current year (2024) ---

SELECT branch_id, YEAR(transaction_date) AS year_of_transaction,
       COUNT(transaction_id) AS total_transactions
FROM new_schema.transactions
GROUP BY branch_id, year_of_transaction
HAVING year_of_transaction = '2024'
ORDER BY total_transactions DESC


--- Cities driving most transactions ---

SELECT COUNT(transaction_id) AS total_sales, ci.city_name
FROM new_schema.customers cu JOIN new_schema.transactions t ON cu.customer_id = t.customer_id INNER JOIN new_schema.cities ci ON ci.city_id = cu.city_id
GROUP BY ci.city_name
ORDER BY total_sales DESC