import Foundation
import PDFKit

struct PDFTab: Identifiable, Equatable {
    let id = UUID()
    let document: PDFDocument
    let url: URL

    static func == (lhs: PDFTab, rhs: PDFTab) -> Bool {
        lhs.id == rhs.id
    }
}
