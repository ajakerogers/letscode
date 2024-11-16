import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var username: String = "Guest"
    @Published var elo: Int = 1000

    private let db = DatabaseManager.shared
    private let defaultUsername = "Jake" // Replace with your desired default username

    func loadUserData() {
        // Fetch user data from the database
        if let eloValue = db.getUserELO(username: defaultUsername) {
            self.username = defaultUsername
            self.elo = eloValue
        } else {
            print("Failed to load user data")
        }
    }

    func resetELO() {
        // Reset ELO to default value
        db.updateUserELO(username: defaultUsername, newELO: 1000)
        self.elo = 1000
    }
}
