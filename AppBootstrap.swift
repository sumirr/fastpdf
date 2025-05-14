import SwiftUI

struct AppBootstrap: View {
    @AppStorage("overrideDarkMode") private var overrideDarkMode: Bool = false

    var body: some View {
        ContentView()
            .onAppear {
                if overrideDarkMode {
                    NSApp.appearance = NSAppearance(named: .darkAqua)
                } else {
                    NSApp.appearance = nil
                }
            }
    }
}
