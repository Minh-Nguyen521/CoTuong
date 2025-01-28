import SwiftUI

struct AdvisorAttackView: View {
    let start: CGPoint
    let end: CGPoint
    let pieceColor: PieceColor
    @State private var progress: CGFloat = 0
    @State private var rotations = 0.0
    
    private func attackPoint(_ t: CGFloat) -> CGPoint {
        let x = start.x + (end.x - start.x) * t
        let y = start.y + (end.y - start.y) * t
        return CGPoint(x: x, y: y)
    }
    
    var body: some View {
        let currentPoint = attackPoint(progress)
        
        ZStack {
            // Spinning blades effect
            ForEach(0..<4) { i in
                Path { path in
                    path.move(to: CGPoint(x: -15, y: 0))
                    path.addLine(to: CGPoint(x: 15, y: 0))
                }
                .stroke(pieceColor == .red ? Color.red : Color.black, lineWidth: 3)
                .position(currentPoint)
                .rotationEffect(.degrees(Double(i) * 90 + rotations))
                .opacity((1 - progress) * 0.7)
            }
            
            // Advisor piece
            Circle()
                .fill(pieceColor == .red ? Color.red : Color.black)
                .frame(width: 30, height: 30)
                .position(currentPoint)
        }
        .onAppear {
            withAnimation(.linear(duration: 0.3)) {
                progress = 1
                rotations = 360
            }
        }
    }
} 