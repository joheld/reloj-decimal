# ⏱️ Reloj Decimal (French Revolutionary Decimal Time)

> Aplicación web autónoma y **Widget Nativo para macOS (Swift & AppKit)** que implementa el sistema de tiempo decimal decretado durante la Revolución Francesa (1793).

El día se divide exactamente en **10 horas decimales**, cada hora en **100 minutos decimales** y cada minuto en **100 segundos decimales**, sumando exactamente 100.000 unidades de tiempo por ciclo solar.

---

## 🌟 Características Principales

### 1. Aplicación Web Standalone (`index.html`)
- **100% Autónoma & Offline:** Código puro sin dependencias externas ni frameworks pesados.
- **Sincronización de Alta Precisión:** Bucle en tiempo real mediante `requestAnimationFrame` con protección contra imprecisiones de punto flotante (IEEE-754).
- **Panel Comparador 24 Horas:** Visualización simultánea del tiempo sexagesimal estándar frente al tiempo decimal.
- **Convertidor Interactivo Bidireccional:** Convierte instantáneamente cualquier hora tradicional a decimal y viceversa.
- **Síntesis de Audio Procedural:** Sonificación rítmica de los segundos decimales mediante la Web Audio API nativa.
- **Diseño Ergonómico:** Interfaz oscura (Slate Dark Mode) optimizada para bajo consumo y alta legibilidad.

### 2. Widget Nativo para macOS (`Reloj Decimal Widget.app`)
- **Escrito en Swift 6 & AppKit:** Binario universal compilado para Apple Silicon (ARM64) e Intel (x86_64).
- **Elemento de Barra de Menús (`NSStatusItem`):** Muestra el tiempo decimal en vivo con 4 modos conmutables:
  1. Horas, Minutos y Segundos (`4:74:20`)
  2. Horas y Minutos (`4:74`)
  3. Porcentaje del Día (`47.4%`)
  4. Detallado con Décimas (`4:74:20.3`)
- **Panel Flotante de Escritorio:** Panel translúcido (*Frosted Glass*) arrastrable que puede fijarse al fondo de pantalla (`.desktop`) o flotar sobre las ventanas (`.floating`).
- **Atajos Globales:** Copia rápida al portapapeles (<kbd>⌘C</kbd>) y apertura de la suite completa.

---

## 📐 Equivalencias Matemáticas Fundamentales

| Unidad Decimal | Valor Decimal | Equivalencia Tradicional (Sexagesimal) |
| :--- | :--- | :--- |
| **1 Día** | 10 horas decimales | 24 horas (86.400 segundos) |
| **1 Hora Decimal** | 100 minutos decimales | 2 horas y 24 minutos (144 minutos) |
| **1 Minuto Decimal** | 100 segundos decimales | 1 minuto y 26,4 segundos (86,4 segundos) |
| **1 Segundo Decimal** | 1 segundo decimal | 0,864 segundos estándar |

---

## 🚀 Instalación y Uso

### Ejecución Web Local
```bash
# Iniciar servidor local en el puerto 5190
./start.sh

# Detener el servidor
./stop.sh
```

### Compilación del Widget Nativo (macOS)
```bash
# Compilar y firmar ad-hoc el widget nativo
./build-widget.sh
```

---

## 📄 Licencia

Distribuido bajo la Licencia MIT. Consulta el archivo [LICENSE](LICENSE) para más detalles.
