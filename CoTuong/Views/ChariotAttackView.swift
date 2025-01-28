import SwiftUI

struct ChariotAttackView: View {
    let start: CGPoint
    let end: CGPoint
    let pieceColor: PieceColor
    @State private var progress: CGFloat = 0
    @State private var showTrail = false
    
    private func attackPoint(_ t: CGFloat) -> CGPoint {
        let x = start.x + (end.x - start.x) * t
        let y = start.y + (end.y - start.y) * t
        return CGPoint(x: x, y: y)
    }
    
    var body: some View {
        let currentPoint = attackPoint(progress)
        let angle = atan2(end.y - start.y, end.x - start.x)
        
        ZStack {
            // Speed trail effect
            if showTrail {
                ForEach(0..<5) { i in
                    Rectangle()
                        .fill(pieceColor == .red ? Color.red.opacity(0.2) : Color.black.opacity(0.2))
                        .frame(width: 30, height: 4)
                        .position(attackPoint(max(0, progress - 0.05 * Double(i + 1))))
                        .rotationEffect(.radians(angle))
                }
            }
            
            // Chariot piece
            Circle()
                .fill(pieceColor == .red ? Color.red : Color.black)
                .frame(width: 30, height: 30)
                .position(currentPoint)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                progress = 1
                showTrail = true
            }
        }
    }
} 