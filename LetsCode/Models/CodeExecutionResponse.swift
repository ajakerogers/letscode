// CodeExecutionResponse.swift
import Foundation

struct CodeExecutionResponse {
    let testCaseResults: [TestCase]
    let consoleOutput: String
    let executionTime: TimeInterval
}
