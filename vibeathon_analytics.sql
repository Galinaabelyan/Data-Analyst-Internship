-- ПРОЕКТ: Аналитика для коворкинга (Хакатон "Вайбатон")
-- Задача: Расчет метрик активности и вовлеченности студентов

-- 1. Расчет DAU (Daily Active Users)
-- Считаем уникальных студентов, которые посетили коворкинг или забронировали место за день
SELECT 
    visit_date, 
    COUNT(DISTINCT student_id) as dau
FROM coworking_visits
GROUP BY visit_date
ORDER BY visit_date DESC;

-- 2. Расчет Retention (Возвращаемость)
-- Проверяем, сколько студентов вернулись в коворкинг на следующей неделе
WITH first_visit AS (
    SELECT student_id, MIN(visit_date) as join_date
    FROM coworking_visits
    GROUP BY student_id
)
SELECT 
    f.join_date,
    COUNT(DISTINCT f.student_id) as new_students,
    COUNT(DISTINCT v.student_id) as returned_students,
    ROUND(COUNT(DISTINCT v.student_id)::numeric / COUNT(DISTINCT f.student_id), 2) as retention_rate
FROM first_visit f
LEFT JOIN coworking_visits v 
    ON f.student_id = v.student_id 
    AND v.visit_date BETWEEN f.join_date + INTERVAL '7 days' AND f.join_date + INTERVAL '14 days'
GROUP BY f.join_date;

-- 3. Анализ донатов (LTV)
-- Агрегируем общий вклад студента (деньги + баллы за волонтерство)
SELECT 
    student_id, 
    SUM(amount_rub) as total_cash,
    SUM(karma_points) as total_karma,
    (SUM(amount_rub) + SUM(karma_points) * 10) as total_contribution_value -- Условный LTV
FROM donations
GROUP BY student_id
ORDER BY total_contribution_value DESC;
