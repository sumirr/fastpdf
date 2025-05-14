import SwiftUI

enum PDFFilterType: String, CaseIterable, Identifiable {
    case none = "None"
    case invert = "Invert"
    case grayscale = "Grayscale"
    case sepia = "Sepia"
    case dimmed = "Dimmed"

    var id: String { rawValue }

    var shortcutKey: KeyEquivalent? {
        switch self {
        case .invert: return "i"
        case .grayscale: return "g"
        case .sepia: return "s"
        case .dimmed: return "d"
        case .none: return nil
        }
    }
}
