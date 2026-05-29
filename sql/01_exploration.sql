-- ╔══════════════════════════════════════════════════════════════╗
-- ║           sql/01_exploration.sql — Requêtes EDA             ║
-- ║   Templates de requêtes SQL pour explorer vos données       ║
-- ╚══════════════════════════════════════════════════════════════╝
-- 
-- COMMENT UTILISER CE FICHIER :
--   → Dans un notebook Python : pd.read_sql(query, conn)
--   → Dans DBeaver, TablePlus, ou tout autre client SQL
--   → Remplace 'ta_table' par le nom de ta table réelle
-- ───────────────────────────────────────────────────────────────


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 1. APERÇU GÉNÉRAL
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- Nombre total de lignes
SELECT COUNT(*) AS nb_lignes
FROM ta_table;

-- Aperçu des premières lignes
SELECT *
FROM ta_table
LIMIT 10;

-- Lister les colonnes et leurs types (PostgreSQL)
SELECT 
    column_name,
    data_type,
    is_nullable,
    character_maximum_length
FROM information_schema.columns
WHERE table_name = 'ta_table'
ORDER BY ordinal_position;


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 2. QUALITÉ DES DONNÉES
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- Compter les valeurs NULL par colonne (exemple pour 4 colonnes)
-- ⚠️ Adapte la liste de colonnes selon ton schéma
SELECT
    COUNT(*) AS total_lignes,
    SUM(CASE WHEN colonne1 IS NULL THEN 1 ELSE 0 END) AS null_colonne1,
    SUM(CASE WHEN colonne2 IS NULL THEN 1 ELSE 0 END) AS null_colonne2,
    SUM(CASE WHEN colonne3 IS NULL THEN 1 ELSE 0 END) AS null_colonne3,
    ROUND(100.0 * SUM(CASE WHEN colonne1 IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_null_colonne1
FROM ta_table;

-- Détecter les doublons (sur toutes les colonnes)
SELECT *, COUNT(*) AS nb_occurrences
FROM ta_table
GROUP BY colonne1, colonne2, colonne3  -- liste toutes tes colonnes
HAVING COUNT(*) > 1
ORDER BY nb_occurrences DESC;

-- Valeurs uniques d'une colonne catégorielle
SELECT 
    departement,
    COUNT(*)              AS nb,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pourcentage
FROM ta_table
GROUP BY departement
ORDER BY nb DESC;


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 3. STATISTIQUES DESCRIPTIVES
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- Stats complètes pour une variable numérique (PostgreSQL)
SELECT
    COUNT(salaire)                        AS nb_valeurs,
    COUNT(*) - COUNT(salaire)             AS valeurs_manquantes,
    ROUND(AVG(salaire)::NUMERIC, 2)       AS moyenne,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY salaire) AS mediane,
    MIN(salaire)                          AS minimum,
    MAX(salaire)                          AS maximum,
    ROUND(STDDEV(salaire)::NUMERIC, 2)    AS ecart_type,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salaire) AS q1,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salaire) AS q3
FROM ta_table
WHERE salaire IS NOT NULL;

-- Détection des outliers via IQR en SQL
WITH stats AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salaire) AS q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salaire) AS q3
    FROM ta_table
)
SELECT t.*
FROM ta_table t, stats s
WHERE t.salaire < s.q1 - 1.5 * (s.q3 - s.q1)
   OR t.salaire > s.q3 + 1.5 * (s.q3 - s.q1);


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 4. ANALYSE BIVARIÉE
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- Moyenne d'une variable numérique par groupe
SELECT
    departement,
    COUNT(*)                          AS nb_employes,
    ROUND(AVG(salaire)::NUMERIC, 2)   AS salaire_moyen,
    ROUND(AVG(anciennete)::NUMERIC, 1) AS anciennete_moy
FROM ta_table
GROUP BY departement
ORDER BY salaire_moyen DESC;

-- Taux de la variable cible par catégorie
SELECT
    departement,
    COUNT(*)                                    AS total,
    SUM(quitte_entreprise)                      AS departs,
    ROUND(100.0 * AVG(quitte_entreprise), 2)    AS taux_depart_pct
FROM ta_table
GROUP BY departement
ORDER BY taux_depart_pct DESC;

-- Tableau croisé (pivot simple) — occurrences croisées
SELECT
    departement,
    satisf_score,
    COUNT(*) AS nb
FROM ta_table
GROUP BY departement, satisf_score
ORDER BY departement, satisf_score;


-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 5. REQUÊTES TEMPORELLES (si date présente)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- Agrégation mensuelle
SELECT
    DATE_TRUNC('month', date_colonne) AS mois,
    COUNT(*)                           AS nb_evenements,
    SUM(montant)                       AS total_montant
FROM ta_table
GROUP BY DATE_TRUNC('month', date_colonne)
ORDER BY mois;

-- Évolution sur les 12 derniers mois
SELECT *
FROM ta_table
WHERE date_colonne >= CURRENT_DATE - INTERVAL '12 months'
ORDER BY date_colonne DESC;
