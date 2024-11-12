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
        guard !code.isEmpty else {
            output = "Code cannot be empty."
            return
        }

        isLoading = true
        output = "Running..."
        self.testCases = []

        // Prepare the user code with necessary boilerplate
        let codeToExecute = """
        def user_function(input):
            \(code)
        """

        // Execute the user code using the service
        codeExecutionService.executeCode(codeToExecute, testCases: testCases) { [weak self] response in
            DispatchQueue.main.async {
                guard let self = self else { return }

                self.isLoading = false
                self.testCases = response.testCaseResults
                self.consoleOutput = response.consoleOutput

                // Calculate the total execution time based on test case results
                self.executionTime = self.testCases.reduce(0.0) { $0 + ($1.passed ? 0.2 : 0.5) }

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
