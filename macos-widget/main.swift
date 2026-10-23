// ==============================================================================
// Reloj Digital de Tiempo Decimal - Native macOS Menu Bar & Desktop Widget
// Sistema Republicano Francés de 1793 (10 horas / día)
// 100% Nativo en Swift & AppKit • Apple Silicon ARM64 • Zero Dependencias
// ==============================================================================

import Cocoa

// MARK: - Modelo Matemático de Tiempo Decimal
struct DecimalTime {
    let hours: Int
    let minutes: Int
    let seconds: Int
    let centiseconds: Int
    let percentage: Double
    let standardTime: String
    let standardDate: String
    let totalDecimalSeconds: Double
    
    static func now() -> DecimalTime {
        let date = Date()
        let calendar = Calendar.current
        let midnight = calendar.startOfDay(for: date)
        let elapsed = max(0, date.timeIntervalSince(midnight))
        
        // Segundos transcurridos en el día estándar (0 a 86400)
        let elapsedStandardSeconds = elapsed
        let rawDecimal = (elapsedStandardSeconds.truncatingRemainder(dividingBy: 86400) * 100000) / 86400
        
        // Redondeo de salvaguarda IEEE-754
        let cleanTotal = (rawDecimal * 1e8).rounded() / 1e8
        
        let h = Int(cleanTotal / 10000)
        let m = Int(cleanTotal.truncatingRemainder(dividingBy: 10000) / 100)
        let s = Int(cleanTotal.truncatingRemainder(dividingBy: 100))
        let c = Int(cleanTotal.truncatingRemainder(dividingBy: 1) * 100)
        let pct = cleanTotal / 1000.0
        
        let df = DateFormatter()
        df.dateFormat = "HH:mm:ss"
        let stdStr = df.string(from: date)
        
        df.locale = Locale(identifier: "es_ES")
        df.dateFormat = "EEEE, d 'de' MMMM"
        let dateStr = df.string(from: date).capitalized
        
        return DecimalTime(
            hours: h,
            minutes: m,
            seconds: s,
            centiseconds: c,
            percentage: pct,
            standardTime: stdStr,
            standardDate: dateStr,
            totalDecimalSeconds: cleanTotal
        )
    }
    
    func formatted(showCentis: Bool = false) -> String {
        let secStr = String(format: "%02d", seconds)
        let minStr = String(format: "%02d", minutes)
        if showCentis {
            let centiStr = String(format: "%02d", centiseconds)
            return "\(hours):\(minStr):\(secStr).\(centiStr)"
        }
        return "\(hours):\(minStr):\(secStr)"
    }
}

// MARK: - Barra de Progreso Vectorial Personalizada
class ProgressBarView: NSView {
    var progress: CGFloat = 0.0 {
        didSet { needsDisplay = true }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        
        let trackRect = bounds.insetBy(dx: 1, dy: 1)
        let cornerRadius = trackRect.height / 2.0
        
        // Pista de fondo
        let trackPath = CGPath(roundedRect: trackRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
        ctx.addPath(trackPath)
        ctx.setFillColor(NSColor(calibratedWhite: 0.16, alpha: 0.75).cgColor)
        ctx.fillPath()
        
        // Borde sutil
        ctx.addPath(trackPath)
        ctx.setStrokeColor(NSColor(calibratedWhite: 0.4, alpha: 0.35).cgColor)
        ctx.setLineWidth(1)
        ctx.strokePath()
        
        // Relleno degradado
        let fillWidth = max(trackRect.height, trackRect.width * min(1.0, max(0.0, progress)))
        let fillRect = CGRect(x: trackRect.origin.x, y: trackRect.origin.y, width: fillWidth, height: trackRect.height)
        let fillPath = CGPath(roundedRect: fillRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
        
        ctx.saveGState()
        ctx.addPath(fillPath)
        ctx.clip()
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = [
            NSColor(calibratedRed: 0.01, green: 0.52, blue: 0.78, alpha: 1.0).cgColor,
            NSColor(calibratedRed: 0.22, green: 0.74, blue: 0.97, alpha: 1.0).cgColor,
            NSColor(calibratedRed: 0.96, green: 0.62, blue: 0.04, alpha: 1.0).cgColor
        ] as CFArray
        let locations: [CGFloat] = [0.0, 0.7, 1.0]
        if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) {
            ctx.drawLinearGradient(gradient, start: CGPoint(x: trackRect.minX, y: trackRect.midY), end: CGPoint(x: trackRect.maxX, y: trackRect.midY), options: [])
        }
        ctx.restoreGState()
    }
}

// MARK: - Vista de Tarjeta de Reloj Decimal (Compartida entre Popover y Desktop Widget)
class ClockCardView: NSView {
    let lblTitle = NSTextField(labelWithString: "TEMPS DÉCIMAL")
    let badgeEra = NSTextField(labelWithString: "1793 • AÑO II")
    let lblDigits = NSTextField(labelWithString: "0 : 00 : 00")
    let lblCentis = NSTextField(labelWithString: ".00")
    let lblUnits = NSTextField(labelWithString: "HORAS (0-9)  •  MINUTOS (00-99)  •  SEGUNDOS (00-99)")
    
    let progressBar = ProgressBarView()
    let lblProgressPct = NSTextField(labelWithString: "00.00 % DEL DÍA")
    
    let lblStandardTime = NSTextField(labelWithString: "Hora Estándar: 00:00:00")
    let lblDate = NSTextField(labelWithString: "Cargando fecha...")
    
    var onToggleDesktopWidget: (() -> Void)?
    var onOpenWeb: (() -> Void)?
    var onCopyTime: (() -> Void)?
    
    let btnDesktop = NSButton(title: "📌 Fijar en Escritorio", target: nil, action: nil)
    let btnCopy = NSButton(title: "📋 Copiar", target: nil, action: nil)
    let btnWeb = NSButton(title: "🌐 Web", target: nil, action: nil)
    
    init(frame: NSRect, isDesktopWidget: Bool = false) {
        super.init(frame: frame)
        setupViews(isDesktopWidget: isDesktopWidget)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews(isDesktopWidget: Bool) {
        wantsLayer = true
        
        // Encabezado
        lblTitle.font = NSFont.systemFont(ofSize: 11, weight: .bold)
        lblTitle.textColor = NSColor(calibratedRed: 0.22, green: 0.74, blue: 0.97, alpha: 1.0)
        addSubview(lblTitle)
        
        badgeEra.font = NSFont.systemFont(ofSize: 9, weight: .bold)
        badgeEra.textColor = NSColor(calibratedRed: 0.96, green: 0.62, blue: 0.04, alpha: 1.0)
        badgeEra.alignment = .right
        addSubview(badgeEra)
        
        // Dígitos Gigantes Tabulares
        lblDigits.font = NSFont.monospacedDigitSystemFont(ofSize: isDesktopWidget ? 34 : 38, weight: .bold)
        lblDigits.textColor = .white
        lblDigits.alignment = .center
        addSubview(lblDigits)
        
        lblCentis.font = NSFont.monospacedDigitSystemFont(ofSize: isDesktopWidget ? 18 : 20, weight: .semibold)
        lblCentis.textColor = NSColor(calibratedRed: 0.96, green: 0.62, blue: 0.04, alpha: 0.9)
        addSubview(lblCentis)
        
        // Etiquetas de unidades
        lblUnits.font = NSFont.systemFont(ofSize: 9, weight: .medium)
        lblUnits.textColor = NSColor(calibratedWhite: 0.6, alpha: 1.0)
        lblUnits.alignment = .center
        addSubview(lblUnits)
        
        // Barra de progreso y porcentaje
        addSubview(progressBar)
        
        lblProgressPct.font = NSFont.monospacedDigitSystemFont(ofSize: 10, weight: .bold)
        lblProgressPct.textColor = NSColor(calibratedRed: 0.22, green: 0.74, blue: 0.97, alpha: 1.0)
        lblProgressPct.alignment = .right
        addSubview(lblProgressPct)
        
        // Comparación con hora estándar
        lblStandardTime.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .semibold)
        lblStandardTime.textColor = NSColor(calibratedWhite: 0.9, alpha: 1.0)
        addSubview(lblStandardTime)
        
        lblDate.font = NSFont.systemFont(ofSize: 10, weight: .regular)
        lblDate.textColor = NSColor(calibratedWhite: 0.65, alpha: 1.0)
        addSubview(lblDate)
        
        // Botones de acción solo si es el popover
        if !isDesktopWidget {
            btnDesktop.bezelStyle = .rounded
            btnDesktop.target = self
            btnDesktop.action = #selector(handleDesktopClick)
            addSubview(btnDesktop)
            
            btnCopy.bezelStyle = .rounded
            btnCopy.target = self
            btnCopy.action = #selector(handleCopyClick)
            addSubview(btnCopy)
            
            btnWeb.bezelStyle = .rounded
            btnWeb.target = self
            btnWeb.action = #selector(handleWebClick)
            addSubview(btnWeb)
        }
    }
    
    @objc private func handleDesktopClick() { onToggleDesktopWidget?() }
    @objc private func handleCopyClick() { onCopyTime?() }
    @objc private func handleWebClick() { onOpenWeb?() }
    
    override func layout() {
        super.layout()
        let w = bounds.width
        let isDesk = btnDesktop.superview == nil
        
        if isDesk {
            // Diseño para el Desktop Widget (compacto y elegante)
            lblTitle.frame = NSRect(x: 18, y: bounds.height - 30, width: 140, height: 16)
            badgeEra.frame = NSRect(x: w - 150, y: bounds.height - 30, width: 132, height: 16)
            
            lblDigits.frame = NSRect(x: 14, y: bounds.height - 76, width: w - 74, height: 42)
            lblCentis.frame = NSRect(x: w - 62, y: bounds.height - 66, width: 48, height: 26)
            
            lblUnits.frame = NSRect(x: 18, y: bounds.height - 94, width: w - 36, height: 14)
            
            progressBar.frame = NSRect(x: 18, y: bounds.height - 114, width: w - 36, height: 8)
            lblProgressPct.frame = NSRect(x: w - 140, y: bounds.height - 132, width: 122, height: 14)
            
            lblStandardTime.frame = NSRect(x: 18, y: bounds.height - 154, width: w - 36, height: 16)
            lblDate.frame = NSRect(x: 18, y: bounds.height - 172, width: w - 36, height: 14)
        } else {
            // Diseño para el Popover
            lblTitle.frame = NSRect(x: 20, y: bounds.height - 32, width: 140, height: 18)
            badgeEra.frame = NSRect(x: w - 160, y: bounds.height - 32, width: 140, height: 18)
            
            lblDigits.frame = NSRect(x: 10, y: bounds.height - 82, width: w - 75, height: 46)
            lblCentis.frame = NSRect(x: w - 66, y: bounds.height - 72, width: 50, height: 28)
            
            lblUnits.frame = NSRect(x: 16, y: bounds.height - 104, width: w - 32, height: 14)
            
            progressBar.frame = NSRect(x: 20, y: bounds.height - 126, width: w - 40, height: 9)
            lblProgressPct.frame = NSRect(x: w - 150, y: bounds.height - 146, width: 130, height: 15)
            
            lblStandardTime.frame = NSRect(x: 20, y: bounds.height - 170, width: w - 40, height: 18)
            lblDate.frame = NSRect(x: 20, y: bounds.height - 190, width: w - 40, height: 15)
            
            let btnY: CGFloat = 16
            let btnW = (w - 48) / 3.0
            btnDesktop.frame = NSRect(x: 18, y: btnY, width: btnW, height: 28)
            btnCopy.frame = NSRect(x: 22 + btnW, y: btnY, width: btnW, height: 28)
            btnWeb.frame = NSRect(x: 26 + btnW * 2, y: btnY, width: btnW, height: 28)
        }
    }
    
    func update(with dec: DecimalTime) {
        lblDigits.stringValue = "\(dec.hours) : " + String(format: "%02d", dec.minutes) + " : " + String(format: "%02d", dec.seconds)
        lblCentis.stringValue = "." + String(format: "%02d", dec.centiseconds)
        
        progressBar.progress = CGFloat(dec.percentage / 100.0)
        lblProgressPct.stringValue = String(format: "%.2f %% DEL DÍA", dec.percentage)
        
        lblStandardTime.stringValue = "Hora Estándar: \(dec.standardTime)  (24h)"
        lblDate.stringValue = dec.standardDate
    }
}

// MARK: - Extensiones
extension NSWindow.Level {
    static let desktop = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)))
}

// MARK: - Panel de Widget de Escritorio Flotante / Anclado
class DesktopWidgetPanel: NSPanel {
    let cardView: ClockCardView
    let visualEffect = NSVisualEffectView()
    
    init() {
        let defaultRect = NSRect(x: 120, y: 140, width: 330, height: 186)
        cardView = ClockCardView(frame: NSRect(origin: .zero, size: defaultRect.size), isDesktopWidget: true)
        
        super.init(
            contentRect: defaultRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        isFloatingPanel = true
        level = .floating // Por defecto flotante; configurable a .desktop
        collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        isMovableByWindowBackground = true
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        
        // Efecto Translúcido macOS (Frosted Glass)
        visualEffect.material = .underWindowBackground
        visualEffect.blendingMode = .behindWindow
        visualEffect.state = .active
        visualEffect.wantsLayer = true
        visualEffect.layer?.cornerRadius = 20.0
        visualEffect.layer?.masksToBounds = true
        visualEffect.layer?.borderColor = NSColor(calibratedRed: 0.22, green: 0.74, blue: 0.97, alpha: 0.35).cgColor
        visualEffect.layer?.borderWidth = 1.0
        
        contentView = visualEffect
        visualEffect.addSubview(cardView)
        
        // Restaurar posición previa guardada
        if let originStr = UserDefaults.standard.string(forKey: "DesktopWidgetOrigin") {
            let point = NSPointFromString(originStr)
            setFrameOrigin(point)
        }
    }
    
    func savePosition() {
        let pointStr = NSStringFromPoint(frame.origin)
        UserDefaults.standard.set(pointStr, forKey: "DesktopWidgetOrigin")
    }
    
    func update(with dec: DecimalTime) {
        cardView.update(with: dec)
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        savePosition()
    }
}

// MARK: - App Delegate Principal
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var clockCardView: ClockCardView!
    var desktopWidget: DesktopWidgetPanel?
    var timer: Timer?
    
    // Preferencias de formato
    enum MenuBarFormat: Int {
        case hms = 0       // 4:74:20
        case hm = 1        // 4:74
        case pct = 2       // 47.4%
        case detailed = 3  // 4:74:20.3
    }
    var currentFormat: MenuBarFormat = .hms
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Inicializar Item en la Barra de Menús
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let btn = statusItem.button {
            btn.title = "0:00:00"
            btn.font = NSFont.monospacedDigitSystemFont(ofSize: 13, weight: .medium)
            btn.target = self
            btn.action = #selector(handleStatusItemClick(_:))
            btn.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        // Inicializar Popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 236)
        popover.behavior = .transient
        
        clockCardView = ClockCardView(frame: NSRect(x: 0, y: 0, width: 320, height: 236), isDesktopWidget: false)
        let vc = NSViewController()
        vc.view = clockCardView
        popover.contentViewController = vc
        
        // Conectar callbacks de la tarjeta
        clockCardView.onToggleDesktopWidget = { [weak self] in
            self?.toggleDesktopWidget()
        }
        clockCardView.onOpenWeb = { [weak self] in
            self?.openWebApp()
        }
        clockCardView.onCopyTime = { [weak self] in
            self?.copyDecimalTime()
        }
        
        // Bucle de actualización suave (~60ms) para respuesta visual en tiempo real
        timer = Timer.scheduledTimer(withTimeInterval: 0.065, repeats: true) { [weak self] _ in
            self?.updateClock()
        }
        RunLoop.main.add(timer!, forMode: .common)
        
        updateClock()
    }
    
    // MARK: - Actualización en Vivo
    @objc private func updateClock() {
        let dec = DecimalTime.now()
        
        // Actualizar Barra de Menús
        if let btn = statusItem.button {
            switch currentFormat {
            case .hms:
                btn.title = String(format: "%d:%02d:%02d", dec.hours, dec.minutes, dec.seconds)
            case .hm:
                btn.title = String(format: "%d:%02d", dec.hours, dec.minutes)
            case .pct:
                btn.title = String(format: "%.1f %%", dec.percentage)
            case .detailed:
                btn.title = String(format: "%d:%02d:%02d.%d", dec.hours, dec.minutes, dec.seconds, dec.centiseconds / 10)
            }
        }
        
        // Actualizar Popover si está visible
        if popover.isShown {
            clockCardView.update(with: dec)
        }
        
        // Actualizar Widget de Escritorio si está activo
        if let dw = desktopWidget, dw.isVisible {
            dw.update(with: dec)
        }
    }
    
    // MARK: - Gestión de Eventos y Menú Contextual
    @objc private func handleStatusItemClick(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        
        if event.type == .rightMouseUp {
            showContextMenu()
        } else {
            togglePopover(sender)
        }
    }
    
    private func togglePopover(_ sender: NSStatusBarButton) {
        if popover.isShown {
            popover.performClose(sender)
        } else {
            clockCardView.update(with: DecimalTime.now())
            popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
        }
    }
    
    private func showContextMenu() {
        let menu = NSMenu()
        
        // Opción Widget de Escritorio
        let isWidgetOn = desktopWidget?.isVisible ?? false
        let itemWidget = NSMenuItem(
            title: isWidgetOn ? "Ocultar Widget de Escritorio" : "Mostrar Widget en Escritorio",
            action: #selector(toggleDesktopWidget),
            keyEquivalent: "d"
        )
        itemWidget.target = self
        menu.addItem(itemWidget)
        
        if isWidgetOn {
            let itemLevel = NSMenuItem(title: "Nivel de Visualización", action: nil, keyEquivalent: "")
            let subMenu = NSMenu()
            
            let itemFloat = NSMenuItem(title: "Flotante sobre ventanas", action: #selector(setWidgetLevelFloating), keyEquivalent: "")
            itemFloat.target = self
            itemFloat.state = (desktopWidget?.level == .floating) ? .on : .off
            subMenu.addItem(itemFloat)
            
            let itemDesk = NSMenuItem(title: "Fijado al Fondo de Pantalla", action: #selector(setWidgetLevelDesktop), keyEquivalent: "")
            itemDesk.target = self
            itemDesk.state = (desktopWidget?.level == .desktop) ? .on : .off
            subMenu.addItem(itemDesk)
            
            itemLevel.submenu = subMenu
            menu.addItem(itemLevel)
        }
        
        menu.addItem(NSMenuItem.separator())
        
        // Formato de barra de menús
        let itemFormat = NSMenuItem(title: "Formato en Barra de Menús", action: nil, keyEquivalent: "")
        let formatMenu = NSMenu()
        
        let f1 = NSMenuItem(title: "Horas, Minutos y Segundos (4:74:20)", action: #selector(setFormatHMS), keyEquivalent: "1")
        f1.target = self; f1.state = (currentFormat == .hms) ? .on : .off
        formatMenu.addItem(f1)
        
        let f2 = NSMenuItem(title: "Horas y Minutos (4:74)", action: #selector(setFormatHM), keyEquivalent: "2")
        f2.target = self; f2.state = (currentFormat == .hm) ? .on : .off
        formatMenu.addItem(f2)
        
        let f3 = NSMenuItem(title: "Porcentaje del Día (47.4 %)", action: #selector(setFormatPct), keyEquivalent: "3")
        f3.target = self; f3.state = (currentFormat == .pct) ? .on : .off
        formatMenu.addItem(f3)
        
        let f4 = NSMenuItem(title: "Detallado con Décimas (4:74:20.3)", action: #selector(setFormatDetailed), keyEquivalent: "4")
        f4.target = self; f4.state = (currentFormat == .detailed) ? .on : .off
        formatMenu.addItem(f4)
        
        itemFormat.submenu = formatMenu
        menu.addItem(itemFormat)
        
        menu.addItem(NSMenuItem.separator())
        
        // Copiar hora decimal
        let itemCopy = NSMenuItem(title: "Copiar Hora Decimal Actual", action: #selector(copyDecimalTime), keyEquivalent: "c")
        itemCopy.target = self
        menu.addItem(itemCopy)
        
        // Abrir app web completa
        let itemWeb = NSMenuItem(title: "Abrir Versión Web Completa...", action: #selector(openWebApp), keyEquivalent: "w")
        itemWeb.target = self
        menu.addItem(itemWeb)
        
        menu.addItem(NSMenuItem.separator())
        
        // Salir
        let itemQuit = NSMenuItem(title: "Salir de Reloj Decimal", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(itemQuit)
        
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil // Restaurar comportamiento de popover tras el click
    }
    
    // MARK: - Acciones
    @objc func toggleDesktopWidget() {
        if desktopWidget == nil {
            desktopWidget = DesktopWidgetPanel()
        }
        
        guard let dw = desktopWidget else { return }
        if dw.isVisible {
            dw.orderOut(nil)
            clockCardView.btnDesktop.title = "📌 Fijar en Escritorio"
        } else {
            dw.update(with: DecimalTime.now())
            dw.makeKeyAndOrderFront(nil)
            clockCardView.btnDesktop.title = "✕ Ocultar Widget"
        }
    }
    
    @objc func setWidgetLevelFloating() {
        desktopWidget?.level = .floating
    }
    
    @objc func setWidgetLevelDesktop() {
        desktopWidget?.level = .desktop
    }
    
    @objc func setFormatHMS() { currentFormat = .hms; updateClock() }
    @objc func setFormatHM() { currentFormat = .hm; updateClock() }
    @objc func setFormatPct() { currentFormat = .pct; updateClock() }
    @objc func setFormatDetailed() { currentFormat = .detailed; updateClock() }
    
    @objc func copyDecimalTime() {
        let text = DecimalTime.now().formatted(showCentis: true)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
    
    @objc func openWebApp() {
        let fileManager = FileManager.default
        let home = fileManager.homeDirectoryForCurrentUser
        let webUrl = home.appendingPathComponent("Developer/reloj-tiempo-decimal/index.html")
        NSWorkspace.shared.open(webUrl)
    }
}

// MARK: - Punto de Entrada Principal
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
