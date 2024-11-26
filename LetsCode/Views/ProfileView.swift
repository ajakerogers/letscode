import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var profileViewModel: ProfileViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text(profileViewModel.username)
                .font(.largeTitle)
                .bold()
            Text("ELO: \(profileViewModel.elo)")
                .font(.headline)

            if profileViewModel.solvedProblems.isEmpty {
                Text("No solved problems yet.")
                    .foregroundColor(.secondary)
            } else {
                List(profileViewModel.solvedProblems) { problem in
                    HStack {
                        let eloChange = problem.eloChange ?? 0
                        // Solved Status Icon
                        Image(systemName: problem.solved ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(problem.solved ? .green : .red)
                        // Problem Title (Truncated if too long)
                        Text(truncate(text: problem.title, length: 20))
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        // Difficulty
                        Text(problem.difficulty)
                            .foregroundColor(difficultyColor(problem.difficulty))
                            .padding(.horizontal, 8)
                            .padding(4)
                            .background(difficultyColor(problem.difficulty).opacity(0.2))
                            .cornerRadius(4)

                        // ELO Change (Assuming +20 for solved)
                        Text(eloChange >= 0 ? "+\(eloChange)" : "\(eloChange)")
                            .foregroundColor(problem.solved ? .green : .red)
                            .padding(.horizontal, 8)
                            .padding(4)
                            .background(problem.solved ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .padding()
        .onAppear {
            profileViewModel.loadUserData()
        }
    }

    // Helper Method: Truncate Text
    private func truncate(text: String, length: Int) -> String {
        if text.count > length {
            let index = text.index(text.startIndex, offsetBy: length)
            return String(text[..<index]) + "..."
        } else {
            return text
        }
    }

    // Helper Method: Determine Color Based on Difficulty
    private func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "Easy":
            return .green
        case "Medium":
            return .orange
        case "Hard":
            return .red
        default:
            return .gray
        }
    }
}
