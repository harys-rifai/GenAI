#!/bin/bash
# Auto generate README.md with repo notes

BRANCH="main"

echo "🔄 Generating README.md..."

# Buat header
echo "# Repository Notes" > README.md
echo "" >> README.md
echo "Generated on: $(date '+%Y-%m-%d %H:%M:%S')" >> README.md
echo "" >> README.md

# Tambahkan tree struktur repo
echo "## 📂 Project Structure" >> README.md
echo '```' >> README.md
tree -a -I '.git|venv|__pycache__' >> README.md
echo '```' >> README.md
echo "" >> README.md

# Tambahkan daftar file
echo "## 📄 Files in Repo" >> README.md
git ls-files >> README.md
echo "" >> README.md

# Tambahkan log commit terakhir
echo "## 📝 Recent Commits" >> README.md
git log -n 5 --pretty=format:"- %h %s (%cr)" >> README.md
echo "" >> README.md

# Stage semua perubahan
git add .

# Commit dengan timestamp
git commit -m "Auto-update README on $(date '+%Y-%m-%d %H:%M:%S')" || echo "ℹ️ No changes to commit"

# Pull dulu biar sinkron dengan remote
git pull --rebase origin $BRANCH || { echo "❌ Pull failed, resolve conflicts manually"; exit 1; }

# Push ke remote
git push origin $BRANCH

echo "✅ README.md updated, synced, and pushed!"
