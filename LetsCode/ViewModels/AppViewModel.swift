import Foundation

class AppViewModel: ObservableObject {
    @Published var problems: [Problem] = []
    @Published var completedProblems: [Problem] = []
    @Published var userELO: Int = 1000
    private let db = DatabaseManager.shared
    private let username = "Jake"  // Temporary username for demo

    init() {
        userELO = db.getUserELO(username: username) ?? 1000
        loadProblems()
    }

    func loadProblems() {
        problems = db.getAttemptedProblems()
    }

    func getRandomProblem(difficulty: String) -> Problem? {
        return db.getUnsolvedProblem(targetDifficulty: difficulty)
    }

    func updateELO(success: Bool) {
        let change = success ? 20 : -10
        userELO += change
        db.updateUserELO(username: username, newELO: userELO)
    }
}
