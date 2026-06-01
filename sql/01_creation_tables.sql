-- ============================================================
-- RETAIL STORE SALES — Schéma en étoile SQLite
-- ============================================================

-- ── TABLE DE FAITS ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS FACT_SALES (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    Store_ID            INTEGER NOT NULL,
    Dept_ID             INTEGER NOT NULL,
    Date                TEXT    NOT NULL,
    Weekly_Sales        REAL,
    Weekly_Sales_Clean  REAL,
    IsHoliday           INTEGER,

    FOREIGN KEY (Store_ID) REFERENCES DIM_STORE(Store_ID),
    FOREIGN KEY (Dept_ID)  REFERENCES DIM_DEPT(Dept_ID),
    FOREIGN KEY (Date)     REFERENCES DIM_DATE(Date)
);

-- ── DIMENSION DATE ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS DIM_DATE (
    Date          TEXT PRIMARY KEY,
    Year          INTEGER,
    Month         INTEGER,
    Month_Name    TEXT,
    Week          INTEGER,
    Quarter       INTEGER,
    IsHoliday     INTEGER,
    Holiday_Label TEXT
);

-- ── DIMENSION MAGASIN ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS DIM_STORE (
    Store_ID      INTEGER PRIMARY KEY,
    Store_Label   TEXT,
    Type          TEXT,
    Size          INTEGER,
    Size_Category TEXT
);

-- ── DIMENSION DÉPARTEMENT ───────────────────────────────────
CREATE TABLE IF NOT EXISTS DIM_DEPT (
    Dept_ID    INTEGER PRIMARY KEY,
    Dept_Label TEXT
);

-- ── DIMENSION MARKDOWN ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS DIM_MARKDOWN (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    Store_ID      INTEGER,
    Date          TEXT,
    MarkDown1     REAL,
    MarkDown2     REAL,
    MarkDown3     REAL,
    MarkDown4     REAL,
    MarkDown5     REAL,
    Total_MarkDown REAL,
    Has_MarkDown  INTEGER,

    FOREIGN KEY (Store_ID) REFERENCES DIM_STORE(Store_ID),
    FOREIGN KEY (Date)     REFERENCES DIM_DATE(Date)
);

-- ── INDEX POUR PERFORMANCE ──────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_fact_store ON FACT_SALES(Store_ID);
CREATE INDEX IF NOT EXISTS idx_fact_dept  ON FACT_SALES(Dept_ID);
CREATE INDEX IF NOT EXISTS idx_fact_date  ON FACT_SALES(Date);
CREATE INDEX IF NOT EXISTS idx_md_store   ON DIM_MARKDOWN(Store_ID);
