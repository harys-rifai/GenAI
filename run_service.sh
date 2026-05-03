#!/bin/bash

SERVICE_FILE="service.pid"

stop_all_services() {
  echo "🛑 Killing all Django & Node.js processes..."
  pkill -f "manage.py runserver" || true
  pkill -f "node index.js" || true
  rm -f $SERVICE_FILE
  echo "✅ Semua service lama dimatikan"
}

start_services() {
  # Load environment variables dari .env kalau ada
  if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
    echo "🌍 Environment variables loaded from .env"
  fi

  # Aktifkan virtual environment Python
  if [ -d "venv" ]; then
    source venv/bin/activate
  else
    echo "❌ Virtual environment tidak ditemukan. Jalankan: python3 -m venv venv"
    exit 1
  fi

  echo "🚀 Starting Django server..."
  nohup python3 manage.py runserver 0.0.0.0:8000 --noreload > django.log 2>&1 &
  DJANGO_PID=$!

  cd node_gateway || { echo "❌ Folder node_gateway tidak ditemukan"; exit 1; }

  echo "📡 Starting Node.js WhatsApp Gateway..."
  nohup node index.js > whatsapp_gateway.log 2>&1 &
  NODE_PID=$!

  cd ..

  echo "$DJANGO_PID $NODE_PID" > $SERVICE_FILE

  echo "✅ Services started"
  echo "   Django log: django.log (PID: $DJANGO_PID)"
  echo "   WhatsApp Gateway log: node_gateway/whatsapp_gateway.log (PID: $NODE_PID)"
}

# --- Main logic ---
stop_all_services
start_services
