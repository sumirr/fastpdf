import SwiftUI
import PDFKit

struct PDFKitView: NSViewRepresentable {
    var document: PDFDocument
    @Binding var pdfView: PDFView?

    func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        DispatchQueue.main.async {
            self.pdfView = pdfView
        }
        return pdfView
    }

    func updateNSView(_ nsView: PDFView, context: Context) {
        nsView.document = document
    }
}
