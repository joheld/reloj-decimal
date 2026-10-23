# Reloj Digital de Tiempo Decimal (Système Décimal Révolutionnaire) - Project Map

Aplicación web standalone en un único archivo (`index.html`), 100% autónoma, offline y sin dependencias externas, que implementa el sistema de tiempo decimal decretado durante la Revolución Francesa (1793): el día dividido en 10 horas decimales, cada hora en 100 minutos decimales y cada minuto en 100 segundos decimales (100.000 unidades/día).

---

## 📊 Grafo de Versiones

```mermaid
gitGraph
    commit id: "init-project-map" tag: "v0.1.0"
    commit id: "feat-decimal-clock-core" tag: "v1.0.0"
    commit id: "feat-desktop-shortcuts-and-icon" tag: "v1.1.0"
```

---

## 📌 Checkpoints

| ID | Fecha | Versión | Descripción | Estado |
|---|---|---|---|---|
| `CHK-001` | 2026-10-23 | `v0.1.0` | Inicialización del repositorio git y mapa del proyecto | ✅ Completado |
| `CHK-002` | 2026-10-23 | `v1.0.0` | Aplicación web standalone completa (`index.html`) con reloj en tiempo real (`requestAnimationFrame`), protección IEEE-754 contra imprecisiones de punto flotante, panel comparador 24h, porcentaje de día, convertidor interactivo bidireccional, síntesis de audio procedural Web Audio API, diseño Slate Dark Mode responsivo y scripts desacoplados POSIX `start.sh`/`stop.sh` en puerto asignado `5190` | ✅ Completado |
| `CHK-003` | 2026-10-23 | `v1.1.0` | Creación de lanzadores en el Escritorio: aplicación nativa compilada macOS `Reloj Decimal.app` con icono de esfera decimal de 10h personalizado (`.icns`), lanzador por terminal `Reloj Decimal.command` y script desacoplado `launch-desktop.sh` | ✅ Completado |

---

## 🚦 Estado de la Sesión
- **Estado Actual:** Accesos directos creados y verificados en el Escritorio de macOS (`~/Desktop`). Servidor y app standalone listos para su uso diario.
- **Siguiente paso:** Notificación al usuario con enlaces clicables según protocolo global.
