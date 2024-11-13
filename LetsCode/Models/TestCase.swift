import Foundation

struct TestCase: Identifiable {
    let id = UUID()
    let input: String
    let expectedOutput: String
    var actualOutput: String?
    var functionCall: String?
    var consoleOutput: String = ""  // New property
    var passed: Bool = false
}
