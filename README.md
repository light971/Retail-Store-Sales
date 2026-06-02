# Retail Store Sales — Analyse Marketing Data
## Optimisation des ventes hebdomadaires par magasin, département et période promotionnelle

> **Problématique** : Comment identifier les leviers d'optimisation des ventes hebdomadaires par magasin et département, en mesurant l'impact des promotions (markdowns), des périodes de fêtes et du type de magasin sur le chiffre d'affaires ?

---

## 🗂️ Structure du projet

```
retail_project/
│
├── 📁 data/
│   ├── 📁 raw/                 # Fichiers sources (train.csv, stores.csv, features.csv, test.csv)
│   ├── 📁 processed/           # Données nettoyées, jointes et enrichies
│   └── 📁 star_schema/         # Tables dimensionnelles et de faits prêtes pour l'analyse
│
├── 📓 notebooks/
│   ├── 📄 01_chargement_jointures.ipynb  # Qualité des données, jointures et cleaning
│   ├── 📄 02_eda_analyse.ipynb          # Analyse exploratoire (EDA) & segmentation clients
│   ├── 📄 03_sql_analyse.ipynb          # Prototypage et requêtes SQL avancées
│   └── 📄 04_dashboard_prep.ipynb       # Préparation et agrégation des données pour Power BI
│
├── 📤 outputs/
│   ├── 📁 figures/             # Graphiques et visualisations exportés (.png, .jpeg)
│   ├── 📁 tables/              # Extractions et KPIs intermédiaires (.csv)
│   └── 📁 powerbi/             # Fichier rapport (.pbix) et exports spécifiques
│
├── 🐍 scripts/
│   ├── 📄 data_loader.py       # Fonctions de chargement et pipeline de nettoyage
│   ├── 📄 sql_helpers.py       # Gestion de la connexion PostgreSQL & exécution des requêtes
│   └── 📄 viz_helpers.py       # Fonctions de visualisation réutilisables
│
├── 🗄️ sql/
│   ├── 📄 01_exploration.sql   # Requêtes de découverte et statistiques descriptives
│   └── 📄 02_analyses_avancees.sql # Calcul des KPIs complexes et vues analytiques
│
├── ⚙️ .gitignore               # Exclusion des gros volumes de données (data/) et des credentials
├── 📝 README.md                # Présentation du projet, installation et cas d'usage
└── 📋 requirements.txt         # Dépendances Python (pandas, psycopg2, matplotlib...)
```

---

## ❓ Questions auxquelles ce projet répond

1. Quels magasins et départements génèrent le plus de CA hebdomadaire ?
2. Les semaines de fêtes sur-performent-elles réellement ?
3. Les promotions (MarkDown1-5) ont-elles un impact mesurable sur les ventes ?
4. Le type de magasin (A/B/C) influence-t-il la performance ?
5. Peut-on segmenter les magasins par profil de performance ?

---

## Schéma en étoile Power BI

```
          DIM_DATE ──────────────────────┐
              │                          │
         DIM_STORE ──── FACT_SALES ──── DIM_MARKDOWN
              │              │
          DIM_DEPT ──────────┘
```

---

## 🛠️ Stack technique

| Domaine | Outils |
|--------|--------|
| Langage | Python 3.12.7 |
| Manipulation données | Pandas, NumPy |
| SQL | PostgrSQL |
| Visualisation | Matplotlib, Seaborn |
| Dashboard | Power BI |
| Environnement | VS Code + Jupyter |

---

## Lancer le projet

```bash
git clone https://github.com/light971/retail-sales-analysis.git
cd retail-sales-analysis
pip install -r requirements.txt
jupyter notebook notebooks/01_chargement_jointures.ipynb
```

**Source** : [Kaggle — Retail Store Sales Forecasting Dataset](https://www.kaggle.com/datasets/noopurbhatt/retail-store-sales-forecasting-dataset)

---

*Malcom Closse · Marketing Data Analyst · github.com/light971*
