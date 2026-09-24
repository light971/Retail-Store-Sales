# Retail Store Sales — Analyse Marketing Data
## Optimisation des ventes hebdomadaires par magasin, département et période promotionnelle

> **Problématique** : Comment identifier les leviers d'optimisation des ventes hebdomadaires par magasin et département, en mesurant l'impact des promotions (markdowns), des périodes de fêtes et du type de magasin sur le chiffre d'affaires ?

---

## 🗂️ Structure du projet

```
Retail-Store-Sales/
│
├── 📁 data/
│   ├── 📁 raw/                 # Fichiers sources (train.csv, stores.csv, features.csv, test.csv)
│   ├── 📁 processed/           # Données nettoyées, jointes et enrichies
│   └── 📁 star_schema/         # Tables de dimensions et de faits prêtes pour l'analyse
│
├── 📁 docs/                    # Documentation complémentaire
│
├── 📓 notebooks/
│   ├── 📄 01_chargement_jointures.ipynb  # Qualité des données, jointures et nettoyage
│   ├── 📄 02_eda_analyse.ipynb           # Analyse exploratoire (EDA) & segmentation des magasins
│   ├── 📄 03_sql_analyse.ipynb           # Prototypage et requêtes SQL avancées
│   └── 📄 04_dashboard_prep.ipynb        # Préparation et agrégation des données pour Power BI
│
├── 📤 outputs/
│   ├── 📁 figures/             # Graphiques et visualisations exportés (.png, .jpeg)
│   ├── 📁 tables/              # Extractions et KPI intermédiaires (.csv)
│   └── 📁 powerbi/             # Rapport Power BI (.pbix) et exports
│
├── 🐍 scripts/
│   ├── 📄 data_loader.py       # Fonctions de chargement et pipeline de nettoyage
│   ├── 📄 sql_helpers.py       # Connexion PostgreSQL & exécution des requêtes
│   └── 📄 viz_helpers.py       # Fonctions de visualisation réutilisables
│
├── 🗄️ sql/
│   ├── 📄 01_exploration.sql         # Requêtes de découverte et statistiques descriptives
│   └── 📄 02_analyses_avancees.sql   # Calcul des KPI complexes et vues analytiques
│
├── ⚙️ .gitignore               # Exclusion des fichiers système et des identifiants
├── 📋 requirements.txt         # Dépendances Python (pandas, psycopg2, matplotlib...)
└── 📝 README.md                # Présentation du projet, installation et cas d'usage
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
git clone https://github.com/light971/Retail-Store-Sales.git
cd Retail-Store-Sales
pip install -r requirements.txt
jupyter notebook notebooks/01_chargement_jointures.ipynb
```

**Source** : [Kaggle — Retail Store Sales Forecasting Dataset](https://www.kaggle.com/datasets/noopurbhatt/retail-store-sales-forecasting-dataset)

---

*Malcom Closse · Marketing Data Analyst · github.com/light971*
