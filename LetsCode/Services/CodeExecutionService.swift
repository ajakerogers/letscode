// CodeExecutionService.swift
import Foundation

class CodeExecutionService {
    func executeCode(_ code: String, testCases: [TestCase], completion: @escaping (CodeExecutionResponse) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var updatedTestCases = [TestCase]()
            let startTime = Date()

            for testCase in testCases {
                var updatedTestCase = testCase
                let input = testCase.input
                let functionCall = testCase.functionCall

                // Combine code with function call for execution
                let codeToExecute = "\(code)\nresult = \(functionCall)"

                // Execute user code and capture result
                if let result = PythonRunner.shared.executeUserCode(codeToExecute, withInput: input) {
                    updatedTestCase.actualOutput = result.output
                    updatedTestCase.consoleOutput = result.consoleOutput  // Store console output per test case
                } else {
                    updatedTestCase.actualOutput = "Error"
                    updatedTestCase.consoleOutput = "Error occurred during execution.\n"
                }

                updatedTestCases.append(updatedTestCase)
            }

            let executionTime = Date().timeIntervalSince(startTime)
            let response = CodeExecutionResponse(testCaseResults: updatedTestCases, executionTime: executionTime)

            DispatchQueue.main.async {
                completion(response)
            }
        }
    }
}
