import SwiftUI
import PDFKit

struct TabsView: View {
    @State private var openTabs: [PDFTab] = []
    @State private var selectedTabID: UUID? = nil
    @State private var recentFiles: [URL] = RecentFiles.load()

    @AppStorage("overrideDarkMode") private var overrideDarkMode: Bool = false
    @AppStorage("selectedFilter") private var storedFilter: String = PDFFilterType.invert.rawValue

    private let homeTabID = UUID() // consistent ID for home tab

    var body: some View {
        TabView(selection: $selectedTabID) {
            HomeScreenView(recentFiles: $recentFiles, onOpen: { url in
                openPDF(from: url)
            })
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(homeTabID)

            ForEach(openTabs) { tab in
                ContentViewWrapper(tab: tab)
                    .tabItem {
                        Text(tab.url.lastPathComponent)
                    }
                    .tag(tab.id)
            }
        }
        .onAppear {
            if openTabs.isEmpty {
                selectedTabID = homeTabID
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Button(action: toggleSidebar) {
                    Label("Toggle Sidebar", systemImage: "sidebar.leading")
                }

                Button(action: toggleDarkMode) {
                    Label("Dark Mode", systemImage: "moon.fill")
                }

                Menu("Filter") {
                    ForEach(PDFFilterType.allCases) { type in
                        Button(type.rawValue) {
                            storedFilter = type.rawValue
                            if type != .none {
                                overrideDarkMode = true
                                NSApp.appearance = NSAppearance(named: .darkAqua)
                            }
                        }
                    }
                }
            }
        }
    }

    func openPDF(from url: URL) {
        guard let document = PDFDocument(url: url) else { return }
        let newTab = PDFTab(document: document, url: url)
        openTabs.append(newTab)
        selectedTabID = newTab.id
        RecentFiles.add(url)
        recentFiles = RecentFiles.load() // refresh
    }

    func openPDF() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.pdf]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        if panel.runModal() == .OK, let url = panel.url {
            openPDF(from: url)
        }
    }

    func toggleSidebar() {
        NotificationCenter.default.post(name: .toggleSidebar, object: nil)
    }

    func toggleDarkMode() {
        overrideDarkMode.toggle()
        NSApp.appearance = overrideDarkMode ? NSAppearance(named: .darkAqua) : nil
    }
}

extension Notification.Name {
    static let toggleSidebar = Notification.Name("ToggleSidebar")
}