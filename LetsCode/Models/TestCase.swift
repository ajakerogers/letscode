import Foundation

struct TestCase: Identifiable, Codable {
    let id: Int?
    let input: String
    let expectedOutput: String
    var actualOutput: String?
    var functionCall: String
    var consoleOutput: String // New property
    var passed: Bool
}
