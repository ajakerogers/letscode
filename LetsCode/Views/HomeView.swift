// HomeView.swift
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var selectedProblem: Problem?

    var body: some View {
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

                NavigationLink(
                    destination: CodeEditorView(problem: selectedProblem),
                    isActive: .constant(selectedProblem != nil)
                ) {
                    EmptyView()
                }
            }
            .padding()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(AppViewModel())
    }
}
