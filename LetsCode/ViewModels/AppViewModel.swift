// AppViewModel.swift
import Foundation

class AppViewModel: ObservableObject {
    @Published var problems: [Problem] = []
    @Published var completedProblems: [Problem] = []
    @Published var userELO: Int = 1000

    init() {
        loadProblems()
    }

    func loadProblems() {
        problems = [
            Problem(
                title: "Two Sum",
                description: """
                Given an array of integers `nums` and an integer `target`, return indices of the two numbers such that they add up to target.
                """,
                difficulty: "Easy",
                functionBody: "def twoSum(lst: [int])\n    # Write your function here\n    return []\n}",
                testCases: [
                    TestCase(input: "2,7,11,15;9", expectedOutput: "[0, 1]"),
                    TestCase(input: "3,2,4;6", expectedOutput: "[1, 2]"),
                    TestCase(input: "3,3;6", expectedOutput: "[0, 1]")
                ]
            )
        ]
    }

    func getRandomProblem(difficulty: String) -> Problem? {
        let filtered = problems.filter { $0.difficulty == difficulty }
        return filtered.randomElement()
    }
}
