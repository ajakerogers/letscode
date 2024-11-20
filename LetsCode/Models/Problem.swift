import Foundation

struct Problem: Identifiable, Codable {
    let id: Int?
    let title: String
    let description: String
    let difficulty: String
    let functionBody: String
    let solved: Bool
    let solution: String?
    let attempts: Int
    let testCases: [TestCase]
}
