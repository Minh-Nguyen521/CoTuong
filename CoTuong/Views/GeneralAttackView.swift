import SwiftUI

struct GeneralAttackView: View {
    let start: CGPoint
    let end: CGPoint
    let pieceColor: PieceColor
    @State private var progress: CGFloat = 0
    @State private var showPower = false
    
    private func attackPoint(_ t: CGFloat) -> CGPoint {
        let x = start.x + (end.x - start.x) * t
        let y = start.y + (end.y - start.y) * t
        return CGPoint(x: x, y: y)
    }
    
    var body: some View {
        let currentPoint = attackPoint(progress)
        
        ZStack {
            // Power wave effect
            if showPower {
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(
                            pieceColor == .red ? Color.red : Color.black,
                            lineWidth: 3 - CGFloat(i)
                        )
                        .frame(width: 40 + CGFloat(i * 10))
                        .position(currentPoint)
                        .scaleEffect(1 + progress * 0.5)
                        .opacity((1 - progress) * 0.8)
                }
            }
            
            // General piece
            Circle()
                .fill(pieceColor == .red ? Color.red : Color.black)
                .frame(width: 35, height: 35)
                .position(currentPoint)
                .scaleEffect(1 + progress * 0.2)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.3)) {
                progress = 1
                showPower = true
            }
        }
    }
} 