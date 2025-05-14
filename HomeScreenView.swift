import SwiftUI

struct HomeScreenView: View {
    @Binding var recentFiles: [URL]
    let onOpen: (URL) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Text("Welcome to FastPDF")
                .font(.system(size: 28, weight: .bold))
                .padding(.top, 30)
                .padding(.horizontal)

            Text("Recent Documents")
                .font(.title2)
                .foregroundColor(.secondary)
                .padding(.top, 8)
                .padding(.horizontal)

            if recentFiles.isEmpty {
                Text("You haven’t opened any PDFs yet.")
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    .padding(.top, 16)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(recentFiles, id: \.self) { url in
                            Button(action: {
                                if FileManager.default.fileExists(atPath: url.path) {
                                    onOpen(url)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "doc.richtext")
                                        .foregroundColor(.accentColor)
                                        .frame(width: 24)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(url.lastPathComponent)
                                            .font(.headline)
                                        Text(url.path)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.primary.opacity(0.05)))
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 10)
                }
            }

            Spacer()

            HStack {
                Spacer()
                Button(action: pickPDFManually) {
                    Label("Open PDF…", systemImage: "folder")
                }
                .keyboardShortcut("o", modifiers: [.command])
                .padding(.bottom, 20)

                Button(action: {
                    recentFiles = RecentFiles.load()
                }) {
                    Label("Reload", systemImage: "arrow.clockwise")
                }
                .padding(.bottom, 20)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
            handleDrop(providers)
        }
    }

    private func pickPDFManually() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.pdf]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        if panel.runModal() == .OK, let url = panel.url {
            onOpen(url)
        }
    }

    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first(where: { $0.hasItemConformingToTypeIdentifier("public.file-url") }) else {
            return false
        }

        provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, _ in
            if let data = item as? Data,
               let url = URL(dataRepresentation: data, relativeTo: nil),
               url.pathExtension.lowercased() == "pdf" {
                DispatchQueue.main.async {
                    onOpen(url)
                }
            }
        }

        return true
    }
}
