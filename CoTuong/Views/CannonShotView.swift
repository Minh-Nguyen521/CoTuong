import SwiftUI

struct CannonShotView: View {
    let start: CGPoint
    let end: CGPoint
    @State private var progress: CGFloat = 0
    @State private var showSmoke = false
    
    var body: some View {
        ZStack {
            // Smoke effect at the start position
            if showSmoke {
                Circle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 20, height: 20)
                    .position(start)
                    .scaleEffect(progress)
                    .opacity(1 - progress)
            }
            
            // Cannon ball
            Circle()
                .fill(Color.black)
                .frame(width: 12, height: 12)
                .position(
                    x: start.x + (end.x - start.x) * progress,
                    y: start.y + (end.y - start.y) * progress
                )
                .opacity(progress < 1 ? 1 : 0)
        }
        .onAppear {
            showSmoke = true
            withAnimation(.easeOut(duration: 0.3)) {
                progress = 1
            }
        }
    }
} 