#!/bin/bash

# ====== Update & Install Python 3.11 via Homebrew ======
echo "🔹 Update Homebrew..."
brew update

echo "🔹 Install/Upgrade Python 3.11..."
brew install python@3.11 || brew upgrade python@3.11

# ====== Buat Virtual Environment ======
echo "🔹 Membuat virtualenv dengan Python 3.11..."
rm -rf venv
python3.11 -m venv venv
source venv/bin/activate

# ====== Upgrade pip ======
echo "🔹 Upgrade pip..."
python3 -m pip install --upgrade pip

# ====== Buat requirements.txt ======
echo "🔹 Membuat requirements.txt..."
cat <<EOF > requirements.txt
django==5.0.4
psycopg2-binary==2.9.9
djangorestframework==3.15.1
requests==2.32.5
langchain==0.3.28
langchain-core==0.3.84
langchain-community==0.3.31
langchain-openai==0.3.35
openai==1.109.1
tiktoken==0.12.0
EOF

# ====== Install semua dependency ======
echo "🔹 Install dependencies..."
python3 -m pip install -r requirements.txt

# ====== Verifikasi ======
echo "🔹 Versi Python:"
python3 --version
echo "🔹 Versi pip:"
pip --version
echo "🔹 Paket terinstall:"
python3 -m pip list
