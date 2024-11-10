import Foundation

class CodeEditorViewModel: ObservableObject {
    @Published var code: String = "// Write your code here"
    @Published var output: String = ""
    @Published var isLoading: Bool = false
    @Published var testCases: [TestCase] = []

    private let codeExecutionService = MockCodeExecutionService()

    func runCode() {
        guard !code.isEmpty else { return }
        isLoading = true
        output = "Running..."

        codeExecutionService.executeCode(code, testCases: testCases) { [weak self] response in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.testCases = response.testCaseResults
                self?.output = response.consoleOutput
            }
        }
    }
}
