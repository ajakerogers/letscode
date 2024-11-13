// TestCase.swift
import Foundation

struct TestCase: Identifiable {
    let id = UUID()
    let input: String
    let expectedOutput: String
    var actualOutput: String?
    var functionCall: String?
    var passed: Bool = false
}
