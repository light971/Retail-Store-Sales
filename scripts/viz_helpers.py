"""
╔══════════════════════════════════════════════════════════════╗
║         viz_helpers.py — Fonctions de visualisation         ║
║  Graphiques prêts à l'emploi et réutilisables              ║
╚══════════════════════════════════════════════════════════════╝
Utilisation dans un notebook :
    import sys
    sys.path.append('../scripts')
    from viz_helpers import plot_distributions, plot_correlation
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
import seaborn as sns
import os

# Style par défaut
sns.set_theme(style='whitegrid', palette='muted', font_scale=1.1)
FIGDIR = '../outputs/figures/'


def _save(fig, filename: str):
    """Sauvegarde une figure si un nom de fichier est fourni."""
    if filename:
        os.makedirs(FIGDIR, exist_ok=True)
        fig.savefig(FIGDIR + filename, bbox_inches='tight', dpi=150)
        print(f"💾 Sauvegardé → {FIGDIR + filename}")


# ──────────────────────────────────────────────────────
#  UNIVARIÉ
# ──────────────────────────────────────────────────────

def plot_distributions(df: pd.DataFrame, cols: list = None,
                       n_cols: int = 2, save_as: str = 'distributions.png') -> None:
    """
    Histogrammes + KDE pour toutes les variables numériques.
    
    Params:
        df      : DataFrame source
        cols    : Liste de colonnes (None = toutes les numériques)
        n_cols  : Nombre de colonnes dans la grille
        save_as : Nom du fichier de sortie (None = pas de sauvegarde)
    """
    cols = cols or df.select_dtypes(include=np.number).columns.tolist()
    n_rows = (len(cols) + n_cols - 1) // n_cols
    fig, axes = plt.subplots(n_rows, n_cols, figsize=(7 * n_cols, 4 * n_rows))
    axes = axes.flatten() if n_rows * n_cols > 1 else [axes]

    for i, col in enumerate(cols):
        ax = axes[i]
        sns.histplot(df[col].dropna(), kde=True, ax=ax, color='steelblue', bins=30)
        ax.axvline(df[col].mean(),   color='red',    linestyle='--', lw=1.5,
                   label=f'Moy: {df[col].mean():.1f}')
        ax.axvline(df[col].median(), color='orange', linestyle='-',  lw=1.5,
                   label=f'Med: {df[col].median():.1f}')
        ax.set_title(col, fontsize=12)
        ax.legend(fontsize=8)

    for j in range(i + 1, len(axes)):
        axes[j].set_visible(False)

    fig.suptitle('📈 Distributions des variables numériques',
                 fontsize=14, fontweight='bold', y=1.01)
    plt.tight_layout()
    _save(fig, save_as)
    plt.show()


def plot_countplots(df: pd.DataFrame, cols: list = None,
                    save_as: str = 'countplots.png') -> None:
    """Diagrammes en barres pour variables catégorielles avec annotation %."""
    cols = cols or df.select_dtypes(include='object').columns.tolist()
    if not cols:
        print("ℹ️  Aucune variable catégorielle.")
        return

    fig, axes = plt.subplots(1, len(cols), figsize=(6 * len(cols), 5))
    axes = axes if len(cols) > 1 else [axes]

    for ax, col in zip(axes, cols):
        order = df[col].value_counts().index
        sns.countplot(data=df, x=col, order=order, palette='Blues_d', ax=ax)
        ax.set_title(col, fontsize=12)
        total = len(df)
        for p in ax.patches:
            ax.annotate(f'{100 * p.get_height() / total:.1f}%',
                        (p.get_x() + p.get_width() / 2, p.get_height()),
                        ha='center', va='bottom', fontsize=10)

    fig.suptitle('🏷️ Distribution des variables catégorielles',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    _save(fig, save_as)
    plt.show()


# ──────────────────────────────────────────────────────
#  BIVARIÉ / MULTIVARIÉ
# ──────────────────────────────────────────────────────

def plot_correlation(df: pd.DataFrame, method: str = 'pearson',
                     save_as: str = 'correlation.png') -> pd.DataFrame:
    """
    Heatmap de la matrice de corrélation (triangle inférieur uniquement).
    
    Returns:
        pd.DataFrame : matrice de corrélation
    """
    num_cols = df.select_dtypes(include=np.number).columns
    corr = df[num_cols].corr(method=method)
    mask = np.triu(np.ones_like(corr, dtype=bool))

    fig, ax = plt.subplots(figsize=(8, 6))
    sns.heatmap(corr, mask=mask, annot=True, fmt='.2f',
                cmap='RdBu_r', center=0, vmin=-1, vmax=1,
                square=True, linewidths=0.5, ax=ax)
    ax.set_title(f'🔗 Matrice de corrélation ({method})',
                 fontsize=13, fontweight='bold')
    plt.tight_layout()
    _save(fig, save_as)
    plt.show()
    return corr


def plot_boxplots_by_cat(df: pd.DataFrame, cat_col: str,
                          num_cols: list = None, save_as: str = 'boxplots.png') -> None:
    """Boxplots de variables numériques groupées par une variable catégorielle."""
    num_cols = num_cols or df.select_dtypes(include=np.number).columns.tolist()[:3]
    fig, axes = plt.subplots(1, len(num_cols), figsize=(6 * len(num_cols), 5))
    axes = axes if len(num_cols) > 1 else [axes]

    for ax, col in zip(axes, num_cols):
        sns.boxplot(data=df, x=cat_col, y=col, palette='Set2', ax=ax)
        ax.set_title(f'{col} par {cat_col}', fontsize=11)

    fig.suptitle(f'📦 Distribution par « {cat_col} »',
                 fontsize=13, fontweight='bold', y=1.02)
    plt.tight_layout()
    _save(fig, save_as)
    plt.show()


def plot_target_analysis(df: pd.DataFrame, target: str,
                          cat_col: str = None, save_as: str = 'target.png') -> None:
    """Analyse de la variable cible binaire + taux par catégorie."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 4))

    # Distribution brute
    df[target].value_counts().plot.bar(ax=axes[0],
                                        color=['steelblue', 'coral'],
                                        edgecolor='white', rot=0)
    axes[0].set_title(f'Distribution de « {target} »')
    axes[0].set_ylabel('Nombre')

    # Taux par catégorie
    if cat_col and cat_col in df.columns:
        taux = df.groupby(cat_col)[target].mean().sort_values(ascending=False)
        taux.plot.bar(ax=axes[1], color='steelblue', edgecolor='white', rot=30)
        axes[1].set_title(f'Taux « {target}=1 » par {cat_col}')
        axes[1].yaxis.set_major_formatter(mticker.PercentFormatter(1.0))
    else:
        axes[1].set_visible(False)

    fig.suptitle(f'🎯 Variable cible : « {target} »',
                 fontsize=13, fontweight='bold', y=1.02)
    plt.tight_layout()
    _save(fig, save_as)
    plt.show()
