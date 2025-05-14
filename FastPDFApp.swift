import SwiftUI
import AppKit

@main
struct FastPDFApp: App {
    @AppStorage("overrideDarkMode") private var overrideDarkMode: Bool = false
    @AppStorage("selectedFilter") private var selectedFilter: String = PDFFilterType.invert.rawValue
    @State private var preferencesWindow: NSWindow?

    var body: some Scene {
        WindowGroup {
            TabsView()
        }
        .commands {
            CommandGroup(after: .appSettings) {
                Button("Preferences") {
                    openPreferences()
                }
                .keyboardShortcut(",", modifiers: [.command])
            }

            CommandGroup(after: .newItem) {
                Button("New Tab") {
                    AppState.shared.triggerNewTab = true
                }
                .keyboardShortcut("t", modifiers: [.command])

                Button("Toggle Dark Mode") {
                    overrideDarkMode.toggle()
                    NSApp.appearance = overrideDarkMode ? NSAppearance(named: .darkAqua) : nil
                }
                .keyboardShortcut("d", modifiers: [.command])

                ForEach(PDFFilterType.allCases.filter { $0 != .none }) { filter in
                    if let key = filter.shortcutKey {
                        Button("Apply \(filter.rawValue) Filter") {
                            selectedFilter = filter.rawValue
                            overrideDarkMode = true
                            NSApp.appearance = NSAppearance(named: .darkAqua)
                        }
                        .keyboardShortcut(key, modifiers: [.command, .shift])
                    }
                }
            }
        }
    }

    func openPreferences() {
        if preferencesWindow == nil {
            let hosting = NSHostingController(rootView: PreferencesWindow())
            preferencesWindow = NSWindow(contentViewController: hosting)
            preferencesWindow?.title = "Preferences"
            preferencesWindow?.styleMask = [.titled, .closable]
            preferencesWindow?.isReleasedWhenClosed = false
        }

        preferencesWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
