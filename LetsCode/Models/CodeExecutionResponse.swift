import Foundation

struct CodeExecutionResponse: Codable {
    let testCaseResults: [TestCase]
    let consoleOutput: String
    let executionTime: Double
}
