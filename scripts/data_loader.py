"""
╔══════════════════════════════════════════════════════════════╗
║           data_loader.py — Chargement des données           ║
║  Fonctions utilitaires réutilisables entre vos notebooks    ║
╚══════════════════════════════════════════════════════════════╝
Utilisation dans un notebook :
    import sys
    sys.path.append('../scripts')
    from data_loader import load_csv, quick_info
"""

import pandas as pd
import numpy as np
import os


# ──────────────────────────────────────────────────────
#  CHARGEMENT
# ──────────────────────────────────────────────────────

def load_csv(filepath: str, **kwargs) -> pd.DataFrame:
    """
    Charge un fichier CSV avec gestion d'erreurs.
    
    Params:
        filepath (str)  : Chemin vers le fichier .csv
        **kwargs        : Arguments supplémentaires pour pd.read_csv
    
    Returns:
        pd.DataFrame
    """
    if not os.path.exists(filepath):
        raise FileNotFoundError(f"❌ Fichier introuvable : {filepath}")
    df = pd.read_csv(filepath, **kwargs)
    print(f"✅ '{os.path.basename(filepath)}' chargé — {df.shape[0]} lignes × {df.shape[1]} colonnes")
    return df


def load_excel(filepath: str, sheet_name=0, **kwargs) -> pd.DataFrame:
    """Charge un fichier Excel."""
    if not os.path.exists(filepath):
        raise FileNotFoundError(f"❌ Fichier introuvable : {filepath}")
    df = pd.read_excel(filepath, sheet_name=sheet_name, **kwargs)
    print(f"✅ '{os.path.basename(filepath)}' chargé — {df.shape[0]} lignes × {df.shape[1]} colonnes")
    return df


# ──────────────────────────────────────────────────────
#  DIAGNOSTIC RAPIDE
# ──────────────────────────────────────────────────────

def quick_info(df: pd.DataFrame) -> pd.DataFrame:
    """
    Affiche un rapport de qualité rapide du DataFrame.
    
    Returns:
        pd.DataFrame : tableau récapitulatif par colonne
    """
    report = pd.DataFrame({
        'type'       : df.dtypes,
        'non_null'   : df.notnull().sum(),
        'null'       : df.isnull().sum(),
        'null_%'     : (df.isnull().sum() / len(df) * 100).round(2),
        'uniques'    : df.nunique(),
        'uniques_%'  : (df.nunique() / len(df) * 100).round(2),
    })
    
    print(f"📐 Shape : {df.shape[0]} lignes × {df.shape[1]} colonnes")
    print(f"🔁 Doublons : {df.duplicated().sum()}")
    print(f"❓ Valeurs manquantes totales : {df.isnull().sum().sum()}")
    print()
    return report


def missing_summary(df: pd.DataFrame) -> pd.DataFrame:
    """Résumé des valeurs manquantes, trié par % décroissant."""
    missing = pd.DataFrame({
        'missing_count': df.isnull().sum(),
        'missing_pct'  : (df.isnull().sum() / len(df) * 100).round(2),
        'dtype'        : df.dtypes,
    }).sort_values('missing_pct', ascending=False)
    return missing[missing['missing_count'] > 0]


def outlier_summary(df: pd.DataFrame) -> pd.DataFrame:
    """Détecte les outliers via la méthode IQR pour les colonnes numériques."""
    num_cols = df.select_dtypes(include=np.number).columns
    rows = []
    for col in num_cols:
        Q1, Q3 = df[col].quantile(0.25), df[col].quantile(0.75)
        IQR = Q3 - Q1
        lb, ub = Q1 - 1.5 * IQR, Q3 + 1.5 * IQR
        n_out = ((df[col] < lb) | (df[col] > ub)).sum()
        rows.append({
            'colonne'     : col,
            'outliers'    : n_out,
            'outliers_%'  : round(n_out / len(df) * 100, 2),
            'borne_basse' : round(lb, 2),
            'borne_haute' : round(ub, 2),
        })
    return pd.DataFrame(rows).set_index('colonne').sort_values('outliers_%', ascending=False)


# ──────────────────────────────────────────────────────
#  NETTOYAGE
# ──────────────────────────────────────────────────────

def impute_missing(df: pd.DataFrame, strategy: str = 'median') -> pd.DataFrame:
    """
    Impute les valeurs manquantes.
    
    Params:
        df       : DataFrame à traiter
        strategy : 'median', 'mean', ou 'mode'
    
    Returns:
        pd.DataFrame nettoyé (copie)
    """
    df_clean = df.copy()
    
    for col in df_clean.select_dtypes(include=np.number).columns:
        if df_clean[col].isnull().any():
            if strategy == 'median':
                val = df_clean[col].median()
            elif strategy == 'mean':
                val = df_clean[col].mean()
            else:
                val = df_clean[col].mode()[0]
            df_clean[col].fillna(val, inplace=True)
            print(f"  ✅ {col} → imputé par {strategy} ({val:.2f})")
    
    for col in df_clean.select_dtypes(include='object').columns:
        if df_clean[col].isnull().any():
            val = df_clean[col].mode()[0]
            df_clean[col].fillna(val, inplace=True)
            print(f"  ✅ {col} → imputé par mode ('{val}')")
    
    return df_clean


# ──────────────────────────────────────────────────────
#  EXPORT
# ──────────────────────────────────────────────────────

def save_clean(df: pd.DataFrame, output_path: str) -> None:
    """Sauvegarde le DataFrame nettoyé en CSV."""
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    df.to_csv(output_path, index=False, encoding='utf-8')
    print(f"💾 Dataset exporté → {output_path}  ({df.shape[0]} lignes)")
