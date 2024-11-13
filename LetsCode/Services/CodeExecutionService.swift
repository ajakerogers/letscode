// CodeExecutionService.swift
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
                let functionCall = testCase.functionCall ?? ""
                
                // Combine code with function call for execution
                let codeToExecute = "\(code)\nresult = \(functionCall)"
                
                if let result = PythonRunner.shared.executeUserCode(codeToExecute, withInput: input) {
                    updatedTestCase.actualOutput = result.output
                    consoleOutput += result.consoleOutput
                } else {
                    updatedTestCase.actualOutput = "Error"
                    consoleOutput += "Error occurred during execution.\n"
                }
                
                updatedTestCases.append(updatedTestCase)
            }
            
            let executionTime = Date().timeIntervalSince(startTime)
            
            let response = CodeExecutionResponse(testCaseResults: updatedTestCases, consoleOutput: consoleOutput, executionTime: executionTime)
            
            DispatchQueue.main.async {
                completion(response)
            }
        }
    }
}
