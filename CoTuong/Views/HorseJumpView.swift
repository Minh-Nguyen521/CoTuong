import SwiftUI

struct HorseJumpView: View {
    let start: CGPoint
    let end: CGPoint
    @State private var progress: CGFloat = 0
    let pieceColor: PieceColor
    
    private func jumpCurvePoint(_ t: CGFloat) -> CGPoint {
        let midX = start.x + (end.x - start.x) * t
        let baseY = start.y + (end.y - start.y) * t
        
        // Create a steeper, more direct jump
        let jumpHeight: CGFloat = 30
        let jumpOffset = -jumpHeight * 2 * t * (t - 1)  // Sharper parabolic curve
        
        return CGPoint(x: midX, y: baseY + jumpOffset)
    }
    
    var body: some View {
        let jumpPoint = jumpCurvePoint(progress)
        
        ZStack {
            // Horse piece shadow
            Ellipse()
                .fill(Color.black.opacity(0.2))
                .frame(width: 30, height: 8)
                .position(x: jumpPoint.x, y: end.y)
                .scaleEffect(x: 1 + progress * 0.3, y: 1)
                .opacity((1 - progress) * 0.4)
            
            // Horse piece
            Text("馬")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(pieceColor == .red ? .red : .black)
                .position(jumpPoint)
                .rotationEffect(.degrees(progress * 180)) // Half rotation only
                .scaleEffect(1 + progress * 0.2) // Slight scale up during jump
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                progress = 1
            }
        }
    }
} 