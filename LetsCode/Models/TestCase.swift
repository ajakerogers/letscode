import Foundation

struct TestCase: Identifiable, Codable {
    let id: UUID
    let input: String
    let expectedOutput: String
    let functionCall: String
    var actualOutput: String?

    var passed: Bool {
        return actualOutput?.trimmingCharacters(in: .whitespacesAndNewlines) == expectedOutput.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    init(id: UUID = UUID(), input: String, expectedOutput: String, functionCall: String, actualOutput: String? = nil) {
        self.id = id
        self.input = input
        self.expectedOutput = expectedOutput
        self.actualOutput = actualOutput
        self.functionCall = functionCall
    }
}
