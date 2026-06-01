-- ============================================================
-- RETAIL STORE SALES — Analyses SQL avancées
-- REGEX · WINDOW FUNCTIONS · CASE WHEN · CTEs
-- ============================================================

-- ── 1. REGEX — Extraction et nettoyage des labels ───────────
-- Identifier les départements avec numéro > 50 (via pattern)
SELECT
    Dept_ID,
    Dept_Label,
    CASE
        WHEN Dept_Label REGEXP '^Dept_[0-9]{2}$' THEN 'Format standard'
        ELSE 'Format non standard'
    END AS label_format
FROM DIM_DEPT
ORDER BY Dept_ID;

-- Filtrer les stores dont le label correspond au pattern "Store_XX"
SELECT
    Store_ID,
    Store_Label,
    Type,
    Size
FROM DIM_STORE
WHERE Store_Label REGEXP '^Store_[0-9]{2}$'
ORDER BY Store_ID;

-- ── 2. WINDOW FUNCTIONS — Ranking et comparaisons ───────────

-- Rang des magasins par CA hebdomadaire moyen (RANK)
SELECT
    f.Store_ID,
    s.Store_Label,
    s.Type,
    ROUND(AVG(f.Weekly_Sales_Clean), 2) AS ca_moyen,
    RANK() OVER (ORDER BY AVG(f.Weekly_Sales_Clean) DESC) AS rang_global,
    RANK() OVER (PARTITION BY s.Type
                 ORDER BY AVG(f.Weekly_Sales_Clean) DESC) AS rang_par_type
FROM FACT_SALES f
JOIN DIM_STORE s ON f.Store_ID = s.Store_ID
GROUP BY f.Store_ID
ORDER BY rang_global;

-- Évolution du CA semaine sur semaine (LAG)
SELECT
    f.Store_ID,
    f.Date,
    ROUND(SUM(f.Weekly_Sales_Clean), 0) AS ca_semaine,
    ROUND(LAG(SUM(f.Weekly_Sales_Clean))
          OVER (PARTITION BY f.Store_ID ORDER BY f.Date), 0) AS ca_semaine_precedente,
    ROUND(
        (SUM(f.Weekly_Sales_Clean)
         - LAG(SUM(f.Weekly_Sales_Clean)) OVER (PARTITION BY f.Store_ID ORDER BY f.Date))
        * 100.0
        / NULLIF(LAG(SUM(f.Weekly_Sales_Clean))
                 OVER (PARTITION BY f.Store_ID ORDER BY f.Date), 0),
    2) AS evolution_pct
FROM FACT_SALES f
GROUP BY f.Store_ID, f.Date
ORDER BY f.Store_ID, f.Date;

-- Déciles de performance des stores (NTILE)
WITH store_perf AS (
    SELECT
        f.Store_ID,
        s.Store_Label,
        s.Type,
        ROUND(SUM(f.Weekly_Sales_Clean), 0) AS ca_total
    FROM FACT_SALES f
    JOIN DIM_STORE s ON f.Store_ID = s.Store_ID
    GROUP BY f.Store_ID
)
SELECT
    Store_ID,
    Store_Label,
    Type,
    ca_total,
    NTILE(10) OVER (ORDER BY ca_total DESC) AS decile,
    CASE NTILE(10) OVER (ORDER BY ca_total DESC)
        WHEN 1  THEN 'Top 10%'
        WHEN 2  THEN 'Top 20%'
        WHEN 10 THEN 'Bottom 10%'
        ELSE 'Mid'
    END AS performance_label
FROM store_perf
ORDER BY ca_total DESC;

-- ── 3. CASE WHEN — Segmentation métier ─────────────────────

-- Segmentation des semaines par intensité promotionnelle
SELECT
    m.Store_ID,
    m.Date,
    m.Total_MarkDown,
    CASE
        WHEN m.Total_MarkDown = 0           THEN 'Aucune promo'
        WHEN m.Total_MarkDown < 5000        THEN 'Promo faible'
        WHEN m.Total_MarkDown < 20000       THEN 'Promo modérée'
        WHEN m.Total_MarkDown < 50000       THEN 'Promo forte'
        ELSE                                     'Promo très forte'
    END AS intensite_promo,
    ROUND(AVG(f.Weekly_Sales_Clean), 2) AS ca_moyen
FROM DIM_MARKDOWN m
JOIN FACT_SALES f ON m.Store_ID = f.Store_ID AND m.Date = f.Date
GROUP BY m.Store_ID, m.Date, m.Total_MarkDown
ORDER BY m.Total_MarkDown DESC;

-- ── 4. CTE — Analyse de l'impact markdown sur le CA ─────────
WITH base AS (
    SELECT
        f.Store_ID,
        f.Date,
        f.Weekly_Sales_Clean,
        m.Total_MarkDown,
        m.Has_MarkDown,
        CASE
            WHEN m.Total_MarkDown = 0    THEN 'Aucune promo'
            WHEN m.Total_MarkDown < 5000 THEN 'Promo faible'
            WHEN m.Total_MarkDown < 20000 THEN 'Promo modérée'
            ELSE                              'Promo forte'
        END AS segment_promo
    FROM FACT_SALES f
    LEFT JOIN DIM_MARKDOWN m ON f.Store_ID = m.Store_ID AND f.Date = m.Date
),
stats AS (
    SELECT
        segment_promo,
        COUNT(*)                        AS nb_semaines,
        ROUND(AVG(Weekly_Sales_Clean), 2) AS ca_moyen,
        ROUND(SUM(Weekly_Sales_Clean), 0) AS ca_total
    FROM base
    GROUP BY segment_promo
),
global AS (
    SELECT ROUND(AVG(Weekly_Sales_Clean), 2) AS ca_global_moyen
    FROM base
)
SELECT
    s.segment_promo,
    s.nb_semaines,
    s.ca_moyen,
    s.ca_total,
    ROUND((s.ca_moyen - g.ca_global_moyen) * 100.0 / g.ca_global_moyen, 2) AS lift_vs_moyenne_pct
FROM stats s, global g
ORDER BY s.ca_moyen DESC;

-- ── 5. GROUP BY ROLLUP — CA par Store, Dept, Total ──────────
SELECT
    COALESCE(CAST(f.Store_ID AS TEXT), 'TOUS LES STORES') AS Store,
    COALESCE(CAST(f.Dept_ID AS TEXT),  'TOUS LES DEPTS')  AS Dept,
    ROUND(SUM(f.Weekly_Sales_Clean), 0) AS ca_total,
    COUNT(*) AS nb_semaines
FROM FACT_SALES f
GROUP BY f.Store_ID, f.Dept_ID
ORDER BY f.Store_ID NULLS LAST, f.Dept_ID NULLS LAST;
