import SwiftUI
import PDFKit
import QuartzCore

struct FilteredPDFView: NSViewRepresentable {
    let pdfView: PDFView
    let filter: PDFFilterType
    let animated: Bool

    func makeNSView(context: Context) -> PDFView {
        applyFilter(to: pdfView)
        pdfView.backgroundColor = .black // force background to black
        pdfView.documentView?.wantsLayer = true
        return pdfView
    }

    func updateNSView(_ nsView: PDFView, context: Context) {
        applyFilter(to: nsView)
    }

    private func applyFilter(to view: PDFView) {
        guard let documentLayer = view.documentView?.layer else { return }

        let filterLayer = makeFilter(for: filter)
        documentLayer.backgroundColor = NSColor.black.cgColor // keep background dark

        if animated {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.25)
            view.layer?.opacity = 0
            documentLayer.filters = filterLayer.map { [$0] }
            view.layer?.opacity = 1
            CATransaction.commit()
        } else {
            documentLayer.filters = filterLayer.map { [$0] }
        }
    }

    private func makeFilter(for type: PDFFilterType) -> CIFilter? {
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
