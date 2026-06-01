
-- RETAIL STORE SALES — Exploration SQL

-- 1. Vue d'ensemble du CA total
SELECT
    COUNT(*)                          AS nb_lignes,
    COUNT(DISTINCT Store_ID)          AS nb_stores,
    COUNT(DISTINCT Dept_ID)           AS nb_depts,
    MIN(Date)                         AS date_debut,
    MAX(Date)                         AS date_fin,
    ROUND(SUM(Weekly_Sales_Clean), 2) AS ca_total,
    ROUND(AVG(Weekly_Sales_Clean), 2) AS ca_moyen_hebdo
FROM FACT_SALES;

-- 2. CA total par type de magasin (GROUP BY)
SELECT
    s.Type,
    s.Size_Category,
    COUNT(DISTINCT f.Store_ID)          AS nb_stores,
    ROUND(SUM(f.Weekly_Sales_Clean), 0) AS ca_total,
    ROUND(AVG(f.Weekly_Sales_Clean), 2) AS ca_moyen_hebdo,
    ROUND(SUM(f.Weekly_Sales_Clean) * 100.0
          / SUM(SUM(f.Weekly_Sales_Clean)) OVER (), 2) AS pct_ca_total
FROM FACT_SALES f
JOIN DIM_STORE s ON f.Store_ID = s.Store_ID
GROUP BY s.Type, s.Size_Category
ORDER BY ca_total DESC;

-- 3. Top 10 magasins par CA total
SELECT
    f.Store_ID,
    s.Store_Label,
    s.Type,
    s.Size_Category,
    ROUND(SUM(f.Weekly_Sales_Clean), 0) AS ca_total,
    ROUND(AVG(f.Weekly_Sales_Clean), 2) AS ca_moyen_hebdo,
    COUNT(DISTINCT f.Dept_ID)           AS nb_depts
FROM FACT_SALES f
JOIN DIM_STORE s ON f.Store_ID = s.Store_ID
GROUP BY f.Store_ID
ORDER BY ca_total DESC
LIMIT 10;

-- 4. Saisonnalité — CA par mois (GROUP BY + DATE)
SELECT
    d.Year,
    d.Month,
    d.Month_Name,
    ROUND(SUM(f.Weekly_Sales_Clean), 0) AS ca_total,
    ROUND(AVG(f.Weekly_Sales_Clean), 2) AS ca_moyen,
    COUNT(*) AS nb_transactions
FROM FACT_SALES f
JOIN DIM_DATE d ON f.Date = d.Date
GROUP BY d.Year, d.Month
ORDER BY d.Year, d.Month;

-- 5. Impact des semaines fériées vs normales
SELECT
    d.Holiday_Label,
    COUNT(*)                            AS nb_semaines,
    ROUND(SUM(f.Weekly_Sales_Clean), 0) AS ca_total,
    ROUND(AVG(f.Weekly_Sales_Clean), 2) AS ca_moyen,
    ROUND(MIN(f.Weekly_Sales_Clean), 2) AS ca_min,
    ROUND(MAX(f.Weekly_Sales_Clean), 2) AS ca_max
FROM FACT_SALES f
JOIN DIM_DATE d ON f.Date = d.Date
GROUP BY d.Holiday_Label
ORDER BY ca_moyen DESC;

-- 6. Top 10 départements par CA (tous stores confondus)
SELECT
    f.Dept_ID,
    d.Dept_Label,
    ROUND(SUM(f.Weekly_Sales_Clean), 0) AS ca_total,
    ROUND(AVG(f.Weekly_Sales_Clean), 2) AS ca_moyen,
    COUNT(DISTINCT f.Store_ID)          AS nb_stores
FROM FACT_SALES f
JOIN DIM_DEPT d ON f.Dept_ID = d.Dept_ID
GROUP BY f.Dept_ID
ORDER BY ca_total DESC
LIMIT 10;

-- 7. Données manquantes MarkDowns
SELECT
    COUNT(*) AS total_lignes,
    SUM(CASE WHEN MarkDown1 = 0 THEN 1 ELSE 0 END) AS md1_zero,
    SUM(CASE WHEN MarkDown2 = 0 THEN 1 ELSE 0 END) AS md2_zero,
    SUM(CASE WHEN MarkDown3 = 0 THEN 1 ELSE 0 END) AS md3_zero,
    SUM(CASE WHEN MarkDown4 = 0 THEN 1 ELSE 0 END) AS md4_zero,
    SUM(CASE WHEN MarkDown5 = 0 THEN 1 ELSE 0 END) AS md5_zero,
    ROUND(SUM(CASE WHEN Has_MarkDown = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
        AS pct_avec_markdown
FROM DIM_MARKDOWN;
