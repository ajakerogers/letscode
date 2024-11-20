import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var profileViewModel: ProfileViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Profile")
                .font(.largeTitle)
                .bold()

            Text("Username: \(profileViewModel.username)")
                .font(.headline)
            Text("ELO: \(profileViewModel.elo)")
                .font(.headline)

            if profileViewModel.solvedProblems.isEmpty {
                Text("No solved problems yet.")
                    .foregroundColor(.secondary)
            } else {
                List(profileViewModel.solvedProblems) { problem in
                    HStack {
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
                        Text("+20")
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(4)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(4)

                        // Solved Status Icon
                        Image(systemName: problem.solved ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(problem.solved ? .green : .red)
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
