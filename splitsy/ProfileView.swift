import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .padding()
                
                Text("John Doe")
                    .font(.title2)
                    .bold()
                
                List {
                    Section(header: Text("Account")) {
                        NavigationLink("Settings", destination: Text("Settings Page"))
                        NavigationLink("Favorites", destination: Text("Favorite Stores"))
                    }
                    
                    Section(header: Text("Support")) {
                        NavigationLink("Help Center", destination: Text("Help Page"))
                        NavigationLink("Privacy Policy", destination: Text("Privacy Page"))
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}
