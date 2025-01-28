//
//  ContentView.swift
//  CoTuong
//
//  Created by Minh on 26/1/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameBoard = GameBoard()
    @StateObject private var gameConnection = GameConnection()
    @State private var selectedPiece: Piece?
    @State private var possibleMoves: [Position] = []
    @State private var showingConnectionSheet = false
    @State private var playerColor: PieceColor = .red
    @State private var activeCannonShot: (from: Position, to: Position)? = nil
    @State private var activeHorseJump: (from: Position, to: Position)? = nil
    @State private var activeSoldierAttack: (from: Position, to: Position)? = nil
    @State private var activeGeneralAttack: (from: Position, to: Position)? = nil
    @State private var activeAdvisorAttack: (from: Position, to: Position)? = nil
    @State private var activeElephantAttack: (from: Position, to: Position)? = nil
    @State private var activeChariotAttack: (from: Position, to: Position)? = nil
    
    var body: some View {
        VStack {
            
            MultiplayerView(
                gameConnection: gameConnection,
                showingConnectionSheet: $showingConnectionSheet,
                playerColor: $playerColor
            )
            
            if gameBoard.isCheckmate {
                Text("\(gameBoard.currentPlayer == .red ? "Black" : "Red") Wins!")
                    .font(.title2)
                    .foregroundColor(gameBoard.currentPlayer == .red ? .black : .red)
                    .padding(.bottom)
            } else {
                Text("\(gameBoard.currentPlayer == .red ? "Red" : "Black")'s Turn")
                    .font(.headline)
                    .foregroundColor(gameBoard.currentPlayer == .red ? .red : .black)
                    .padding(.bottom)
            }
            
            if gameBoard.isCheck && !gameBoard.isCheckmate {
                Text("Check!")
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
                        let isBeingCaptured = selectedPiece != nil && 
                                             possibleMoves.contains(piece.position) && 
                                             piece.color != selectedPiece?.color
                        
                        PieceView(
                            piece: piece,
                            isSelected: selectedPiece?.id == piece.id,
                            isBeingCaptured: isBeingCaptured,
                            cellWidth: cellWidth,
                            cellHeight: cellHeight
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
                
                // Cannon shot animation
                if let shot = activeCannonShot {
                    GeometryReader { geometry in
                        createCannonShot(from: shot.from, to: shot.to, in: geometry)
                    }
                }
                
                // Horse jump animation
                if let jump = activeHorseJump {
                    GeometryReader { geometry in
                        createHorseJump(from: jump.from, to: jump.to, in: geometry)
                    }
                }
                
                // Soldier attack animation
                if let attack = activeSoldierAttack {
                    GeometryReader { geometry in
                        createSoldierAttack(from: attack.from, to: attack.to, in: geometry)
                    }
                }
                
                // General attack animation
                if let generalAttack = activeGeneralAttack {
                    GeometryReader { geometry in
                        createGeneralAttack(from: generalAttack.from, to: generalAttack.to, in: geometry)
                    }
                }
                
                // Advisor attack animation
                if let advisorAttack = activeAdvisorAttack {
                    GeometryReader { geometry in
                        createAdvisorAttack(from: advisorAttack.from, to: advisorAttack.to, in: geometry)
                    }
                }
                
                // Elephant attack animation
                if let elephantAttack = activeElephantAttack {
                    GeometryReader { geometry in
                        createElephantAttack(from: elephantAttack.from, to: elephantAttack.to, in: geometry)
                    }
                }
                
                // Chariot attack animation
                if let chariotAttack = activeChariotAttack {
                    GeometryReader { geometry in
                        createChariotAttack(from: chariotAttack.from, to: chariotAttack.to, in: geometry)
                    }
                }
            }
            .frame(width: 360, height: 400)
            .padding()
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { value in
                        if !gameBoard.isCheckmate && canMakeMove() {
                            handleBoardTap(at: value.location)
                        }
                    }
            )
            
            if gameConnection.state == .connected {
                DisconnectButton(gameConnection: gameConnection, resetGame: resetGame)
            } else {
                Button(action: resetGame) {
                    Text(gameBoard.isCheckmate ? "New Game" : "Reset Game")
                        .foregroundColor(.white)
                        .padding()
                        .background(gameBoard.isCheckmate ? Color.green : Color.blue)
                        .cornerRadius(8)
                }
            }
        }
        .sheet(isPresented: $showingConnectionSheet) {
            ConnectionView(gameConnection: gameConnection)
        }
        .alert("Game Invitation", isPresented: $gameConnection.receivedInvite) {
            Button("Accept") {
                gameConnection.acceptInvitation(accept: true)
            }
            Button("Decline") {
                gameConnection.acceptInvitation(accept: false)
            }
        } message: {
            Text("Would you like to join this game?")
        }
        .onAppear {
            setupGameConnection()
        }
    }
    
    private func setupGameConnection() {
        gameConnection.onMoveMade = { from, to in
            gameBoard.movePiece(from: from, to: to)
        }
    }
    
    private func canMakeMove() -> Bool {
        if gameConnection.state == .connected {
            return gameBoard.currentPlayer == playerColor
        }
        return true
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
                        makeMove(from: piece.position, to: position)
                    }
                    selectedPiece = nil
                    possibleMoves = []
                } else {
                    // If tapping on a new piece of the same color
                    if let piece = gameBoard.pieceAt(position: position),
                       piece.color == gameBoard.currentPlayer {
                        selectedPiece = piece
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
                    possibleMoves = calculatePossibleMoves(for: piece)
                }
            }
        }
    }
    
    private func handlePieceTap(_ piece: Piece) {
        guard !gameBoard.isCheckmate && canMakeMove() else { return }
        
        if piece.color == gameBoard.currentPlayer {
            // If selecting a new piece, reset any pieces that were about to be captured
            if selectedPiece != nil {
                // Reset capture states for all pieces
                for p in gameBoard.pieces {
                    if possibleMoves.contains(p.position) && p.color != selectedPiece?.color {
                        // This piece was about to be captured, reset its state
                        if let index = gameBoard.pieces.firstIndex(where: { $0.id == p.id }) {
                            gameBoard.pieces[index].position = p.position
                        }
                    }
                }
            }
            
            if let selected = selectedPiece {
                if piece.id == selected.id {
                    selectedPiece = nil
                    possibleMoves = []
                } else {
                    if let exactPiece = gameBoard.pieces.first(where: { $0.id == piece.id }) {
                        selectedPiece = exactPiece
                        possibleMoves = calculatePossibleMoves(for: exactPiece)
                    }
                }
            } else {
                if let exactPiece = gameBoard.pieces.first(where: { $0.id == piece.id }) {
                    selectedPiece = exactPiece
                    possibleMoves = calculatePossibleMoves(for: exactPiece)
                }
            }
        } else if let selected = selectedPiece,
                  possibleMoves.contains(piece.position) {
            if let exactPiece = gameBoard.pieces.first(where: { $0.id == selected.id }) {
                makeMove(from: exactPiece.position, to: piece.position)
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
    
    private func createCannonShot(from: Position, to: Position, in geometry: GeometryProxy) -> some View {
        let cellWidth = geometry.size.width / 9
        let cellHeight = geometry.size.height / 10
        let offsetX = cellWidth / 2
        let offsetY = cellHeight / 2
        
        return CannonShotView(
            start: CGPoint(
                x: CGFloat(from.x) * cellWidth + offsetX,
                y: CGFloat(from.y) * cellHeight + offsetY
            ),
            end: CGPoint(
                x: CGFloat(to.x) * cellWidth + offsetX,
                y: CGFloat(to.y) * cellHeight + offsetY
            )
        )
    }
    
    private func createHorseJump(from: Position, to: Position, in geometry: GeometryProxy) -> some View {
        let cellWidth = geometry.size.width / 9
        let cellHeight = geometry.size.height / 10
        let offsetX = cellWidth / 2
        let offsetY = cellHeight / 2
        
        // Get the moving piece's color
        let pieceColor = gameBoard.pieceAt(position: from)?.color ?? .red
        
        return HorseJumpView(
            start: CGPoint(
                x: CGFloat(from.x) * cellWidth + offsetX,
                y: CGFloat(from.y) * cellHeight + offsetY
            ),
            end: CGPoint(
                x: CGFloat(to.x) * cellWidth + offsetX,
                y: CGFloat(to.y) * cellHeight + offsetY
            ),
            pieceColor: pieceColor
        )
    }
    
    private func createSoldierAttack(from: Position, to: Position, in geometry: GeometryProxy) -> some View {
        let cellWidth = geometry.size.width / 9
        let cellHeight = geometry.size.height / 10
        let offsetX = cellWidth / 2
        let offsetY = cellHeight / 2
        
        let pieceColor = gameBoard.pieceAt(position: from)?.color ?? .red
        
        return SoldierAttackView(
            start: CGPoint(
                x: CGFloat(from.x) * cellWidth + offsetX,
                y: CGFloat(from.y) * cellHeight + offsetY
            ),
            end: CGPoint(
                x: CGFloat(to.x) * cellWidth + offsetX,
                y: CGFloat(to.y) * cellHeight + offsetY
            ),
            pieceColor: pieceColor
        )
    }
    
    private func createGeneralAttack(from: Position, to: Position, in geometry: GeometryProxy) -> some View {
        // Similar implementation as other create functions
        // Implementation details would be added here
        Text("General Attack View")
    }
    
    private func createAdvisorAttack(from: Position, to: Position, in geometry: GeometryProxy) -> some View {
        // Similar implementation
        Text("Advisor Attack View")
    }
    
    private func createElephantAttack(from: Position, to: Position, in geometry: GeometryProxy) -> some View {
        // Similar implementation
        Text("Elephant Attack View")
    }
    
    private func createChariotAttack(from: Position, to: Position, in geometry: GeometryProxy) -> some View {
        let cellWidth = geometry.size.width / 9
        let cellHeight = geometry.size.height / 10
        let offsetX = cellWidth / 2
        let offsetY = cellHeight / 2
        
        let pieceColor = gameBoard.pieceAt(position: from)?.color ?? .red
        
        return ChariotAttackView(
            start: CGPoint(
                x: CGFloat(from.x) * cellWidth + offsetX,
                y: CGFloat(from.y) * cellHeight + offsetY
            ),
            end: CGPoint(
                x: CGFloat(to.x) * cellWidth + offsetX,
                y: CGFloat(to.y) * cellHeight + offsetY
            ),
            pieceColor: pieceColor
        )
    }
    
    private func makeMove(from: Position, to: Position) {
        if gameBoard.isValidMove(from: from, to: to) {
            if let capturedPiece = gameBoard.pieceAt(position: to),
               let movingPiece = gameBoard.pieceAt(position: from) {
                
                if movingPiece.type == .cannon {
                    // Set the active cannon shot
                    activeCannonShot = (from: from, to: to)
                    
                    // After the shot animation, perform the capture
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        gameBoard.movePiece(from: from, to: to)
                        if gameConnection.state == .connected {
                            gameConnection.sendMove(from: from, to: to)
                        }
                        // Clear the cannon shot
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            activeCannonShot = nil
                        }
                    }
                } else if movingPiece.type == .horse {
                    // Horse jump animation
                    activeHorseJump = (from: from, to: to)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        gameBoard.movePiece(from: from, to: to)
                        if gameConnection.state == .connected {
                            gameConnection.sendMove(from: from, to: to)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            activeHorseJump = nil
                        }
                    }
                } else if movingPiece.type == .soldier {
                    // Soldier attack animation
                    activeSoldierAttack = (from: from, to: to)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        gameBoard.movePiece(from: from, to: to)
                        if gameConnection.state == .connected {
                            gameConnection.sendMove(from: from, to: to)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            activeSoldierAttack = nil
                        }
                    }
                } else if movingPiece.type == .general {
                    activeGeneralAttack = (from: from, to: to)
                    // Similar implementation as other animations
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        gameBoard.movePiece(from: from, to: to)
                        if gameConnection.state == .connected {
                            gameConnection.sendMove(from: from, to: to)
                        }
                    }
                } else if movingPiece.type == .advisor {
                    activeAdvisorAttack = (from: from, to: to)
                    // Similar implementation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        gameBoard.movePiece(from: from, to: to)
                        if gameConnection.state == .connected {
                            gameConnection.sendMove(from: from, to: to)
                        }
                    }
                } else if movingPiece.type == .elephant {
                    activeElephantAttack = (from: from, to: to)
                    // Similar implementation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        gameBoard.movePiece(from: from, to: to)
                        if gameConnection.state == .connected {
                            gameConnection.sendMove(from: from, to: to)
                        }
                    }
                } else if movingPiece.type == .chariot {
                    activeChariotAttack = (from: from, to: to)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        gameBoard.movePiece(from: from, to: to)
                        if gameConnection.state == .connected {
                            gameConnection.sendMove(from: from, to: to)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            activeChariotAttack = nil
                        }
                    }
                } else {
                    // Normal capture animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        gameBoard.movePiece(from: from, to: to)
                        if gameConnection.state == .connected {
                            gameConnection.sendMove(from: from, to: to)
                        }
                    }
                }
            } else {
                // No capture, just move normally
                gameBoard.movePiece(from: from, to: to)
                if gameConnection.state == .connected {
                    gameConnection.sendMove(from: from, to: to)
                }
            }
        } else {
            selectedPiece = nil
            possibleMoves = []
        }
    }
    
    private func resetGame() {
        gameBoard.pieces.removeAll()
        gameBoard.setupInitialBoard()
        gameBoard.currentPlayer = .red
        gameBoard.isCheck = false
        gameBoard.isCheckmate = false
        selectedPiece = nil
        possibleMoves = []
    }
}

#Preview {
    ContentView()
}
