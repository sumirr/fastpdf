import Foundation

class AppState: ObservableObject {
    static let shared = AppState()
    @Published var triggerNewTab: Bool = false
}
