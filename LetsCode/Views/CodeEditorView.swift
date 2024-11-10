import SwiftUI

struct CodeEditorView: View {
    @StateObject private var viewModel = CodeEditorViewModel()
    let problem: Problem?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Problem Title and Description
                if let problem = problem {
                    Text(problem.title)
                        .font(.title)
                        .bold()
                    Text(problem.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                // Code Editor
                TextEditor(text: $viewModel.code)
                    .border(Color.gray.opacity(0.3), width: 1)
                    .padding()
                    .frame(height: 300)

                // Run Code Button
                Button(action: {
                    viewModel.runCode(testCases: problem?.testCases ?? [])
                }) {
                    Text(viewModel.isLoading ? "Running..." : "Run Code")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(viewModel.isLoading ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(viewModel.isLoading)
                .padding()

                // Summary of Test Results
                if viewModel.testCases.isEmpty == false {
                    let allPassed = viewModel.testCases.allSatisfy { $0.passed }
                    let summaryColor = allPassed ? Color.green : Color.red

                    VStack(alignment: .leading) {
                        Text(allPassed ? "All Tests Passed" : "Some Tests Failed")
                            .foregroundColor(summaryColor)
                            .font(.headline)

                        Text("Execution Time: \(viewModel.executionTime, specifier: "%.2f")s")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.gray.opacity(0.3), radius: 4, x: 0, y: 2)
                }

                // Test Cases List
                ForEach(viewModel.testCases.indices, id: \.self) { index in
                    let testCase = viewModel.testCases[index]

                    HStack {
                        DisclosureGroup {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Input: \(testCase.input)")
                                Text("Expected Output: \(testCase.expectedOutput)")
                                Text("Actual Output: \(testCase.actualOutput ?? "Not executed")")
                                Text("Console Log: \(viewModel.consoleOutput)")
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(color: Color.gray.opacity(0.3), radius: 4, x: 0, y: 2)
                        } label: {
                            Text("Test \(index + 1): \(testCase.passed ? "✅ Passed" : "❌ Failed")")
                                .foregroundColor(testCase.passed ? .green : .red)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(color: Color.gray.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                }
            }
            .padding()
        }
        .navigationTitle("Solve Problem")
    }
}
