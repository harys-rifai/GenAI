#!/bin/bash

# Aktifkan virtual environment Python
source venv/bin/activate

# Jalankan Django server di background, log ke file
echo "Starting Django server..."
python3 manage.py runserver > django.log 2>&1 &

# Pindah ke folder Node.js gateway
cd node_gateway

# Jalankan Node.js gateway di background, log ke file
echo "Starting Node.js WhatsApp Gateway..."
node index.js > whatsapp_gateway.log 2>&1 &

# Kembali ke root project
cd ..

echo "✅ Django & Node.js Gateway are running"
echo "Django log: django.log"
echo "WhatsApp Gateway log: node_gateway/whatsapp_gateway.log"
