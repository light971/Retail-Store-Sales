# Retail Store Sales — Analyse Marketing Data
## Optimisation des ventes hebdomadaires par magasin, département et période promotionnelle

> **Problématique** : Comment identifier les leviers d'optimisation des ventes hebdomadaires par magasin et département, en mesurant l'impact des promotions (markdowns), des périodes de fêtes et du type de magasin sur le chiffre d'affaires ?

---

## 🗂️ Structure du projet

```
retail_project/
│
├── 📓 notebooks/
│   ├── 01_chargement_jointures.ipynb     ← Chargement, jointures, qualité
│   ├── 02_eda_analyse.ipynb              ← EDA & segmentation
│   ├── 03_sql_analyse.ipynb              ← Requêtes SQL avancées
│   
│
├── 🐍 scripts/
│   ├── data_loader.py                   ← Chargement & jointures
│   ├── viz_helpers.py                   ← Visualisations réutilisables
│   └── sql_helpers.py                   ← Connexion SQLite & requêtes
│
├── 🗄️ sql/
│   ├── 01_exploration.sql               ← Requêtes d'exploration
│   ├── 02_analyses_avancees.sql         ← Requêtes d'exploration
│   
│
├── 📁 data/
│   ├── raw/                             ← train.csv, stores.csv,
│   │                                       features.csv, test.csv
│   ├── processed/                       ← Données nettoyées & enrichies
│   └── star_schema/                     ← Tables du schéma étoile
│
├── 📤 outputs/
│   ├── figures/                         ← Graphiques exportés (.png)
│   └── tables/                          ← Agrégats Power BI (.csv)
│
└── 📋 reports/
    ├── Dashboard.pbi                  ← Dashboard Power BI
    
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
| Langage | Python 3.11 |
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
