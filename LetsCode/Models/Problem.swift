// Problem.swift
import Foundation

struct Problem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let difficulty: String
    let testCases: [TestCase]
}
