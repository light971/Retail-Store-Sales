import pandas as pd
import numpy as np
import os

RAW_PATH       = os.path.join('..', 'data', 'raw')
PROCESSED_PATH = os.path.join('..', 'data', 'processed')
STAR_PATH      = os.path.join('..', 'data', 'star_schema')


def load_raw_files() -> dict:
    """Charge les 4 fichiers CSV bruts."""
    files = {
        'train'   : 'train.csv',
        'stores'  : 'stores.csv',
        'features': 'features.csv',
        'test'    : 'test.csv',
    }
    dfs = {}
    for key, fname in files.items():
        path = os.path.join(RAW_PATH, fname)
        dfs[key] = pd.read_csv(path)
        print(f'  ✅ {fname:<20} {dfs[key].shape[0]:>10,} lignes × {dfs[key].shape[1]} colonnes')
    return dfs


def build_master(train, stores, features) -> pd.DataFrame:
    """
    Construit le dataset maître par jointures successives.
    Jointure 1 : train  LEFT JOIN stores   ON Store
    Jointure 2 : result LEFT JOIN features ON [Store, Date]
    """
    train['Date']    = pd.to_datetime(train['Date'])
    features['Date'] = pd.to_datetime(features['Date'])

    # Jointure 1
    df = train.merge(stores, on='Store', how='left')
    print(f'  ✅ train × stores    : {df.shape}')

    # Jointure 2 — supprime IsHoliday dupliqué
    features_clean = features.drop(columns=['IsHoliday'], errors='ignore')
    df = df.merge(features_clean, on=['Store', 'Date'], how='left')
    print(f'  ✅ × features        : {df.shape}')

    return df


def enrich(df: pd.DataFrame) -> pd.DataFrame:
    """Feature engineering métier."""
    df = df.copy()

    # Temporel
    df['Year']    = df['Date'].dt.year
    df['Month']   = df['Date'].dt.month
    df['Week']    = df['Date'].dt.isocalendar().week.astype(int)
    df['Quarter'] = df['Date'].dt.quarter
    df['Month_Name'] = df['Date'].dt.strftime('%B')

    # Catégorisation taille magasin
    df['Size_Category'] = pd.cut(
        df['Size'],
        bins=[0, 80_000, 150_000, 999_999],
        labels=['Small', 'Medium', 'Large']
    )

    # MarkDowns — COALESCE (NaN → 0), clip négatifs
    md_cols = ['MarkDown1','MarkDown2','MarkDown3','MarkDown4','MarkDown5']
    for col in md_cols:
        if col in df.columns:
            df[col] = df[col].fillna(0).clip(lower=0)
    df['Total_MarkDown'] = df[[c for c in md_cols if c in df.columns]].sum(axis=1)
    df['Has_MarkDown']   = (df['Total_MarkDown'] > 0).astype(int)

    # Labels
    df['Holiday_Label']      = np.where(df['IsHoliday'], 'Fériée', 'Normale')
    df['Weekly_Sales_Clean'] = df['Weekly_Sales'].clip(lower=0)

    return df


def build_star_schema(df: pd.DataFrame) -> dict:
    """Construit et exporte les 5 tables du schéma en étoile."""
    os.makedirs(STAR_PATH, exist_ok=True)

    fact = df[['Store','Dept','Date','Weekly_Sales','Weekly_Sales_Clean','IsHoliday']].copy()
    fact.rename(columns={'Store':'Store_ID','Dept':'Dept_ID'}, inplace=True)

    dim_date = (df[['Date','Year','Month','Month_Name','Week','Quarter','IsHoliday','Holiday_Label']]
                  .drop_duplicates('Date').sort_values('Date').reset_index(drop=True))

    dim_store = (df[['Store','Type','Size','Size_Category']]
                   .drop_duplicates('Store').sort_values('Store').reset_index(drop=True))
    dim_store.rename(columns={'Store':'Store_ID'}, inplace=True)
    dim_store['Store_Label'] = 'Store_' + dim_store['Store_ID'].astype(str).str.zfill(2)

    dim_dept = (df[['Dept']].drop_duplicates().sort_values('Dept').reset_index(drop=True))
    dim_dept.rename(columns={'Dept':'Dept_ID'}, inplace=True)
    dim_dept['Dept_Label'] = 'Dept_' + dim_dept['Dept_ID'].astype(str).str.zfill(2)

    md_cols = [c for c in ['Store','Date','MarkDown1','MarkDown2','MarkDown3',
                            'MarkDown4','MarkDown5','Total_MarkDown','Has_MarkDown'] if c in df.columns]
    dim_md = df[md_cols].drop_duplicates(['Store','Date']).copy()
    dim_md.rename(columns={'Store':'Store_ID'}, inplace=True)

    tables = {
        'FACT_SALES'  : fact,
        'DIM_DATE'    : dim_date,
        'DIM_STORE'   : dim_store,
        'DIM_DEPT'    : dim_dept,
        'DIM_MARKDOWN': dim_md,
    }

    for name, tbl in tables.items():
        path = os.path.join(STAR_PATH, f'{name}.csv')
        tbl.to_csv(path, index=False)
        print(f'  ✅ {name:<18} {tbl.shape[0]:>10,} lignes → {path}')

    return tables


def save_master(df: pd.DataFrame) -> None:
    os.makedirs(PROCESSED_PATH, exist_ok=True)
    path = os.path.join(PROCESSED_PATH, 'retail_master.csv')
    df.to_csv(path, index=False)
    print(f'  ✅ Dataset maître → {path}  ({df.shape[0]:,} lignes × {df.shape[1]} col.)')
