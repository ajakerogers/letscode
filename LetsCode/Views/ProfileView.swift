import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var profileViewModel: ProfileViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Profile")
                .font(.largeTitle)
                .bold()

            Text("Username: \(profileViewModel.username)")
            Text("ELO: \(profileViewModel.elo)")

            Button(action: {
                profileViewModel.resetELO()
            }) {
                Text("Reset ELO")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .onAppear {
            profileViewModel.loadUserData()
        }
    }
}
