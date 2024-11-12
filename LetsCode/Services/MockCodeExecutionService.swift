import Foundation

class MockCodeExecutionService {
    func executeCode(_ code: String, testCases: [TestCase], completion: @escaping (CodeExecutionResponse) -> Void) {
        // Simulate a delay to mimic code execution
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let updatedTestCases = testCases.map { testCase in
                var updatedTestCase = testCase

                // Generate a random number for the actual output
                let randomOutput = Int.random(in: 0...100)
                updatedTestCase.actualOutput = "\(randomOutput)"

                return updatedTestCase
            }

            let consoleOutput = "Executed code successfully with mock logs"
            let response = CodeExecutionResponse(testCaseResults: updatedTestCases, consoleOutput: consoleOutput)
            completion(response)
        }
    }
}
