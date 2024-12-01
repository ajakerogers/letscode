import SwiftUI

@main
struct LetsCodeApp: App {
    @StateObject private var viewModel = AppViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()

    init() {
        PythonRunner.shared.initializePython()
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(viewModel)
                .environmentObject(profileViewModel)
        }
    }
}
