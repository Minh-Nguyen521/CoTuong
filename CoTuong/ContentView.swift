//
//  ContentView.swift
//  CoTuong
//
//  Created by Minh on 26/1/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameBoard = GameBoard()
    @State private var selectedPiece: Piece?
    @State private var possibleMoves: [Position] = []
    
    var body: some View {
        VStack {
            Text("Chinese Chess - Cờ Tướng")
                .font(.title)
                .padding()
            
            Text("\(gameBoard.currentPlayer == .red ? "Red" : "Black")'s Turn")
                .font(.headline)
                .foregroundColor(gameBoard.currentPlayer == .red ? .red : .black)
                .padding(.bottom)
            
            if gameBoard.isCheck {
                Text(gameBoard.isCheckmate ? "Checkmate!" : "Check!")
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding(.bottom)
            }
            
            ZStack {
                Rectangle()
                    .fill(Color(red: 0.95, green: 0.85, blue: 0.67))
                    .overlay(
                        Rectangle()
                            .stroke(Color(red: 0.6, green: 0.3, blue: 0.1), lineWidth: 15)
                    )
                
                BoardGrid()
                
                // Possible moves indicators
                GeometryReader { geometry in
                    let cellWidth = geometry.size.width / 9
                    let cellHeight = geometry.size.height / 10
                    let offsetX = cellWidth / 2
                    let offsetY = cellHeight / 2
                    
                    ForEach(possibleMoves, id: \.self) { position in
                        let canCapture = gameBoard.pieceAt(position: position) != nil
                        Circle()
                            .fill(canCapture ? Color.red.opacity(0.5) : Color.green.opacity(0.3))
                            .frame(width: canCapture ? 20 : 16, height: canCapture ? 20 : 16)
                            .overlay(
                                canCapture ? Circle()
                                    .stroke(Color.red, lineWidth: 2)
                                    .frame(width: 24, height: 24) : nil
                            )
                            .position(
                                x: CGFloat(position.x) * cellWidth + offsetX,
                                y: CGFloat(position.y) * cellHeight + offsetY
                            )
                    }
                }
                
                // Pieces
                GeometryReader { geometry in
                    let cellWidth = geometry.size.width / 9
                    let cellHeight = geometry.size.height / 10
                    let offsetX = cellWidth / 2
                    let offsetY = cellHeight / 2
                    
                    ForEach(gameBoard.pieces) { piece in
                        PieceView(
                            piece: piece,
                            isSelected: selectedPiece?.id == piece.id
                        )
                        .position(
                            x: CGFloat(piece.position.x) * cellWidth + offsetX,
                            y: CGFloat(piece.position.y) * cellHeight + offsetY
                        )
                        .onTapGesture {
                            handlePieceTap(piece)
                        }
                    }
                }
            }
            .frame(width: 360, height: 400)
            .padding()
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { value in
                        handleBoardTap(at: value.location)
                    }
            )
            
            Button(action: {
                gameBoard.pieces.removeAll()
                gameBoard.setupInitialBoard()
                gameBoard.currentPlayer = .red
                selectedPiece = nil
                possibleMoves = []
            }) {
                Text("Reset Game")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding()
        }
    }
    
    private func handleBoardTap(at location: CGPoint) {
        let boardWidth: CGFloat = 360
        let boardHeight: CGFloat = 400
        let cellWidth = boardWidth / 9
        let cellHeight = boardHeight / 10
        
        let adjustedX = location.x - 15
        let adjustedY = location.y - 15
        
        let x = Int((adjustedX / cellWidth).rounded(.down))
        let y = Int((adjustedY / cellHeight).rounded(.down))
        
        if x >= 0 && x < 9 && y >= 0 && y < 10 {
            let position = Position(x: x, y: y)
            
            if let selected = selectedPiece {
                // If we have a selected piece and the tap is on a valid move position
                if possibleMoves.contains(position) {
                    // Ensure we're using the exact selected piece for the move
                    if let piece = gameBoard.pieces.first(where: { $0.id == selected.id }) {
                        print("Moving piece with ID: \(piece.id) from \(piece.position) to \(position)")
                        gameBoard.movePiece(from: piece.position, to: position)
                    }
                    selectedPiece = nil
                    possibleMoves = []
                } else {
                    // If tapping on a new piece of the same color
                    if let piece = gameBoard.pieceAt(position: position),
                       piece.color == gameBoard.currentPlayer {
                        selectedPiece = piece
                        print("Selected piece with ID: \(piece.id) at \(piece.position)")
                        possibleMoves = calculatePossibleMoves(for: piece)
                    } else {
                        selectedPiece = nil
                        possibleMoves = []
                    }
                }
            } else {
                // If no piece is selected and we tap on a piece
                if let piece = gameBoard.pieceAt(position: position),
                   piece.color == gameBoard.currentPlayer {
                    selectedPiece = piece
                    print("Selected piece with ID: \(piece.id) at \(piece.position)")
                    possibleMoves = calculatePossibleMoves(for: piece)
                }
            }
        }
    }
    
    private func handlePieceTap(_ piece: Piece) {
        print("\nPIECE TAP:")
        print("- Tapped piece: \(piece.color) \(piece.type) [ID: \(piece.id)]")
        
        if piece.color == gameBoard.currentPlayer {
            if let selected = selectedPiece {
                if piece.id == selected.id {
                    print("- Deselecting piece")
                    selectedPiece = nil
                    possibleMoves = []
                } else {
                    print("- Selecting new piece: \(piece.color) \(piece.type) [ID: \(piece.id)]")
                    // Ensure we're using the exact piece from the game board
                    if let exactPiece = gameBoard.pieces.first(where: { $0.id == piece.id }) {
                        selectedPiece = exactPiece
                        possibleMoves = calculatePossibleMoves(for: exactPiece)
                    }
                }
            } else {
                print("- Selecting piece: \(piece.color) \(piece.type) [ID: \(piece.id)]")
                // Ensure we're using the exact piece from the game board
                if let exactPiece = gameBoard.pieces.first(where: { $0.id == piece.id }) {
                    selectedPiece = exactPiece
                    possibleMoves = calculatePossibleMoves(for: exactPiece)
                }
            }
        } else if let selected = selectedPiece,
                  possibleMoves.contains(piece.position) {
            print("- Attempting capture:")
            print("  * Using: \(selected.color) \(selected.type) [ID: \(selected.id)]")
            print("  * Target: \(piece.color) \(piece.type) [ID: \(piece.id)]")
            
            // Ensure we're using the exact selected piece for the move
            if let exactPiece = gameBoard.pieces.first(where: { $0.id == selected.id }) {
                gameBoard.movePiece(from: exactPiece.position, to: piece.position)
            }
            selectedPiece = nil
            possibleMoves = []
        }
    }
    
    private func calculatePossibleMoves(for piece: Piece) -> [Position] {
        var moves: [Position] = []
        // Check all positions on the board
        for y in 0..<10 {
            for x in 0..<9 {
                let targetPosition = Position(x: x, y: y)
                if gameBoard.isValidMove(from: piece.position, to: targetPosition) {
                    moves.append(targetPosition)
                }
            }
        }
        return moves
    }
}

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
                
                // Horizontal lines - only draw within the board
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

struct PieceView: View {
    let piece: Piece
    let isSelected: Bool
    
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

// Make Position Hashable for ForEach
extension Position: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

#Preview {
    ContentView()
}
