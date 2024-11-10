import SwiftUI

struct CodeEditorView: View {
    @StateObject private var viewModel = CodeEditorViewModel()
    let problem: Problem?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let problem = problem {
                    Text(problem.title)
                        .font(.title)
                        .bold()
                    Text(problem.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                TextEditor(text: $viewModel.code)
                    .border(Color.gray.opacity(0.3), width: 1)
                    .padding()
                    .frame(height: 300)

                Button(action: {
                    viewModel.runCode()
                }) {
                    Text("Run Code")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .padding()
        }
        .navigationTitle("Solve Problem")
    }
}

struct CodeEditorView_Previews: PreviewProvider {
    static var previews: some View {
        CodeEditorView(problem: AppViewModel().problems.first)
    }
}
