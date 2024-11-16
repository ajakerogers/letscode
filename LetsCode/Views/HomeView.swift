import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var selectedProblem: Problem?
    @State private var selectedTab: Tab = .home

    enum Tab {
        case home
        case profile
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationStack {
                VStack(spacing: 20) {
                    Text("LetsCode")
                        .font(.largeTitle)
                        .bold()

                    Button(action: {
                        selectedProblem = viewModel.getRandomProblem(difficulty: "Easy")
                    }) {
                        Text("Easy")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        selectedProblem = viewModel.getRandomProblem(difficulty: "Medium")
                    }) {
                        Text("Medium")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        selectedProblem = viewModel.getRandomProblem(difficulty: "Hard")
                    }) {
                        Text("Hard")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .navigationDestination(isPresented: Binding(
                    get: { selectedProblem != nil },
                    set: { if !$0 { selectedProblem = nil } }
                )) {
                    if let problem = selectedProblem {
                        CodeEditorView(problem: problem)
                    }
                }
                .onAppear {
                    // Reset selectedProblem when returning to the HomeView
                    selectedProblem = nil
                }
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(Tab.home)

            // Profile Tab
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle")
            }
            .tag(Tab.profile)
        }
    }
}
