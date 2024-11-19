import Foundation

class ELOCalculationService {
    // Base ELO values for different problem difficulties
    private let difficultyELO: [String: Int] = [
        "Easy": 500,
        "Medium": 1000,
        "Hard": 1500
    ]
    
    // Base K-factor
    private let baseKFactor: Double = 30.0
    
    /// Calculates the ELO change based on user's current ELO and problem difficulty
    /// - Parameters:
    ///   - userELO: The current ELO rating of the user
    ///   - success: Whether the user successfully solved the problem
    ///   - problemDifficulty: The difficulty level of the problem ("Easy", "Medium", "Hard")
    /// - Returns: The ELO change (positive for gain, negative for loss)
    func calculateELOChange(userELO: Int, success: Bool, problemDifficulty: String) -> Int {
        // Retrieve the problem's ELO based on difficulty
        guard let problemElo = difficultyELO[problemDifficulty] else {
            // Default to "Easy" if difficulty is unrecognized
            return calculateChange(userELO: userELO, problemELO: 500, success: success)
        }
        
        return calculateChange(userELO: userELO, problemELO: problemElo, success: success)
    }
    
    /// Helper method to calculate ELO change using the standard ELO formula with separate K-factors
    private func calculateChange(userELO: Int, problemELO: Int, success: Bool) -> Int {
        // Calculate the expected score
        let expectedScore = 1.0 / (1.0 + pow(10.0, Double(problemELO - userELO) / 400.0))
        
        // Determine the actual score based on success
        let actualScore: Double = success ? 1.0 : 0.0
        
        // Adjust K-factor based on problem difficulty and success/failure
        let kFactor = determineKFactor(problemELO: problemELO, success: success)
        
        // Calculate the ELO change
        let eloChange = Double(kFactor) * (actualScore - expectedScore)
        
        // Round the ELO change to the nearest integer
        return Int(round(eloChange))
    }
    
    /// Determines the K-factor based on problem difficulty and whether it's a success or failure
    private func determineKFactor(problemELO: Int, success: Bool) -> Double {
        switch problemELO {
        case 1500: // Hard
            return success ? baseKFactor * 1.5 : baseKFactor * 0.5
        case 1000: // Medium
            return success ? baseKFactor : baseKFactor * 1.0
        case 500: // Easy
            return success ? baseKFactor * 0.5 : baseKFactor * 1.5
        default:
            return success ? baseKFactor : baseKFactor
        }
    }
}
