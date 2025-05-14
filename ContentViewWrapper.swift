import SwiftUI
import PDFKit

struct ContentViewWrapper: View {
    let tab: PDFTab
    @State private var pdfView: PDFView = PDFView()
    @State private var showSidebar: Bool = true

    @AppStorage("overrideDarkMode") private var overrideDarkMode: Bool = false
    @AppStorage("selectedFilter") private var storedFilter: String = PDFFilterType.invert.rawValue
    @AppStorage("sidebarPosition") private var sidebarPosition: SidebarPosition = .left // default to left
    @AppStorage("defaultZoom") private var defaultZoom: Double = 1.0
    @AppStorage("activeTabColor") private var activeTabColor: String = "blue"
    @AppStorage("isToolbarVisible") private var isToolbarVisible: Bool = true

    private var selectedFilterType: PDFFilterType {
        PDFFilterType(rawValue: storedFilter) ?? .none
    }

    var body: some View {
        ZStack {
            colorFromName(activeTabColor)
                .opacity(overrideDarkMode ? 0.2 : 0.08)
                .ignoresSafeArea()

            HStack(spacing: 16) {
                if showSidebar && sidebarPosition == .left {
                    CustomThumbnailSidebar(
                        pdfView: pdfView,
                        document: tab.document,
                        filter: overrideDarkMode ? selectedFilterType : .none
                    ) { index in
                        if let page = tab.document.page(at: index) {
                            pdfView.go(to: page)
                        }
                    }
                    .frame(width: 140)
                    .padding()
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 4)
                }

                // ✅ Main PDF viewer
                FilteredPDFView(
                    pdfView: pdfView,
                    filter: overrideDarkMode ? selectedFilterType : .none,
                    animated: true
                )
                .padding()
                .background(.windowBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 4)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            pdfView.document = tab.document
            pdfView.autoScales = true
            pdfView.minScaleFactor = 0.25
            pdfView.maxScaleFactor = 8.0
            pdfView.scaleFactor = defaultZoom
        }
        .onReceive(NotificationCenter.default.publisher(for: .toggleSidebar)) { _ in
            withAnimation {
                showSidebar.toggle()
            }
        }
    }

    // MARK: - Color mapping helper

    func colorFromName(_ name: String) -> Color {
        switch name.lowercased() {
        case "blue": return .blue
        case "red": return .red
        case "green": return .green
        case "purple": return .purple
        case "gray": return .gray
        default: return .accentColor
        }
    }
}
