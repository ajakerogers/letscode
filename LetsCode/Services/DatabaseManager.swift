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
    private let problemId = SQLiteExpression<String>("id")
    private let title = SQLiteExpression<String>("title")
    private let description = SQLiteExpression<String>("description")
    private let difficulty = SQLiteExpression<String>("difficulty")
    private let functionBody = SQLiteExpression<String>("functionBody")
    private let solved = SQLiteExpression<Bool>("solved")
    private let solution = SQLiteExpression<String?>("solution")
    private let attempts = SQLiteExpression<Int>("attempts")

    // TestCase Table Columns
    private let testCaseId = SQLiteExpression<String>("id")
    private let problemIdFK = SQLiteExpression<String>("problemId")
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
            initializeDatabase()  // Initialize the database with predefined problems
        } catch {
            print("Failed to initialize database: \(error)")
        }
    }

    // Create Tables
    private func createTables() {
        do {
            // User Table
            try db?.run(users.create(ifNotExists: true) { table in
                table.column(userId, primaryKey: true)
                table.column(username, unique: true)
                table.column(elo, defaultValue: 1000)
            })

            // Problem Table
            try db?.run(problems.create(ifNotExists: true) { table in
                table.column(problemId, primaryKey: true)
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
                table.column(testCaseId, primaryKey: true)
                table.column(problemIdFK)
                table.column(input)
                table.column(expectedOutput)
                table.column(functionCall)
                table.column(actualOutput)
                table.column(consoleOutput)
                table.column(passed, defaultValue: false)
                table.foreignKey(problemIdFK, references: problems, problemId)
            })
        } catch {
            print("Failed to create tables: \(error)")
        }
    }
    
    // Initialize Database with Predefined Problems
    private func bulkInsertProblems(_ incomingProblems: [Problem]) {
        guard let db = db else { return }
        do {
            try db.transaction {
                for problem in incomingProblems {
                    // Insert Problem
                    try db.run(problems.insert(
                        problemId <- problem.id,
                        title <- problem.title,
                        description <- problem.description,
                        difficulty <- problem.difficulty,
                        functionBody <- problem.functionBody,
                        solved <- false,
                        solution <- nil,
                        attempts <- 0
                    ))

                    // Insert Test Cases
                    for testCase in problem.testCases {
                        try db.run(testCases.insert(
                            testCaseId <- testCase.id,
                            problemIdFK <- problem.id,
                            input <- testCase.input,
                            functionCall <- testCase.functionCall,
                            expectedOutput <- testCase.expectedOutput,
                            consoleOutput <- "",
                            actualOutput <- nil,
                            passed <- false
                        ))
                    }
                }
            }
            print("Successfully inserted \(problems.count) problems with their test cases.")
        } catch {
            print("Failed to bulk insert problems: \(error)")
        }
    }

    // Updated Initialize Database
    private func initializeDatabase() {
        do {
            // Check if there are already problems in the database
            let problemCount = try db?.scalar(problems.count) ?? 0
            if problemCount >= 300 {
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
                print("Json not found")
            }

            print("Database initialized with predefined problems.")
        } catch {
            print("Error initializing database: \(error)")
        }
    }
    
//    func deleteDatabase() {
//        do {
//            let documentDirectory = try FileManager.default.url(
//                for: .documentDirectory,
//                in: .userDomainMask,
//                appropriateFor: nil,
//                create: false
//            )
//            let dbPath = documentDirectory.appendingPathComponent("letscode.sqlite3").path
//            try FileManager.default.removeItem(atPath: dbPath)
//            print("Database file deleted successfully.")
//        } catch {
//            print("Failed to delete database file: \(error)")
//        }
//    }

    // User Management
    func createUser(username: String) {
        do {
            try db?.run(users.insert(self.username <- username, elo <- 1000))
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
        } catch {
            print("Failed to update ELO: \(error)")
        }
    }

    // Problem Management
    func addProblem(problem: Problem) {
        do {
            try db?.run(problems.insert(
                problemId <- problem.id,
                title <- problem.title,
                description <- problem.description,
                difficulty <- problem.difficulty,
                functionBody <- problem.functionBody,
                solved <- false,
                solution <- nil,
                attempts <- 0
            ))
        } catch {
            print("Failed to add problem: \(error)")
        }
    }

    func markProblemAsSolved(problemId: UUID, solution: String) {
        let problem = problems.filter(self.problemId == problemId.uuidString)
        do {
            try db?.run(problem.update(solved <- true, self.solution <- solution))
        } catch {
            print("Failed to mark problem as solved: \(error)")
        }
    }

    func incrementProblemAttempts(problemId: UUID) {
        let problem = problems.filter(self.problemId == problemId.uuidString)
        do {
            try db?.run(problem.update(attempts += 1))
        } catch {
            print("Failed to increment attempts: \(error)")
        }
    }

    // Fetch Problems
    func getUnsolvedProblem(targetDifficulty: String) -> Problem? {
        do {
            // Query for the first unsolved problem with the specified difficulty
            if let problemRow = try db?.pluck(problems.filter(difficulty == targetDifficulty && solved == false)) {
                
                // Fetch associated test cases for the problem
                let associatedTestCases = try fetchTestCases(for: problemRow[problemId])
                
                // Create and return the Problem object with populated testCases
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

    // Fetch User's Attempted Problems
    func getAttemptedProblems() -> [Problem] {
        var problemList = [Problem]()
        do {
            for row in try db!.prepare(problems.filter(attempts > 0)) {
                let problem = Problem(
                    id: row[problemId],
                    title: row[title],
                    description: row[description],
                    difficulty: row[difficulty],
                    functionBody: row[functionBody],
                    solved: row[solved],
                    solution: row[solution],
                    attempts: row[attempts],
                    testCases: []
                )
                problemList.append(problem)
            }
        } catch {
            print("Failed to fetch attempted problems: \(error)")
        }
        return problemList
    }
    
    // Helper Method to Fetch Test Cases for a Given Problem ID
    private func fetchTestCases(for problemIdValue: String) throws -> [TestCase] {
        var testCasesList = [TestCase]()
        
        // Define the query to filter test cases by problemIdFK
        let query = testCases.filter(problemIdFK == problemIdValue)
        
        // Iterate through the filtered test cases
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
}
