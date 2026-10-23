#!/usr/bin/env bash
# ==============================================================================
# Script de inicio para Reloj Digital de Tiempo Decimal
# Puerto dedicado aislado: 5190 (Zero-Port-Collision Gate)
# Desacoplado de terminal POSIX con inmunidad SIGHUP
# ==============================================================================
set -euo pipefail

PORT=5190
HOST="127.0.0.1"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/tmp/reloj_decimal_server.log"

cd "$DIR"

# Verificar si ya está corriendo en el puerto
if lsof -i :$PORT >/dev/null 2>&1; then
    echo "⚡ El servidor ya se encuentra en ejecución en http://${HOST}:${PORT}"
else
    echo "🚀 Iniciando servidor HTTP local en http://${HOST}:${PORT}..."
    nohup python3 -m http.server "$PORT" --bind "$HOST" </dev/null >"$LOG_FILE" 2>&1 &
    sleep 0.5
fi

# Verificar respuesta HTTP 200
if curl -s -I "http://${HOST}:${PORT}/index.html" | grep -q "200 OK"; then
    echo "✅ Reloj Decimal verificado con éxito [HTTP 200 OK]."
    echo "🔗 URL local: http://${HOST}:${PORT}"
    echo "📁 Archivo directo: file://${DIR}/index.html"
else
    echo "⚠️ Advertencia: No se recibió HTTP 200 al verificar el socket local."
fi
