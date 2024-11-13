import Foundation

class CodeExecutionService {
    func executeCode(_ code: String, testCases: [TestCase], completion: @escaping (CodeExecutionResponse) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var updatedTestCases = [TestCase]()
            var consoleOutput = ""
            let startTime = Date()
            
            for testCase in testCases {
                var updatedTestCase = testCase
                let input = testCase.input
                
                if let result = PythonRunner.shared.executeUserCode(code, withInput: input) {
                    updatedTestCase.actualOutput = result
                } else {
                    updatedTestCase.actualOutput = "Error"
                }
                
                updatedTestCases.append(updatedTestCase)
            }
            
            let executionTime = Date().timeIntervalSince(startTime)
            consoleOutput = ""
            
            let response = CodeExecutionResponse(testCaseResults: updatedTestCases, consoleOutput: consoleOutput, executionTime: executionTime)
            
            DispatchQueue.main.async {
                completion(response)
            }
        }
    }
}
