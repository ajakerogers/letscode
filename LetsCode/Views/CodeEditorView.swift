// CodeEditorView.swift
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
                ScrollView(.horizontal) {
                    CustomTextEditor(text: $viewModel.code)
                        .frame(height: 300)
                        .frame(width: calculateWidth(for: viewModel.code))
                }
                
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
                        if !viewModel.testCases.isEmpty {
                            let testCase = viewModel.testCases[selectedTestIndex]

                            VStack(alignment: .leading, spacing: 8) {
                                CodeBlock(label: "Input:", content: "\(testCase.input)")
                                CodeBlock(label: "Expected Output:", content: "\(testCase.expectedOutput)")
                                CodeBlock(label: "Actual Output:", content: "\(testCase.actualOutput ?? "Not executed")")
                                CodeBlock(label: "Console Log:", content: testCase.consoleOutput)  // Display per-test-case console output
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
        .onAppear {
            viewModel.code = problem?.functionBody ?? "Write your code here..."
        }
    }
    
    // Helper function to calculate the width based on the content length
    private func calculateWidth(for text: String) -> CGFloat {
        let characterWidth: CGFloat = 8.0 // Average width for monospaced font
        let padding: CGFloat = 40.0 // Additional padding
        let minWidth = UIScreen.main.bounds.width - 40 // Minimum width based on screen size
        let maxWidth = UIScreen.main.bounds.width * 2 // Maximum width set to twice the screen width

        // Calculate the estimated width and clamp it between minWidth and maxWidth
        let estimatedWidth = CGFloat(text.count) * characterWidth + padding
        return max(min(estimatedWidth, maxWidth), minWidth)
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
