import SwiftUI

@main
struct LeetCodeAppApp: App {
    @StateObject private var viewModel = AppViewModel()

    init() {
        // Initialize PythonRunner
        _ = PythonRunner.shared
    }

    var body: some Scene {
        WindowGroup {
            HomeView().environmentObject(viewModel)
        }
    }
}
