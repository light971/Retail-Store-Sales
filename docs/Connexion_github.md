# Aller dans le dossier du projet
cd /chemin/vers/manga_analysis

# Vérifier le statut
git status

# Initialiser Git
git init

# Ajouter tous les fichiers
git add .

# Premier commit
git commit -m "Initial commit: structure projet et notebook initial"

# Lier le repo distant
git remote add origin https://github.com/<ton_username>/manga_analysis.git

# Renommer la branche principale
git branch -M main

# Récupère les changements distants
git pull origin main --rebase

# Terminer le rebase
git rebase --continue

# Pousser sur GitHub
git push -u origin main

# Token
[GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)](https://github.com/settings/tokens)
