import SwiftUI
import PDFKit

struct CustomThumbnailSidebar: View {
    let pdfView: PDFView
    let document: PDFDocument
    let filter: PDFFilterType
    let onPageSelect: (Int) -> Void

    @State private var thumbnails: [NSImage] = []

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(thumbnails.enumerated()), id: \.0) { index, thumbnail in
                    Button(action: {
                        onPageSelect(index)
                    }) {
                        VStack(spacing: 4) {
                            Image(nsImage: thumbnail)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 80)
                                .cornerRadius(6)

                            Text("\(pageLabel(for: index))")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .padding(6)
                        .background(Color.black)
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
        .frame(minWidth: 100)
        .background(Color.black)
        .onAppear {
            generateThumbnails()
        }
    }

    private func generateThumbnails() {
        DispatchQueue.global(qos: .userInitiated).async {
            var images: [NSImage] = []
            for index in 0..<document.pageCount {
                guard let page = document.page(at: index) else { continue }
                var thumb = page.thumbnail(of: CGSize(width: 60, height: 80), for: .artBox)

                if let tiffData = thumb.tiffRepresentation,
                   let ciImage = CIImage(data: tiffData),
                   let filter = makeCIFilter(for: filter) {
                    filter.setValue(ciImage, forKey: kCIInputImageKey)
                    if let output = filter.outputImage {
                        let rep = NSCIImageRep(ciImage: output)
                        let final = NSImage(size: rep.size)
                        final.addRepresentation(rep)
                        thumb = final
                    }
                }

                images.append(thumb)
            }

            DispatchQueue.main.async {
                self.thumbnails = images
            }
        }
    }

    private func pageLabel(for index: Int) -> String {
        return document.page(at: index)?.label ?? "\(index + 1)"
    }

    private func makeCIFilter(for type: PDFFilterType) -> CIFilter? {
        switch type {
        case .invert: return CIFilter(name: "CIColorInvert")
        case .grayscale: return CIFilter(name: "CIPhotoEffectMono")
        case .sepia: return CIFilter(name: "CISepiaTone")
        case .dimmed:
            let f = CIFilter(name: "CIColorControls")
            f?.setValue(0.6, forKey: kCIInputBrightnessKey)
            return f
        default: return nil
        }
    }
}
