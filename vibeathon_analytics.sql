-- PROJECT: Campus Space & Free Classroom Monitoring App Analytics (Vibathon Hackathon)
-- Author: Galina Abelyan
-- Objective: Calculate student activity, weekly retention, and total user contribution metrics.

-- 1. DAILY ACTIVE USERS (DAU) COMPUTATION
-- Count unique students checking in or monitoring classroom availability per day
SELECT 
    visit_date, 
    COUNT(DISTINCT student_id) AS dau
FROM classroom_visits
GROUP BY visit_date
ORDER BY visit_date DESC;

-- 2. WEEKLY COHORT RETENTION RATE
-- Measure how many new students returned to the app in Week 2 (Days 7-14)
WITH first_visit AS (
    SELECT 
        student_id, 
        MIN(visit_date) AS join_date
    FROM classroom_visits
    GROUP BY student_id
)
SELECT 
    f.join_date,
    COUNT(DISTINCT f.student_id) AS new_students,
    COUNT(DISTINCT v.student_id) AS returned_students,
    ROUND(
        COUNT(DISTINCT v.student_id)::numeric / NULLIF(COUNT(DISTINCT f.student_id), 0), 
        2
    ) AS retention_rate
FROM first_visit f
LEFT JOIN classroom_visits v 
    ON f.student_id = v.student_id 
   AND v.visit_date BETWEEN f.join_date + INTERVAL '7 days' AND f.join_date + INTERVAL '14 days'
GROUP BY f.join_date
ORDER BY f.join_date DESC;

-- 3. TOTAL USER VALUE CALCULATION (Monetary + Engagement Points)
-- Aggregate overall student contribution (donations + activity points)
SELECT 
    student_id, 
    SUM(amount_rub) AS total_cash,
    SUM(karma_points) AS total_karma,
    (SUM(amount_rub) + SUM(karma_points) * 10) AS total_user_value -- Total Value Metric
FROM user_donations
GROUP BY student_id
ORDER BY total_user_value DESC;
