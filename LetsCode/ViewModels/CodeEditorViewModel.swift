// CodeEditorViewModel.swift
import Foundation

class CodeEditorViewModel: ObservableObject {
    @Published var code: String = ""
    @Published var isLoading: Bool = false
    @Published var testCases: [TestCase] = []
    @Published var consoleOutput: String = ""
    @Published var executionTime: TimeInterval = 0.0

    private let codeExecutionService = CodeExecutionService()

    func runCode(testCases: [TestCase]) {
        guard !code.isEmpty else { return }
        isLoading = true
        self.testCases = testCases

        codeExecutionService.executeCode(code, testCases: testCases) { response in
            self.testCases = response.testCaseResults.map { testCase in
                var updatedTestCase = testCase
                if let actualOutput = testCase.actualOutput {
                    updatedTestCase.passed = actualOutput.trimmingCharacters(in: .whitespacesAndNewlines) == testCase.expectedOutput.trimmingCharacters(in: .whitespacesAndNewlines)
                } else {
                    updatedTestCase.passed = false
                }
                return updatedTestCase
            }
            self.executionTime = response.executionTime
            self.isLoading = false
        }
    }

    func getConsoleOutput(for index: Int) -> String {
        return testCases.indices.contains(index) ? testCases[index].consoleOutput : ""
    }
}
