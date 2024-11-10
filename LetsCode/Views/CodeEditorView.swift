import SwiftUI

struct CodeEditorView: View {
    @StateObject private var viewModel = CodeEditorViewModel()
    let problem: Problem?
    @State private var selectedTestIndex: Int = 0
    
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
                    .font(.system(.body, design: .monospaced))
                    .border(Color.gray.opacity(0.3), width: 1)
                    .padding()
                    .frame(height: 300)
                    .background(Color.white)
                    .cornerRadius(4)
                    .autocapitalization(.none) // Disable auto-capitalization
                    .disableAutocorrection(true) // Disable auto-correction

                // Run Code Button
                Button(action: {
                    viewModel.runCode(testCases: problem?.testCases ?? [])
                }) {
                    Text(viewModel.isLoading ? "Running..." : "Run Code")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(viewModel.isLoading ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
                .disabled(viewModel.isLoading)
                .padding()

                // Execution Summary
                if !viewModel.isLoading && !viewModel.testCases.isEmpty {
                    let allPassed = viewModel.testCases.allSatisfy { $0.passed }
                    let summaryColor = allPassed ? Color.green.opacity(0.1) : Color.red.opacity(0.1)

                    VStack {
                        HStack {
                            Text(allPassed ? "All Cases Passed" : "Some Cases Failed")
                                .foregroundColor(allPassed ? .green : .red)
                                .font(.headline)
                            Spacer()
                            Text("Execution Time: \(viewModel.executionTime, specifier: "%.2f")s")
                                .foregroundColor(.secondary)
                        }
                        .padding(15)
                        .background(summaryColor)
                        .cornerRadius(4)
                    }
                    .padding(.horizontal)

                    // Test Results Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Test Results")
                            .font(.headline)
                            .padding(.leading)

                        // Test Case Selectors
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(viewModel.testCases.indices, id: \.self) { index in
                                    let testCase = viewModel.testCases[index]
                                    let passed = testCase.passed
                                    let isSelected = selectedTestIndex == index
                                    let buttonColor = passed ? (isSelected ? Color.green : Color.green.opacity(0.3)) : (isSelected ? Color.red : Color.red.opacity(0.3))

                                    Button(action: {
                                        selectedTestIndex = index
                                    }) {
                                        Text("Case \(index + 1)")
                                            .padding(8)
                                            .background(buttonColor)
                                            .foregroundColor(isSelected ? .white : (passed ? .green : .red))
                                            .cornerRadius(4)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        // Selected Test Case Details
                        if !viewModel.testCases.isEmpty  {
                            let testCase = viewModel.testCases[selectedTestIndex]

                            VStack(alignment: .leading, spacing: 8) {
                                CodeBlock(label: "Input:", content: "[\(testCase.input)]")
                                CodeBlock(label: "Expected Output:", content: "[\(testCase.expectedOutput)]")
                                CodeBlock(label: "Actual Output:", content: "[\(testCase.actualOutput ?? "Not executed")]")
                                CodeBlock(label: "Console Log:", content: viewModel.consoleOutput)
                            }
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(4)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }
            }
            .padding()
        }
        .navigationTitle("Solve Problem")
    }
}

// Helper View for Code Blocks
struct CodeBlock: View {
    let label: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.body)
                .bold()
            Text(content)
                .font(.system(.body, design: .monospaced))
                .padding(8)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(4)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
