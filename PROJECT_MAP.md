# Reloj Digital de Tiempo Decimal (Système Décimal Révolutionnaire) - Project Map

Aplicación web standalone en un único archivo (`index.html`), 100% autónoma, offline y sin dependencias externas, que implementa el sistema de tiempo decimal decretado durante la Revolución Francesa (1793): el día dividido en 10 horas decimales, cada hora en 100 minutos decimales y cada minuto en 100 segundos decimales (100.000 unidades/día).

---

## 📊 Grafo de Versiones

```mermaid
gitGraph
    commit id: "init-project-map" tag: "v0.1.0"
    commit id: "feat-decimal-clock-core" tag: "v1.0.0"
```

---

## 📌 Checkpoints

| ID | Fecha | Versión | Descripción | Estado |
|---|---|---|---|---|
| `CHK-001` | 2026-10-23 | `v0.1.0` | Inicialización del repositorio git y mapa del proyecto | ✅ Completado |
| `CHK-002` | 2026-10-23 | `v1.0.0` | Aplicación web standalone completa (`index.html`) con reloj en tiempo real (`requestAnimationFrame`), panel comparador 24h, porcentaje de día, convertidor interactivo bidireccional, síntesis de audio Web Audio API y diseño Slate Dark Mode responsivo | 🟡 En progreso |

---

## 🚦 Estado de la Sesión
- **En progreso:** Desarrollo de la aplicación en `/Users/joe/Developer/reloj-tiempo-decimal/index.html`.
- **Siguiente paso:** Pruebas funcionales de precisión matemática, responsividad y validación Zero-Defect.
