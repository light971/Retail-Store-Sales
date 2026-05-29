# 📊 Projet Data Analysis — Template EDA

> Template professionnel pour l'analyse exploratoire des données (EDA)  
> Conçu pour les data analysts débutants et intermédiaires

---

## 🗂️ Structure du projet

```
eda_project/
│
├── 📓 notebooks/
│   └── 01_eda_template.ipynb    ← Notebook EDA principal (commence ici !)
│
├── 🐍 scripts/
│   ├── data_loader.py           ← Fonctions de chargement & nettoyage
│   └── viz_helpers.py           ← Fonctions de visualisation réutilisables
│
├── 🗄️ sql/
│   └── 01_exploration.sql       ← Requêtes SQL pour explorer les données
│
├── 📁 data/
│   ├── raw/                     ← ⚠️ Données BRUTES originales (ne jamais modifier)
│   ├── processed/               ← Données nettoyées (générées par les notebooks)
│   └── external/                ← Données externes (référentiels, enrichissements)
│
├── 📤 outputs/
│   ├── figures/                 ← Graphiques exportés (.png)
│   └── tables/                  ← Tableaux exportés (.csv)
│
└── 📋 reports/                  ← Rapports finaux (.pdf, .pptx, .md)
```

---

## 🚀 Démarrage rapide

### 1. Installer les dépendances

```bash
pip install pandas numpy matplotlib seaborn jupyter
```

### 2. Lancer Jupyter

```bash
jupyter notebook
# ou
jupyter lab
```

### 3. Ouvrir le notebook EDA

Ouvre `notebooks/01_eda_template.ipynb` et remplace le dataset de démonstration par le tien.

---

## 📋 Contenu du notebook EDA

| # | Étape | Description |
|---|-------|-------------|
| 1 | ⚙️ Configuration | Imports, paramètres globaux, chemins |
| 2 | 📥 Chargement | Lecture du fichier (CSV, Excel, SQL...) |
| 3 | 🔍 Aperçu rapide | Shape, types, head(), describe() |
| 4 | 🧹 Qualité | Valeurs manquantes, doublons, outliers |
| 5 | 📈 Univarié | Distribution de chaque variable |
| 6 | 🔗 Bivarié | Relations entre variables |
| 7 | 💡 Synthèse | Conclusions & prochaines étapes |

---

## 🧰 Scripts réutilisables

### `data_loader.py`

```python
from scripts.data_loader import load_csv, quick_info, impute_missing

df = load_csv('data/raw/mon_fichier.csv')
quick_info(df)                          # Diagnostic rapide
df_clean = impute_missing(df, 'median') # Nettoyage auto
```

### `viz_helpers.py`

```python
from scripts.viz_helpers import plot_distributions, plot_correlation

plot_distributions(df_clean)             # Histogrammes toutes variables
plot_correlation(df_clean)               # Heatmap de corrélation
plot_boxplots_by_cat(df, 'departement') # Boxplots par groupe
```

---

## 📏 Conventions & bonnes pratiques

| Règle | Explication |
|-------|-------------|
| `df` = données brutes | On ne touche jamais aux données originales |
| `df_clean` = données nettoyées | Toujours travailler sur une copie |
| `data/raw/` en lecture seule | Jamais de modification directe |
| Nommer les notebooks avec un numéro | `01_eda.ipynb`, `02_features.ipynb`... |
| Un notebook = une étape | Séparation claire des responsabilités |
| Sauvegarder les figures | Toujours exporter dans `outputs/figures/` |

---

## 📚 Ressources pour aller plus loin

- 🐼 [Documentation pandas](https://pandas.pydata.org/docs/)
- 📊 [Galerie seaborn](https://seaborn.pydata.org/examples/index.html)
- 🎓 [Kaggle Learn — Pandas](https://www.kaggle.com/learn/pandas)
- 📖 [Towards Data Science](https://towardsdatascience.com/)

---

*Template créé pour accompagner les débutants en data analysis.*
