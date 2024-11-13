import Foundation

class CodeEditorViewModel: ObservableObject {
    @Published var code: String = ""
    @Published var output: String = ""
    @Published var isLoading: Bool = false
    @Published var testCases: [TestCase] = []
    @Published var consoleOutput: String = ""
    @Published var executionTime: Double = 0.0

    private let codeExecutionService = CodeExecutionService()

    func runCode(testCases: [TestCase]) {
        guard !code.isEmpty else {
            output = "Code cannot be empty."
            return
        }

        isLoading = true
        output = "Running..."
        self.testCases = []

        // Prepare the user code (ensure it defines 'user_function')
        let codeToExecute = code

        codeExecutionService.executeCode(codeToExecute, testCases: testCases) { [weak self] response in
            DispatchQueue.main.async {
                guard let self = self else { return }

                self.isLoading = false
                self.testCases = response.testCaseResults
                self.consoleOutput = response.consoleOutput
                self.executionTime = response.executionTime

                // Check if all test cases passed
                if self.testCases.allSatisfy({ $0.passed }) {
                    self.output = "All test cases passed!"
                } else {
                    self.output = "Some test cases failed."
                }
            }
        }
    }
}
