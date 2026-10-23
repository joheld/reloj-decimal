#!/usr/bin/env bash
# ==============================================================================
# Script de apagado para Reloj Digital de Tiempo Decimal
# ==============================================================================
set -euo pipefail

PORT=5190
PID=$(lsof -ti :$PORT || true)

if [ -n "$PID" ]; then
    echo "🛑 Deteniendo servidor de Reloj Decimal (PID: $PID)..."
    kill -15 "$PID" 2>/dev/null || kill -9 "$PID" 2>/dev/null
    echo "✅ Servidor detenido correctamente."
else
    echo "ℹ️ No hay ningún servidor corriendo en el puerto $PORT."
fi
