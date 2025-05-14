import SwiftUI

struct SidebarView: View {
    var recentFiles: [URL]
    var onOpen: (URL) -> Void

    @AppStorage("overrideDarkMode") private var overrideDarkMode: Bool = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea() // ensure total black background

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent PDFs")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top)

                    ForEach(recentFiles, id: \.self) { file in
                        Button(action: { onOpen(file) }) {
                            HStack(spacing: 8) {
                                Image(systemName: "doc.richtext")
                                    .foregroundColor(.white)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(file.lastPathComponent)
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .lineLimit(1)

                                    Text(file.deletingLastPathComponent().path)
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(8)
                            .background(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
        }
    }
}
