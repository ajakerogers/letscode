// Problem.swift
import Foundation

struct Problem: Identifiable, Decodable {
    let id: String
    let title: String
    let description: String
    let difficulty: String
    let functionBody: String
    let testCases: [TestCase]
}
