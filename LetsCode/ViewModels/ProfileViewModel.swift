import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var username: String = "Guest"
    @Published var elo: Int = 500
    @Published var solvedProblems: [Problem] = []

    private let db = DatabaseManager.shared
    private let defaultUsername = "ProCoder123"

    func loadUserData() {
        // Fetch user data from the database
        if let eloValue = db.getUserELO(username: defaultUsername) {
            self.username = defaultUsername
            self.elo = eloValue
        } else {
            print("Failed to load user data")
        }

        // Fetch solved problems
        self.solvedProblems = db.getSolvedProblems()
    }
}
