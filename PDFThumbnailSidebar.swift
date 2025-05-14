import SwiftUI
import PDFKit

struct PDFThumbnailSidebar: NSViewRepresentable {
    let pdfView: PDFView
    let filter: PDFFilterType
    let animated: Bool

    func makeNSView(context: Context) -> PDFThumbnailView {
        let thumbnailView = PDFThumbnailView()
        thumbnailView.pdfView = pdfView
        thumbnailView.thumbnailSize = CGSize(width: 40, height: 60)

        // Force vertical layout
        if thumbnailView.responds(to: Selector(("setPdfThumbnailLayoutMode:"))) {
            thumbnailView.setValue(0, forKey: "pdfThumbnailLayoutMode") // 0 = vertical
        }

        // Ensure layer exists
        thumbnailView.wantsLayer = true
        if let layer = thumbnailView.layer {
            layer.masksToBounds = true
            layer.cornerRadius = 10

            if filter == .invert {
                layer.backgroundColor = NSColor.black.cgColor
            } else {
                layer.backgroundColor = NSColor.clear.cgColor
            }
        }

        // Also directly set view background color
        if filter == .invert {
            thumbnailView.backgroundColor = .black
        } else {
            thumbnailView.backgroundColor = .clear
        }

        return thumbnailView
    }

    func updateNSView(_ nsView: PDFThumbnailView, context: Context) {
        nsView.pdfView = pdfView
    }
}
