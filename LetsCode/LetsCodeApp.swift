import SwiftUI

@main
struct LeetCodeAppApp: App {
    @StateObject private var viewModel = AppViewModel()

    init() {
        // Initialize PythonRunner
        PythonRunner.shared.initializePython()
    }

    var body: some Scene {
        WindowGroup {
            HomeView().environmentObject(viewModel)
        }
    }
}
