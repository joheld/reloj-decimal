#!/usr/bin/env bash
# ==============================================================================
# Launcher para Escritorio - Reloj Digital de Tiempo Decimal
# Desacoplado de terminal POSIX con inmunidad SIGHUP
# ==============================================================================
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Si el servidor HTTP local no está corriendo en el puerto dedicado 5190, iniciarlo
if ! lsof -i :5190 >/dev/null 2>&1; then
    if [ -x "$DIR/start.sh" ]; then
        "$DIR/start.sh" >/dev/null 2>&1 || true
    fi
fi

# Abrir la aplicación web en el navegador predeterminado de macOS
open "$DIR/index.html"
