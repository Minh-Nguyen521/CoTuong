import SwiftUI

struct BoardGrid: View {
    var body: some View {
        GeometryReader { geometry in
            let cellWidth = geometry.size.width / 9
            let cellHeight = geometry.size.height / 10
            let offsetX = cellWidth / 2
            let offsetY = cellHeight / 2
            
            Path { path in
                // Vertical lines
                for i in 0...8 {
                    let x = cellWidth * CGFloat(i) + offsetX
                    // Top half
                    path.move(to: CGPoint(x: x, y: offsetY))
                    path.addLine(to: CGPoint(x: x, y: cellHeight * 4 + offsetY))
                    // Bottom half
                    path.move(to: CGPoint(x: x, y: cellHeight * 5 + offsetY))
                    path.addLine(to: CGPoint(x: x, y: cellHeight * 9 + offsetY))
                }
                
                // Horizontal lines
                for i in 0...8 {
                    let y = cellHeight * CGFloat(i) + offsetY
                    path.move(to: CGPoint(x: offsetX, y: y))
                    path.addLine(to: CGPoint(x: cellWidth * 8 + offsetX, y: y))
                }
                
                // Palace diagonals
                // Black palace (top)
                path.move(to: CGPoint(x: 3 * cellWidth + offsetX, y: offsetY))
                path.addLine(to: CGPoint(x: 5 * cellWidth + offsetX, y: 2 * cellHeight + offsetY))
                path.move(to: CGPoint(x: 5 * cellWidth + offsetX, y: offsetY))
                path.addLine(to: CGPoint(x: 3 * cellWidth + offsetX, y: 2 * cellHeight + offsetY))
                
                // Red palace (bottom)
                path.move(to: CGPoint(x: 3 * cellWidth + offsetX, y: 7 * cellHeight + offsetY))
                path.addLine(to: CGPoint(x: 5 * cellWidth + offsetX, y: 9 * cellHeight + offsetY))
                path.move(to: CGPoint(x: 5 * cellWidth + offsetX, y: 7 * cellHeight + offsetY))
                path.addLine(to: CGPoint(x: 3 * cellWidth + offsetX, y: 9 * cellHeight + offsetY))
            }
            .stroke(Color.black, lineWidth: 1)
            
            Text("楚 河")
                .font(.system(size: 24))
                .position(x: geometry.size.width * 0.25, y: geometry.size.height * 0.5)
            Text("漢 界")
                .font(.system(size: 24))
                .position(x: geometry.size.width * 0.75, y: geometry.size.height * 0.5)
        }
    }
} 