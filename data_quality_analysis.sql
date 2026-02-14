-- ПРОЕКТ: Валидация финансовых данных и расчет KPI
-- Автор: Галина Абелян

-- 1. ПРОВЕРКА ДАТА-КОНТРАКТА (Целостность и полнота)
-- Ищем записи, где нарушены бизнес-требования: пустые суммы или некорректные даты
SELECT 
    'Missing Critical Data' as issue_type,
    count(*) as affected_rows
FROM financial_transactions
WHERE transaction_amount IS NULL 
   OR user_id IS NULL 
   OR transaction_date > CURRENT_DATE;

-- 2. ПОИСК ДУБЛИКАТОВ И "ЗОЛОТАЯ ЗАПИСЬ"
WITH DeduplicatedData AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY transaction_id 
            ORDER BY updated_at DESC -- Берем самую свежую версию транзакции
        ) as row_num
    FROM raw_payments
)
SELECT * FROM DeduplicatedData 
WHERE row_num = 1;

-- 3. РАСЧЕТ ПРОДУКТОВЫХ МЕТРИК (AD-HOC запрос)
-- считаем Retention или активность (DAU)
SELECT 
    date_trunc('day', login_time) as day,
    count(distinct user_id) as dau,
    count(login_id) as total_sessions
FROM user_logins
GROUP BY 1
ORDER BY 1 DESC;
