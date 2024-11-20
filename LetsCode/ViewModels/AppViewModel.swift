import Foundation

class AppViewModel: ObservableObject {
    @Published var problems: [Problem] = []
    @Published var completedProblems: [Problem] = []
    @Published var userELO: Int = 1000
    private let db = DatabaseManager.shared
    private let username = "Jake"  // Temporary username for demo
    private let eloService = ELOCalculationService()

    init() {
        userELO = db.getUserELO(username: username) ?? 1000
        loadProblems()
    }

    func loadProblems() {
        problems = db.getSolvedProblems()
    }

    func getRandomProblem(difficulty: String) -> Problem? {
        return db.getUnsolvedProblem(targetDifficulty: difficulty)
    }

    // Update ELO based on success or failure
    func updateELO(success: Bool, problemDifficulty: String) {
        let eloChange = eloService.calculateELOChange(userELO: userELO, success: success, problemDifficulty: problemDifficulty)
        userELO += eloChange
        db.updateUserELO(username: username, newELO: userELO)
    }

    // Handle successful problem solving
    func handleSuccess(problem: Problem) {
        updateELO(success: true, problemDifficulty: problem.difficulty)
    }

    // Handle failed problem solving
    func handleFailure(problem: Problem) {
        updateELO(success: false, problemDifficulty: problem.difficulty)
    }
}
