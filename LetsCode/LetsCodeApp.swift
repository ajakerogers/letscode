import SwiftUI

@main
struct LeetCodeAppApp: App {
    @StateObject private var viewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            HomeView().environmentObject(viewModel)
        }
    }
}
