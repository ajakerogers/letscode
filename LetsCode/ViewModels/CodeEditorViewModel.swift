import Foundation

class CodeEditorViewModel: ObservableObject {
    @Published var code: String = ""
    @Published var output: String = ""
    @Published var isLoading: Bool = false
    @Published var testCases: [TestCase] = []
    @Published var consoleOutput: String = ""
    @Published var executionTime: Double = 0.0

    private let codeExecutionService = MockCodeExecutionService()

    func runCode(testCases: [TestCase]) {
        guard !code.isEmpty else { return }
        isLoading = true
        output = "Running..."
        self.testCases = []

        codeExecutionService.executeCode(code, testCases: testCases) { [weak self] response in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.testCases = response.testCaseResults
                self?.consoleOutput = response.consoleOutput
                self?.executionTime = response.testCaseResults.reduce(0) { $0 + ($1.passed ? 0.2 : 0.5) }
            }
        }
    }
}
