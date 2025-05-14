import SwiftUI

enum SidebarPosition: String, CaseIterable, Identifiable {
    case left = "Left"
    case right = "Right"
    var id: String { self.rawValue }
}

struct PreferencesWindow: View {
    @AppStorage("overrideDarkMode") private var overrideDarkMode: Bool = false
    @AppStorage("selectedFilter") private var storedFilter: String = PDFFilterType.invert.rawValue
    @AppStorage("sidebarPosition") private var sidebarPosition: SidebarPosition = .left
    @AppStorage("defaultZoom") private var defaultZoom: Double = 1.0
    @AppStorage("lastOpenedPDFPath") private var lastOpenedPDFPath: String?
    @AppStorage("activeTabColor") private var activeTabColor: String = "blue"

    var body: some View {
        Form {
            Section(header: Text("Appearance")) {
                Toggle("Enable Dark Mode", isOn: $overrideDarkMode)

                Picker("Default Filter", selection: $storedFilter) {
                    ForEach(PDFFilterType.allCases) { filter in
                        Text(filter.rawValue).tag(filter.rawValue)
                    }
                }

                Picker("Active Tab Color", selection: $activeTabColor) {
                    Text("Blue").tag("blue")
                    Text("Red").tag("red")
                    Text("Green").tag("green")
                    Text("Purple").tag("purple")
                    Text("Gray").tag("gray")
                }
            }

            Section(header: Text("Layout")) {
                Picker("Sidebar Position", selection: $sidebarPosition) {
                    ForEach(SidebarPosition.allCases) { position in
                        Text(position.rawValue).tag(position)
                    }
                }

                Stepper(value: $defaultZoom, in: 0.5...3.0, step: 0.25) {
                    Text("Default Zoom: \(String(format: "%.2fx", defaultZoom))")
                }
            }

            Section(header: Text("Session")) {
                Toggle("Reopen Last PDF on Launch", isOn: .constant(lastOpenedPDFPath != nil))
                    .disabled(true)
                    .help("This is managed automatically when you open a PDF.")
            }

            Section {
                Button("Reset to Defaults") {
                    resetDefaults()
                }
                .keyboardShortcut(.delete, modifiers: [.command])
            }
        }
        .padding(20)
        .frame(width: 380)
    }

    private func resetDefaults() {
        let defaults = UserDefaults.standard

        defaults.set(false, forKey: "overrideDarkMode")
        defaults.set(PDFFilterType.invert.rawValue, forKey: "selectedFilter")
        defaults.set(SidebarPosition.left.rawValue, forKey: "sidebarPosition")
        defaults.set(1.0, forKey: "defaultZoom")
        defaults.removeObject(forKey: "lastOpenedPDFPath")
        defaults.set("blue", forKey: "activeTabColor")

        // Force UI refresh
        overrideDarkMode = false
        storedFilter = PDFFilterType.invert.rawValue
        sidebarPosition = .left
        defaultZoom = 1.0
        lastOpenedPDFPath = nil
        activeTabColor = "blue"
        NSApp.appearance = nil
    }
}
