import SwiftUI

struct SoldierAttackView: View {
    let start: CGPoint
    let end: CGPoint
    let pieceColor: PieceColor
    @State private var progress: CGFloat = 0
    @State private var showSlash = false
    
    private func attackPoint(_ t: CGFloat) -> CGPoint {
        let x = start.x + (end.x - start.x) * t
        let y = start.y + (end.y - start.y) * t
        return CGPoint(x: x, y: y)
    }
    
    private func calculateRotation() -> Double {
        let direction: Double = end.x > start.x ? 1 : -1
        return progress * 20.0 * direction
    }
    
    var body: some View {
        let currentPoint = attackPoint(progress)
        let angle = atan2(end.y - start.y, end.x - start.x)
        
        ZStack {
            // Slash effect
            if showSlash {
                Path { path in
                    path.move(to: CGPoint(x: -20, y: 0))
                    path.addQuadCurve(
                        to: CGPoint(x: 20, y: 0),
                        control: CGPoint(x: 0, y: -30)
                    )
                }
                .stroke(Color.white, lineWidth: 3)
                .shadow(color: .red, radius: 3)
                .frame(width: 40, height: 30)
                .position(end)
                .rotationEffect(.radians(angle))
                .opacity((1 - progress) * 0.8)
            }
            
            // Soldier piece
            Text(pieceColor == .red ? "兵" : "卒")
                .modifier(PieceFontModifier())
                .foregroundColor(pieceColor == .red ? .red : .black)
                .position(currentPoint)
                .rotationEffect(.degrees(calculateRotation())) // Using helper function
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.2)) {
                progress = 0.8
                showSlash = true
            }
            withAnimation(.easeOut(duration: 0.1).delay(0.2)) {
                progress = 1
            }
        }
    }
}

struct PieceFontModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 24, weight: .bold))
    }
} 