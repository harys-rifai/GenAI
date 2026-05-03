#!/bin/bash
# Auto generate README.md with repo notes

BRANCH="main"

echo "🔄 Generating README.md..."

# Buat header
echo "# Repository Notes" > README.md
echo "" >> README.md
echo "Generated on: $(date '+%Y-%m-%d %H:%M:%S')" >> README.md
echo "" >> README.md

# Tambahkan gambar UI dari folder imgs
if [ -d "imgs" ]; then
  echo "## 🖼️ UI Screenshots" >> README.md
  for img in imgs/*; do
    if [[ $img =~ \.(png|jpg|jpeg|gif|PNG|JPG|JPEG|GIF)$ ]]; then
      echo "### $(basename "$img")" >> README.md
      echo "<img src=\"$img\" width=\"600\" alt=\"$(basename "$img")\">" >> README.md
      echo "" >> README.md
    fi
  done
fi

# Tambahkan log commit terakhir
echo "## 📝 Recent Commits" >> README.md
git log -n 10 --pretty=format:"- %h %s (%cr)" >> README.md
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
