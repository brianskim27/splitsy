import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 32)
            Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            Text("Brian")
                .font(.title)
                    .bold()
            VStack(alignment: .leading, spacing: 16) {
                Text("History")
                    .font(.headline)
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .frame(height: 60)
                    .overlay(Text("No history yet.").foregroundColor(.gray))
                Text("Favorites")
                    .font(.headline)
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .frame(height: 60)
                    .overlay(Text("No favorites yet.").foregroundColor(.gray))
            }
            .padding(.horizontal)
            Spacer()
        }
    }
}
