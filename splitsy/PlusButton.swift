import SwiftUI

struct PlusButton: View {
    @Binding var isExpanded: Bool

    var body: some View {
        Button(action: {
            withAnimation {
                isExpanded.toggle()
            }
        }) {
            Image(systemName: isExpanded ? "xmark" : "plus")
                .resizable()
                .frame(width: 22, height: 22)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .clipShape(Circle())
                .shadow(radius: 5)
        }
    }
}
