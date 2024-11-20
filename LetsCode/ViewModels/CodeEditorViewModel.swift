// CodeEditorViewModel.swift
import Foundation

class CodeEditorViewModel: ObservableObject {
    @Published var code: String = ""
    @Published var isLoading: Bool = false
    @Published var testCases: [TestCase] = []
    @Published var consoleOutput: String = ""
    @Published var executionTime: TimeInterval = 0.0
    @Published var showEloAlert: Bool = false
    @Published var eloAlertMessage: String = ""

    private let codeExecutionService = CodeExecutionService()
    private let db = DatabaseManager.shared
    private let username = "Jake" // Temporary username for demo
    private let eloService = ELOCalculationService()

    func runCode(problem: Problem) {
        guard !code.isEmpty else { return }
        isLoading = true
        self.testCases = problem.testCases

        codeExecutionService.executeCode(code, testCases: problem.testCases) { [weak self] response in
            guard let self = self else { return }
            
            // Update test cases based on execution results
            self.testCases = response.testCaseResults.map { testCase in
                var updatedTestCase = testCase
                if let actualOutput = testCase.actualOutput {
                    updatedTestCase.passed = actualOutput.trimmingCharacters(in: .whitespacesAndNewlines) == testCase.expectedOutput.trimmingCharacters(in: .whitespacesAndNewlines)
                } else {
                    updatedTestCase.passed = false
                }
                return updatedTestCase
            }

            self.executionTime = response.executionTime
            self.isLoading = false

            // Determine if all test cases passed
            let allPassed = self.testCases.allSatisfy { $0.passed }

            if allPassed {
                // Mark problem as solved
                self.db.markProblemAsCompleted(problemId: problem.id!, solution: self.code, correct: true)
                // Update ELO for success
                let eloChange = self.eloService.calculateELOChange(userELO: self.db.getUserELO(username: self.username) ?? 1000, success: true, problemDifficulty: problem.difficulty)
                self.db.updateUserELO(username: self.username, newELO: (self.db.getUserELO(username: self.username) ?? 1000) + eloChange)
                // Optionally, notify the user of ELO gain
            } else {
                // Increment attempt count
                self.db.incrementProblemAttempts(problemId: problem.id!)
                // Get current attempt count
                let attempts = self.db.getAttemptsForProblem(problemId: problem.id!)
                
                self.db.markProblemAsCompleted(problemId: problem.id!, solution: self.code, correct: true)
                
                print("attempts: ")
                print(attempts)
                if attempts == 5 {
                    // Calculate ELO deduction
                    let eloChange = self.eloService.calculateELOChange(userELO: self.db.getUserELO(username: self.username) ?? 1000, success: false, problemDifficulty: problem.difficulty)
                    // Update ELO
                    self.db.updateUserELO(username: self.username, newELO: (self.db.getUserELO(username: self.username) ?? 1000) + eloChange)
                    // Set alert message
                    self.eloAlertMessage = "You've reached the maximum attempts for this problem. You lost \(abs(eloChange)) ELO points."
                    self.showEloAlert = true
                } else {
                    // Optionally, notify the user of failed attempt
                }
            }
        }
    }
}
