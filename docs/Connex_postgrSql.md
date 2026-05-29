# Connexion à la base de données PostgreSQL

# psql toolkit
import psycopg2
from sqlalchemy import create_engine

user = "postgres"  # ou ton utilisateur défini dans le docker-compose
password = "postgres"  # idem
host = "localhost"
port = "5432"
database = "manga_db"

# Création de l'engine SQLAlchemy
engine = create_engine(f"postgresql://{user}:{password}@{host}:{port}/{database}")
try:
    engine
    print("Connection Successed to PSQL")
except:
    print("Unable to connect")

# Sauvegarde du DataFrame dans la table "manga"
df_manga.to_sql(name="manga", con=engine, if_exists="replace", index=False)