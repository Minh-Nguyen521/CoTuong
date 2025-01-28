import SwiftUI

struct ElephantAttackView: View {
    let start: CGPoint
    let end: CGPoint
    let pieceColor: PieceColor
    @State private var progress: CGFloat = 0
    @State private var showImpact = false
    
    private func attackPoint(_ t: CGFloat) -> CGPoint {
        let midPoint = CGPoint(
            x: (start.x + end.x) / 2,
            y: (start.y + end.y) / 2 - 40 * (1 - 4 * (t - 0.5) * (t - 0.5))
        )
        return CGPoint(
            x: start.x + (end.x - start.x) * t,
            y: start.y + (midPoint.y - start.y) * (2 * min(t, 0.5)) +
               (end.y - midPoint.y) * (2 * max(t - 0.5, 0))
        )
    }
    
    var body: some View {
        let currentPoint = attackPoint(progress)
        
        ZStack {
            // Impact waves
            if showImpact {
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(pieceColor == .red ? Color.red : Color.black, lineWidth: 2)
                        .frame(width: CGFloat(i + 1) * 20)
                        .position(end)
                        .scaleEffect(progress)
                        .opacity((1 - progress) * 0.5)
                }
            }
            
            // Elephant piece
            Circle()
                .fill(pieceColor == .red ? Color.red : Color.black)
                .frame(width: 35, height: 35)
                .position(currentPoint)
                .scaleEffect(1 + (1 - progress) * 0.3)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.4)) {
                progress = 1
                showImpact = true
            }
        }
    }
} 