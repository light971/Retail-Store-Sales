-- 1. REGEX — Extraction et nettoyage des labels ───────────

-- Identifier les départements avec numéro > 50 (via pattern)
SELECT
    deptid,
    deptlabel,
    CASE
        WHEN deptlabel ~ '^Dept_[0-9]{2}$' THEN 'Format standard'
        ELSE 'Format non standard'
    END AS label_format
FROM dimdept
ORDER BY deptid;

-- Filtrer les stores dont le label correspond au pattern "Store_XX"
SELECT
    storeid,
    storelabel,
    storetype,
    storesize
FROM dimstore
WHERE storelabel ~ '^Store_[0-9]{2}$'
ORDER BY storeid;


-- ── 2. WINDOW FUNCTIONS — Ranking et comparaisons ───────────

-- Rang des magasins par CA hebdomadaire moyen (RANK)
SELECT
    f.storeid,
    s.storelabel,
    s.storetype,
    ROUND(AVG(f.weeklysalesclean)::numeric, 2) AS ca_moyen,
    RANK() OVER (ORDER BY AVG(f.weeklysalesclean) DESC) AS rang_global,
    RANK() OVER (PARTITION BY s.storetype
     ORDER BY AVG(f.weeklysalesclean) DESC) AS rang_par_type
FROM factsales f
JOIN dimstore s ON f.storeid = s.storeid
GROUP BY f.storeid, s.storelabel, s.storetype -- Correction ici : Ajout des colonnes requises dans le GROUP BY
ORDER BY rang_global;

-- ── 3. CASE WHEN — Segmentation métier ─────────────────────

-- Segmentation des semaines par intensité promotionnelle
SELECT
    m.storeid,
    m.date,
    m.totalmarkdown,
    CASE
        WHEN m.totalmarkdown = 0 OR m.totalmarkdown IS NULL THEN 'Aucune promo'
        WHEN m.totalmarkdown < 5000  THEN 'Promo faible'
        WHEN m.totalmarkdown < 20000 THEN 'Promo modérée'
        WHEN m.totalmarkdown < 50000 THEN 'Promo forte'
        ELSE 'Promo très forte'
    END AS intensite_promo,
    ROUND(AVG(f.weeklysalesclean)::numeric, 2) AS ca_moyen
FROM dimmarkdown m
JOIN factsales f ON m.storeid = f.storeid AND m.date = f.date
GROUP BY m.storeid, m.date, m.totalmarkdown -- Utile et suffisant car totalmarkdown détermine le CASE WHEN
ORDER BY m.totalmarkdown DESC;


-- ── 4. CTE — Analyse de l'impact markdown sur le CA ─────────
WITH base AS (
    SELECT
        f.storeid,
        f.date,
        f.weeklysalesclean,
        m.totalmarkdown,
        m.hasmarkdown,
        CASE
            WHEN m.totalmarkdown = 0 OR m.totalmarkdown IS NULL THEN 'Aucune promo'
            WHEN m.totalmarkdown < 5000 THEN 'Promo faible'
            WHEN m.totalmarkdown < 20000 THEN 'Promo modérée'
            ELSE 'Promo forte'
        END AS segment_promo
    FROM factsales f
    LEFT JOIN dimmarkdown m ON f.storeid = m.storeid AND f.date = m.date
),
stats AS (
    SELECT
        segment_promo,
        COUNT(*)                                  AS nb_semaines,
        ROUND(AVG(weeklysalesclean)::numeric, 2) AS ca_moyen,
        ROUND(SUM(weeklysalesclean)::numeric, 0) AS ca_total
    FROM base
    GROUP BY segment_promo
),
global AS (
    SELECT ROUND(AVG(weeklysalesclean)::numeric, 2) AS ca_global_moyen
    FROM base
)
SELECT
    s.segment_promo,
    s.nb_semaines,
    s.ca_moyen,
    s.ca_total,
    ROUND(((s.ca_moyen - g.ca_global_moyen) * 100.0 / g.ca_global_moyen)::numeric, 2) AS lift_vs_moyenne_pct
FROM stats s, global g
ORDER BY s.ca_moyen DESC;

-- 5. Impact des semaines fériées vs normales
SELECT
    d.holidaylabel,
    COUNT(*) AS nb_semaines,
    ROUND(SUM(f.weeklysalesclean)::numeric, 0) AS ca_total,
    ROUND(AVG(f.weeklysalesclean)::numeric, 2) AS ca_moyen,
    ROUND(MIN(f.weeklysalesclean)::numeric, 2) AS ca_min,
    ROUND(MAX(f.weeklysalesclean)::numeric, 2) AS ca_max
FROM factsales f
JOIN dimdate d ON f.date = d.date
GROUP BY d.holidaylabel
ORDER BY ca_moyen DESC;