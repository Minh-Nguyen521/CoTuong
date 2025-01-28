import SwiftUI

struct PieceView: View {
    let piece: Piece
    let isSelected: Bool
    let isBeingCaptured: Bool
    @State private var isCaptured = false
    @State private var offset = CGSize.zero
    let cellWidth: CGFloat
    let cellHeight: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.95, green: 0.9, blue: 0.8))
                .frame(width: 38, height: 38)
                .overlay(
                    Circle()
                        .stroke(Color.black, lineWidth: 2)
                )
            
            Circle()
                .fill(Color(red: 0.95, green: 0.9, blue: 0.8))
                .frame(width: 34, height: 34)
                .overlay(
                    Circle()
                        .stroke(Color.black, lineWidth: 1)
                )
            
            Text(pieceSymbol(for: piece))
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(piece.color == .red ? .red : .black)
                .rotationEffect(piece.color == .black ? .degrees(180) : .degrees(0))
        }
        .background(
            Circle()
                .fill(isSelected ? Color.yellow.opacity(0.3) : Color.clear)
                .frame(width: 44, height: 44)
        )
        .offset(offset)
        .scaleEffect(isCaptured ? 0.5 : 1)
        .opacity(isCaptured ? 0 : 1)
        .animation(.easeInOut(duration: 0.3), value: isCaptured)
        .animation(.easeInOut(duration: 0.3), value: offset)
        .onChange(of: isBeingCaptured) { newValue in
            if newValue {
                isCaptured = true
            } else {
                isCaptured = false
            }
        }
        .onChange(of: piece.position) { _ in
            isCaptured = false
            offset = .zero
        }
    }
    
    private func pieceSymbol(for piece: Piece) -> String {
        switch piece.type {
        case .general: return piece.color == .red ? "帥" : "將"
        case .advisor: return piece.color == .red ? "仕" : "士"
        case .elephant: return piece.color == .red ? "相" : "象"
        case .horse: return "馬"
        case .chariot: return "車"
        case .cannon: return "砲"
        case .soldier: return piece.color == .red ? "兵" : "卒"
        }
    }
} 