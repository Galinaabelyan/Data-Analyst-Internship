-- PROJECT: Financial Data Integrity & Product KPI Validation
-- Author: Galina Abelyan

-- 1. DATA CONTRACT VALIDATION (Integrity & Completeness Check)
-- Identify records violating business rules: missing critical values or future dates
SELECT 
    'Missing Critical Data' AS issue_type,
    COUNT(*) AS affected_rows
FROM financial_transactions
WHERE transaction_amount IS NULL 
   OR user_id IS NULL 
   OR transaction_date > CURRENT_DATE;

-- 2. DEDUPLICATION & MASTER RECORD SELECTION (Golden Record)
-- Filter out duplicate payment events, retaining only the latest transaction status
WITH DeduplicatedData AS (
    SELECT 
        raw_payments.*,
        ROW_NUMBER() OVER (
            PARTITION BY transaction_id 
            ORDER BY updated_at DESC -- Retrieve the most recent version of the transaction
        ) AS row_num
    FROM raw_payments
)
SELECT 
    -- Exclude technical 'row_num' column from final master output
    * EXCEPT(row_num)
FROM DeduplicatedData 
WHERE row_num = 1;

-- 3. PRODUCT METRICS COMPUTATION (Daily Active Users & Session Volume)
-- Aggregate unique daily active users (DAU) and total user login sessions
SELECT 
    DATE_TRUNC('day', login_time) AS login_day,
    COUNT(DISTINCT user_id) AS dau,
    COUNT(login_id) AS total_sessions
FROM user_logins
GROUP BY login_day
ORDER BY login_day DESC;
