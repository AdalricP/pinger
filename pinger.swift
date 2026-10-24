// pinger: flash a flat white bar on the right edge of every screen, then quit.
// Usage: pinger [seconds]   (default 3)
import AppKit

let seconds = Double(CommandLine.arguments.dropFirst().first ?? "") ?? 3
let width: CGFloat = 10
let pulses = 3

let app = NSApplication.shared
app.setActivationPolicy(.accessory)  // no Dock icon, never steals focus

var windows: [NSWindow] = []
for screen in NSScreen.screens {
    let f = screen.frame
    let w = NSWindow(contentRect: NSRect(x: f.maxX - width, y: f.minY, width: width, height: f.height),
                     styleMask: .borderless, backing: .buffered, defer: false)
    w.backgroundColor = .white
    w.isOpaque = false
    w.hasShadow = false
    w.ignoresMouseEvents = true
    w.level = .screenSaver
    w.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
    w.alphaValue = 0
    w.orderFrontRegardless()
    windows.append(w)
}

// Pulse: fade in, hold, fade down, repeat; then fade out and exit.
let step = seconds / Double(pulses)
func pulse(_ n: Int) {
    guard n < pulses else {
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.3
            windows.forEach { $0.animator().alphaValue = 0 }
        }, completionHandler: { exit(0) })
        return
    }
    NSAnimationContext.runAnimationGroup({ ctx in
        ctx.duration = step * 0.35
        windows.forEach { $0.animator().alphaValue = 1 }
    }, completionHandler: {
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = step * 0.65
            windows.forEach { $0.animator().alphaValue = 0.25 }
        }, completionHandler: { pulse(n + 1) })
    })
}
pulse(0)
app.run()
