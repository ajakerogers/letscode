import SQLite
import Foundation

// Define a type alias to resolve the conflict
typealias SQLiteExpression = SQLite.Expression

class DatabaseManager {
    static let shared = DatabaseManager()

    private var db: Connection?

    // Table definitions
    private let users = Table("users")
    private let problems = Table("problems")
    private let testCases = Table("test_cases")

    // User Table Columns
    private let userId = SQLiteExpression<Int>("id")
    private let username = SQLiteExpression<String>("username")
    private let elo = SQLiteExpression<Int>("elo")

    // Problem Table Columns
    private let problemId = SQLiteExpression<Int>("id") // Changed to Int for auto-increment
    private let title = SQLiteExpression<String>("title")
    private let description = SQLiteExpression<String>("description")
    private let difficulty = SQLiteExpression<String>("difficulty")
    private let functionBody = SQLiteExpression<String>("functionBody")
    private let solved = SQLiteExpression<Bool>("solved")
    private let solution = SQLiteExpression<String?>("solution")
    private let attempts = SQLiteExpression<Int>("attempts")

    // TestCase Table Columns
    private let testCaseId = SQLiteExpression<Int>("id") // Changed to Int for auto-increment
    private let problemIdFK = SQLiteExpression<Int>("problemId") // Updated to match problemId
    private let input = SQLiteExpression<String>("input")
    private let functionCall = SQLiteExpression<String>("functionCall")
    private let expectedOutput = SQLiteExpression<String>("expectedOutput")
    private let actualOutput = SQLiteExpression<String?>("actualOutput")
    private let passed = SQLiteExpression<Bool>("passed")
    private let consoleOutput = SQLiteExpression<String>("consoleOutput")

    private init() {
        // Initialize the SQLite database
        do {
            let documentDirectory = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )
            let dbPath = documentDirectory.appendingPathComponent("letscode.sqlite3").path
            db = try Connection(dbPath)
            createTables()
            initializeDatabase()
            ensureDefaultUserExists()
        } catch {
            print("Failed to initialize database: \(error)")
        }
    }
    
    func deleteDatabase() {
        do {
            let documentDirectory = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )
            let dbPath = documentDirectory.appendingPathComponent("letscode.sqlite3").path
            if FileManager.default.fileExists(atPath: dbPath) {
                try FileManager.default.removeItem(atPath: dbPath)
                print("Database deleted successfully.")
            } else {
                print("Database file does not exist.")
            }
        } catch {
            print("Failed to delete database: \(error)")
        }
    }

    // Create Tables
    private func createTables() {
        do {
            // User Table
            try db?.run(users.create(ifNotExists: true) { table in
                table.column(userId, primaryKey: .autoincrement)
                table.column(username, unique: true)
                table.column(elo, defaultValue: 1000)
            })

            // Problem Table
            try db?.run(problems.create(ifNotExists: true) { table in
                table.column(problemId, primaryKey: .autoincrement)
                table.column(title)
                table.column(description)
                table.column(difficulty)
                table.column(functionBody)
                table.column(solved, defaultValue: false)
                table.column(solution)
                table.column(attempts, defaultValue: 0)
            })

            // TestCase Table
            try db?.run(testCases.create(ifNotExists: true) { table in
                table.column(testCaseId, primaryKey: .autoincrement)
                table.column(problemIdFK)
                table.column(input)
                table.column(functionCall)
                table.column(expectedOutput)
                table.column(actualOutput, defaultValue: "")
                table.column(consoleOutput, defaultValue: "")
                table.column(passed, defaultValue: false)
                table.foreignKey(problemIdFK, references: problems, problemId, update: .cascade, delete: .cascade)
            })
        } catch {
            print("Failed to create tables: \(error)")
        }
    }

    private func bulkInsertProblems(_ incomingProblems: [Problem]) {
        guard let db = db else { return }
        do {
            try db.transaction {
                for problem in incomingProblems {
                    // Insert Problem without specifying the ID
                    try db.run(problems.insert(
                        title <- problem.title,
                        description <- problem.description,
                        difficulty <- problem.difficulty,
                        functionBody <- problem.functionBody,
                        solved <- problem.solved,
                        solution <- problem.solution,
                        attempts <- problem.attempts
                    ))

                    // Retrieve the last inserted ID
                    let newProblemId = db.lastInsertRowid

                    // Insert Test Cases linked to the new problem ID
                    for testCase in problem.testCases {
                        try db.run(testCases.insert(
                            problemIdFK <- Int(newProblemId),
                            input <- testCase.input,
                            functionCall <- testCase.functionCall,
                            expectedOutput <- testCase.expectedOutput,
                            actualOutput <- testCase.actualOutput ?? "",
                            consoleOutput <- testCase.consoleOutput,
                            passed <- testCase.passed
                        ))
                    }
                }
            }
            print("Successfully inserted \(incomingProblems.count) problems with their test cases.")
        } catch {
            print("Failed to bulk insert problems: \(error)")
        }
    }

    // Updated Initialize Database
    private func initializeDatabase() {
        do {
            // Check if there are already problems in the database
            let problemCount = try db?.scalar(problems.count) ?? 0
            if problemCount >= 1 {
                print("Database already contains \(problemCount) problems. Skipping initialization.")
                return
            }

            // Load problems from JSON
            if let url = Bundle.main.url(forResource: "problems", withExtension: "json") {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let decodedProblems = try decoder.decode([Problem].self, from: data)
                bulkInsertProblems(decodedProblems)
            } else {
                print("JSON file not found in the bundle.")
            }

            print("Database initialized with predefined problems.")
        } catch {
            print("Error initializing database: \(error)")
        }
    }

    // User Management
    func createUser(username: String) {
        do {
            try db?.run(users.insert(self.username <- username, elo <- 1000))
            print("User '\(username)' created with ELO 1000.")
        } catch {
            print("Failed to create user: \(error)")
        }
    }

    func getUserELO(username: String) -> Int? {
        do {
            if let user = try db?.pluck(users.filter(self.username == username)) {
                return user[elo]
            }
        } catch {
            print("Failed to fetch ELO: \(error)")
        }
        return nil
    }

    func updateUserELO(username: String, newELO: Int) {
        let user = users.filter(self.username == username)
        do {
            try db?.run(user.update(elo <- newELO))
            print("User '\(username)' ELO updated to \(newELO).")
        } catch {
            print("Failed to update ELO: \(error)")
        }
    }
    
    enum DatabaseError: Error {
        case problemInsertionFailed
    }

    // Update Methods to Use Integer IDs
    func addProblem(problem: Problem) {
        do {
            // Insert the problem and get the auto-incremented ID
            try db?.transaction {
                let problemId = try db?.run(problems.insert(
                    title <- problem.title,
                    description <- problem.description,
                    difficulty <- problem.difficulty,
                    functionBody <- problem.functionBody,
                    solved <- false,
                    solution <- nil,
                    attempts <- 0
                ))

                guard let newProblemId = db?.lastInsertRowid else {
                    throw DatabaseError.problemInsertionFailed
                }

                print("Problem added with ID: \(newProblemId)")

                // Insert test cases linked to the new problem ID
                for testCase in problem.testCases {
                    try db?.run(testCases.insert(
                        problemIdFK <- Int(newProblemId), // Use the retrieved problem ID
                        input <- testCase.input,
                        functionCall <- testCase.functionCall,
                        expectedOutput <- testCase.expectedOutput,
                        actualOutput <- testCase.actualOutput ?? "",
                        consoleOutput <- testCase.consoleOutput,
                        passed <- testCase.passed
                    ))
                }
            }
        } catch {
            print("Failed to add problem and test cases: \(error)")
        }
    }

    func markProblemAsSolved(problemId: Int, solution: String) {
        let problem = problems.filter(self.problemId == problemId)
        do {
            try db?.run(problem.update(solved <- true, self.solution <- solution))
            print("Problem with ID \(problemId) marked as solved.")
        } catch {
            print("Failed to mark problem as solved: \(error)")
        }
    }

    func incrementProblemAttempts(problemId: Int) {
        let problem = problems.filter(self.problemId == problemId)
        do {
            let update = problem.update(attempts <- attempts + 1)
            if try db?.run(update) ?? 0 > 0 {
                print("Incremented attempts for problem ID \(problemId).")
            }
        } catch {
            print("Failed to increment attempts: \(error)")
        }
    }

    func getAttemptsForProblem(problemId: Int) -> Int {
        let problem = problems.filter(self.problemId == problemId)
        do {
            if let problem = try db?.pluck(problem) {
                return problem[attempts]
            }
        } catch {
            print("Failed to fetch attempts: \(error)")
        }
        return 0
    }

    func getUnsolvedProblem(targetDifficulty: String) -> Problem? {
        do {
            if let problemRow = try db?.pluck(problems.filter(difficulty == targetDifficulty && solved == false)) {
                let associatedTestCases = try fetchTestCases(for: problemRow[problemId])
                return Problem(
                    id: problemRow[problemId],
                    title: problemRow[title],
                    description: problemRow[description],
                    difficulty: problemRow[difficulty],
                    functionBody: problemRow[functionBody],
                    solved: problemRow[solved],
                    solution: problemRow[solution],
                    attempts: problemRow[attempts],
                    testCases: associatedTestCases
                )
            }
        } catch {
            print("Failed to fetch unsolved problem: \(error)")
        }
        return nil
    }

    // Fetch User's Solved Problems Ordered by Most Recent
    func getSolvedProblems() -> [Problem] {
        var solvedProblems = [Problem]()
        do {
            // Assuming higher attempts indicate more recent solves; ideally, include a 'solvedAt' timestamp
            for row in try db!.prepare(problems.filter(solved == true).order(attempts.desc)) {
                let associatedTestCases = try fetchTestCases(for: row[problemId])
                
                let problem = Problem(
                    id: row[problemId],
                    title: row[title],
                    description: row[description],
                    difficulty: row[difficulty],
                    functionBody: row[functionBody],
                    solved: row[solved],
                    solution: row[solution],
                    attempts: row[attempts],
                    testCases: associatedTestCases
                )
                solvedProblems.append(problem)
            }
        } catch {
            print("Failed to fetch solved problems: \(error)")
        }
        return solvedProblems
    }

    // Helper Method to Fetch Test Cases for a Given Problem ID
    private func fetchTestCases(for problemIdValue: Int) throws -> [TestCase] {
        var testCasesList = [TestCase]()
        let query = testCases.filter(problemIdFK == problemIdValue)
        for testCaseRow in try db!.prepare(query) {
            let testCase = TestCase(
                id: testCaseRow[testCaseId],
                input: testCaseRow[input],
                expectedOutput: testCaseRow[expectedOutput],
                actualOutput: testCaseRow[actualOutput],
                functionCall: testCaseRow[functionCall],
                consoleOutput: testCaseRow[consoleOutput],
                passed: testCaseRow[passed]
            )
            testCasesList.append(testCase)
        }
        return testCasesList
    }
    
    private func ensureDefaultUserExists() {
        let existingUser = users.filter(username == "Jake")
        do {
            if try db?.pluck(existingUser) == nil {
                createUser(username: "Jake")
                print("Default user 'Jake' created.")
            } else {
                print("Default user 'Jake' already exists.")
            }
        } catch {
            print("Failed to check or create default user: \(error)")
        }
    }
}
