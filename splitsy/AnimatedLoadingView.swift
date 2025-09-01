import SwiftUI

struct AnimatedLoadingView: View {
    @State private var showSlash = false
    @State private var slashOffset: CGFloat = -200
    @State private var topPieceOffset: CGSize = .zero
    @State private var bottomPieceOffset: CGSize = .zero
    @State private var showSplitsyText = false
    @State private var textScale: CGFloat = 0.5
    @State private var textOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Background
            Color.white.ignoresSafeArea()
            
            // Non-ripped receipt (initial state)
            if !showSlash {
                Image("app_logo_whole") // You'll need a non-ripped version
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .animation(.easeInOut(duration: 0.3), value: showSlash)
            }
            
            // Top piece of receipt (after slash)
            if showSlash {
                Image("app_logo_top") // Top half of your receipt
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 60)
                    .offset(topPieceOffset)
                    .animation(.easeInOut(duration: 0.8), value: topPieceOffset)
            }
            
            // Bottom piece of receipt (after slash)
            if showSlash {
                Image("app_logo_bottom") // Bottom half of your receipt
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 60)
                    .offset(bottomPieceOffset)
                    .animation(.easeInOut(duration: 0.8), value: bottomPieceOffset)
            }
            
            // Slash line
            Rectangle()
                .fill(Color.red)
                .frame(width: 3, height: 160)
                .rotationEffect(.degrees(45))
                .offset(x: slashOffset)
                .opacity(showSlash ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: slashOffset)
                .animation(.easeInOut(duration: 0.2), value: showSlash)
            
            // Splitsy text
            Text("Splitsy")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .scaleEffect(textScale)
                .opacity(textOpacity)
                .animation(.spring(response: 0.8, dampingFraction: 0.6), value: textScale)
                .animation(.easeInOut(duration: 0.5), value: textOpacity)
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Start slash animation after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            showSlash = true
            slashOffset = 0
        }
        
        // Start piece separation after slash completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            topPieceOffset = CGSize(width: 0, height: -300) // Fly up
            bottomPieceOffset = CGSize(width: 0, height: 300) // Fly down
        }
        
        // Reveal Splitsy text as pieces fly away
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            showSplitsyText = true
            textScale = 1.0
            textOpacity = 1.0
        }
    }
}

// Fallback version using your existing app_logo if you don't have separate pieces
struct AnimatedLoadingViewFallback: View {
    @State private var showSlash = false
    @State private var slashOffset: CGFloat = -200
    @State private var receiptOffset: CGSize = .zero
    @State private var receiptScale: CGFloat = 1.0
    @State private var showSplitsyText = false
    @State private var textScale: CGFloat = 0.5
    @State private var textOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Background
            Color.white.ignoresSafeArea()
            
            // Receipt (using your existing app_logo)
            Image("app_logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .offset(receiptOffset)
                .scaleEffect(receiptScale)
                .animation(.easeInOut(duration: 0.8), value: receiptOffset)
                .animation(.easeInOut(duration: 0.8), value: receiptScale)
            
            // Slash line
            Rectangle()
                .fill(Color.red)
                .frame(width: 3, height: 160)
                .rotationEffect(.degrees(45))
                .offset(x: slashOffset)
                .opacity(showSlash ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: slashOffset)
                .animation(.easeInOut(duration: 0.2), value: showSlash)
            
            // Splitsy text
            Text("Splitsy")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .scaleEffect(textScale)
                .opacity(textOpacity)
                .animation(.spring(response: 0.8, dampingFraction: 0.6), value: textScale)
                .animation(.easeInOut(duration: 0.5), value: textOpacity)
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Start slash animation after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            showSlash = true
            slashOffset = 0
        }
        
        // Start receipt movement after slash completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            receiptOffset = CGSize(width: 0, height: -400) // Fly up and away
            receiptScale = 0.3 // Shrink as it flies away
        }
        
        // Reveal Splitsy text as receipt flies away
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            showSplitsyText = true
            textScale = 1.0
            textOpacity = 1.0
        }
    }
}
