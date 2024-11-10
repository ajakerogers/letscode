import Foundation

struct TestCase: Identifiable, Codable {
    let id: UUID
    let input: String
    let expectedOutput: String
    var actualOutput: String?

    var passed: Bool {
        return actualOutput == expectedOutput
    }

    init(id: UUID = UUID(), input: String, expectedOutput: String, actualOutput: String? = nil) {
        self.id = id
        self.input = input
        self.expectedOutput = expectedOutput
        self.actualOutput = actualOutput
    }
}
