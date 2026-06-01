
-- RETAIL STORE SALES — Exploration SQL

-- 1. Vue d'ensemble du CA total
SELECT
    COUNT(*)                             AS nb_lignes,
    COUNT(DISTINCT storeid)              AS nb_stores,
    COUNT(DISTINCT deptid)               AS nb_depts,
    MIN(date)                            AS date_debut,
    MAX(date)                            AS date_fin,
    ROUND(SUM(weeklysalesclean)::numeric, 2) AS ca_total,
    ROUND(AVG(weeklysalesclean)::numeric, 2) AS ca_moyen_hebdo
FROM factsales;

-- 2. CA total par type de magasin (GROUP BY)
SELECT
    s.storetype,
    s.sizecategory,
    COUNT(DISTINCT f.storeid)            AS nb_stores,
    ROUND(SUM(f.weeklysalesclean)::numeric, 0) AS ca_total,
    ROUND(AVG(f.weeklysalesclean)::numeric, 2) AS ca_moyen_hebdo,
    -- Correction du SUM(SUM()) par une fonction de fenêtrage standard
    ROUND((SUM(f.weeklysalesclean) * 100.0 / SUM(SUM(f.weeklysalesclean)) OVER())::numeric, 2) AS pct_ca_total
FROM factsales f
JOIN dimstore s ON f.storeid = s.storeid
GROUP BY s.storetype, s.sizecategory
ORDER BY ca_total DESC;

-- 3. Top 10 magasins par CA total
SELECT
    f.storeid,
    s.storelabel,
    s.storetype,
    s.sizecategory,
    ROUND(SUM(f.weeklysalesclean)::numeric, 0) AS ca_total,
    ROUND(AVG(f.weeklysalesclean)::numeric, 2) AS ca_moyen_hebdo,
    COUNT(DISTINCT f.deptid)             AS nb_depts
FROM factsales f
JOIN dimstore s ON f.storeid = s.storeid
GROUP BY f.storeid, s.storelabel, s.storetype, s.sizecategory -- Correction du GROUP BY
ORDER BY ca_total DESC
LIMIT 10;

-- 4. Saisonnalité — CA par mois (GROUP BY + DATE)
SELECT
    d.year,
    d.month,
    d.monthname,
    ROUND(SUM(f.weeklysalesclean)::numeric, 0) AS ca_total,
    ROUND(AVG(f.weeklysalesclean)::numeric, 2) AS ca_moyen,
    COUNT(*)                             AS nb_transactions
FROM factsales f
JOIN dimdate d ON f.date = d.date
GROUP BY d.year, d.month, d.monthname -- Correction du GROUP BY (monthname ajouté)
ORDER BY d.year, d.month;


-- 5. Top 10 départements par CA (tous stores confondus)
SELECT
    f.deptid,
    d.deptlabel,
    ROUND(SUM(f.weeklysalesclean)::numeric, 0) AS ca_total,
    ROUND(AVG(f.weeklysalesclean)::numeric, 2) AS ca_moyen,
    COUNT(DISTINCT f.storeid)            AS nb_stores
FROM factsales f
JOIN dimdept d ON f.deptid = d.deptid
GROUP BY f.deptid, d.deptlabel -- Correction du GROUP BY
ORDER BY ca_total DESC
LIMIT 10;

-- 7. Données manquantes MarkDowns
SELECT
    COUNT(*) AS total_lignes,
    SUM(CASE WHEN markdown1 = 0 THEN 1 ELSE 0 END) AS md1_zero,
    SUM(CASE WHEN markdown2 = 0 THEN 1 ELSE 0 END) AS md2_zero,
    SUM(CASE WHEN markdown3 = 0 THEN 1 ELSE 0 END) AS md3_zero,
    SUM(CASE WHEN markdown4 = 0 THEN 1 ELSE 0 END) AS md4_zero,
    SUM(CASE WHEN markdown5 = 0 THEN 1 ELSE 0 END) AS md5_zero,
    ROUND((SUM(CASE WHEN hasmarkdown = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*))::numeric, 2) AS pct_avec_markdown
FROM dimmarkdown;