import Foundation

class GameBoard: ObservableObject {
    @Published var pieces: [Piece]
    @Published var selectedPiece: Piece?
    @Published var currentPlayer: PieceColor = .red
    @Published var isCheckmate: Bool = false
    @Published var isCheck: Bool = false
    
    init() {
        self.pieces = []
        setupInitialBoard()
    }
    
    func setupInitialBoard() {
        // Black pieces (top)
        pieces.append(Piece(type: .chariot, color: .black, position: Position(x: 0, y: 0), index: 0))
        pieces.append(Piece(type: .horse, color: .black, position: Position(x: 1, y: 0), index: 0))
        pieces.append(Piece(type: .elephant, color: .black, position: Position(x: 2, y: 0), index: 0))
        pieces.append(Piece(type: .advisor, color: .black, position: Position(x: 3, y: 0), index: 0))
        pieces.append(Piece(type: .general, color: .black, position: Position(x: 4, y: 0), index: 0))
        pieces.append(Piece(type: .advisor, color: .black, position: Position(x: 5, y: 0), index: 1))
        pieces.append(Piece(type: .elephant, color: .black, position: Position(x: 6, y: 0), index: 1))
        pieces.append(Piece(type: .horse, color: .black, position: Position(x: 7, y: 0), index: 1))
        pieces.append(Piece(type: .chariot, color: .black, position: Position(x: 8, y: 0), index: 1))
        pieces.append(Piece(type: .cannon, color: .black, position: Position(x: 1, y: 2), index: 0))
        pieces.append(Piece(type: .cannon, color: .black, position: Position(x: 7, y: 2), index: 1))
        pieces.append(Piece(type: .soldier, color: .black, position: Position(x: 0, y: 3), index: 0))
        pieces.append(Piece(type: .soldier, color: .black, position: Position(x: 2, y: 3), index: 1))
        pieces.append(Piece(type: .soldier, color: .black, position: Position(x: 4, y: 3), index: 2))
        pieces.append(Piece(type: .soldier, color: .black, position: Position(x: 6, y: 3), index: 3))
        pieces.append(Piece(type: .soldier, color: .black, position: Position(x: 8, y: 3), index: 4))
        
        // Red pieces (bottom)
        pieces.append(Piece(type: .chariot, color: .red, position: Position(x: 0, y: 9), index: 0))
        pieces.append(Piece(type: .horse, color: .red, position: Position(x: 1, y: 9), index: 0))
        pieces.append(Piece(type: .elephant, color: .red, position: Position(x: 2, y: 9), index: 0))
        pieces.append(Piece(type: .advisor, color: .red, position: Position(x: 3, y: 9), index: 0))
        pieces.append(Piece(type: .general, color: .red, position: Position(x: 4, y: 9), index: 0))
        pieces.append(Piece(type: .advisor, color: .red, position: Position(x: 5, y: 9), index: 1))
        pieces.append(Piece(type: .elephant, color: .red, position: Position(x: 6, y: 9), index: 1))
        pieces.append(Piece(type: .horse, color: .red, position: Position(x: 7, y: 9), index: 1))
        pieces.append(Piece(type: .chariot, color: .red, position: Position(x: 8, y: 9), index: 1))
        pieces.append(Piece(type: .cannon, color: .red, position: Position(x: 1, y: 7), index: 0))
        pieces.append(Piece(type: .cannon, color: .red, position: Position(x: 7, y: 7), index: 1))
        pieces.append(Piece(type: .soldier, color: .red, position: Position(x: 0, y: 6), index: 0))
        pieces.append(Piece(type: .soldier, color: .red, position: Position(x: 2, y: 6), index: 1))
        pieces.append(Piece(type: .soldier, color: .red, position: Position(x: 4, y: 6), index: 2))
        pieces.append(Piece(type: .soldier, color: .red, position: Position(x: 6, y: 6), index: 3))
        pieces.append(Piece(type: .soldier, color: .red, position: Position(x: 8, y: 6), index: 4))
    }
    
    func pieceAt(position: Position) -> Piece? {
        return pieces.first { $0.position == position }
    }
    
    func isValidMove(from: Position, to: Position) -> Bool {
        guard let piece = pieceAt(position: from) else { return false }
        guard piece.color == currentPlayer else { return false }
        
        // Check if destination has a piece of the same color
        if let destPiece = pieceAt(position: to) {
            if destPiece.color == piece.color { return false }
        }
        
        // Check if the move is within board bounds
        if !isWithinBounds(position: to) { return false }
        
        // Validate move based on piece type
        switch piece.type {
        case .general:
            return isValidGeneralMove(from: from, to: to, color: piece.color)
        case .advisor:
            return isValidAdvisorMove(from: from, to: to, color: piece.color)
        case .elephant:
            return isValidElephantMove(from: from, to: to, color: piece.color)
        case .horse:
            return isValidHorseMove(from: from, to: to)
        case .chariot:
            return isValidChariotMove(from: from, to: to)
        case .cannon:
            return isValidCannonMove(from: from, to: to)
        case .soldier:
            return isValidSoldierMove(from: from, to: to, color: piece.color)
        }
    }
    
    private func isWithinBounds(position: Position) -> Bool {
        return position.x >= 0 && position.x < 9 && position.y >= 0 && position.y < 10
    }
    
    private func isInPalace(position: Position, color: PieceColor) -> Bool {
        let y = position.y
        let x = position.x
        if color == .red {
            return x >= 3 && x <= 5 && y >= 7 && y <= 9
        } else {
            return x >= 3 && x <= 5 && y >= 0 && y <= 2
        }
    }
    
    private func isValidGeneralMove(from: Position, to: Position, color: PieceColor) -> Bool {
        // Must stay in palace
        if !isInPalace(position: to, color: color) { return false }
        
        // Can only move one step orthogonally
        let dx = abs(to.x - from.x)
        let dy = abs(to.y - from.y)
        
        // Check for flying general rule
        if dx == 0 && dy > 1 {
            // Check if it's a direct confrontation with the opposing general
            var foundPiece = false
            let minY = min(from.y, to.y)
            let maxY = max(from.y, to.y)
            
            for y in (minY + 1)..<maxY {
                if let piece = pieceAt(position: Position(x: from.x, y: y)) {
                    foundPiece = true
                    break
                }
            }
            
            if !foundPiece {
                if let piece = pieceAt(position: to) {
                    return piece.type == .general && piece.color != color
                }
            }
        }
        
        return (dx == 1 && dy == 0) || (dx == 0 && dy == 1)
    }
    
    private func isValidAdvisorMove(from: Position, to: Position, color: PieceColor) -> Bool {
        // Must stay in palace
        if !isInPalace(position: to, color: color) { return false }
        
        // Can only move one step diagonally
        let dx = abs(to.x - from.x)
        let dy = abs(to.y - from.y)
        return dx == 1 && dy == 1
    }
    
    private func isValidElephantMove(from: Position, to: Position, color: PieceColor) -> Bool {
        // Cannot cross river
        if color == .red && to.y < 5 { return false }
        if color == .black && to.y > 4 { return false }
        
        // Must move exactly two points diagonally
        let dx = abs(to.x - from.x)
        let dy = abs(to.y - from.y)
        if dx != 2 || dy != 2 { return false }
        
        // Check if the path is blocked
        let midX = (from.x + to.x) / 2
        let midY = (from.y + to.y) / 2
        return pieceAt(position: Position(x: midX, y: midY)) == nil
    }
    
    private func isValidHorseMove(from: Position, to: Position) -> Bool {
        let dx = abs(to.x - from.x)
        let dy = abs(to.y - from.y)
        
        // Horse moves in an L-shape: 2 steps in one direction and 1 step in the perpendicular direction
        if !((dx == 2 && dy == 1) || (dx == 1 && dy == 2)) { return false }
        
        // Check for blocking piece
        let blockingX = from.x + (dx == 2 ? (to.x - from.x) / 2 : 0)
        let blockingY = from.y + (dy == 2 ? (to.y - from.y) / 2 : 0)
        return pieceAt(position: Position(x: blockingX, y: blockingY)) == nil
    }
    
    private func isValidChariotMove(from: Position, to: Position) -> Bool {
        let dx = to.x - from.x
        let dy = to.y - from.y
        
        // Must move either horizontally or vertically
        if dx != 0 && dy != 0 { return false }
        
        // Check if path is clear
        if dx != 0 {
            let minX = min(from.x, to.x)
            let maxX = max(from.x, to.x)
            for x in (minX + 1)..<maxX {
                if pieceAt(position: Position(x: x, y: from.y)) != nil {
                    return false
                }
            }
        } else {
            let minY = min(from.y, to.y)
            let maxY = max(from.y, to.y)
            for y in (minY + 1)..<maxY {
                if pieceAt(position: Position(x: from.x, y: y)) != nil {
                    return false
                }
            }
        }
        return true
    }
    
    private func isValidCannonMove(from: Position, to: Position) -> Bool {
        let dx = to.x - from.x
        let dy = to.y - from.y
        
        // Must move either horizontally or vertically
        if dx != 0 && dy != 0 { return false }
        
        var piecesInPath = 0
        
        // Count pieces in path
        if dx != 0 {
            let minX = min(from.x, to.x)
            let maxX = max(from.x, to.x)
            for x in (minX + 1)..<maxX {
                if pieceAt(position: Position(x: x, y: from.y)) != nil {
                    piecesInPath += 1
                }
            }
        } else {
            let minY = min(from.y, to.y)
            let maxY = max(from.y, to.y)
            for y in (minY + 1)..<maxY {
                if pieceAt(position: Position(x: from.x, y: y)) != nil {
                    piecesInPath += 1
                }
            }
        }
        
        // If capturing, need exactly one piece in between
        if pieceAt(position: to) != nil {
            return piecesInPath == 1
        }
        
        // If not capturing, path must be clear
        return piecesInPath == 0
    }
    
    private func isValidSoldierMove(from: Position, to: Position, color: PieceColor) -> Bool {
        let dx = abs(to.x - from.x)
        let dy = to.y - from.y
        
        // Red soldiers move up (negative dy), black soldiers move down (positive dy)
        let forwardDirection = color == .red ? -1 : 1
        
        // Before crossing river: can only move forward
        if (color == .red && from.y > 4) || (color == .black && from.y < 5) {
            return dx == 0 && dy == forwardDirection
        }
        
        // After crossing river: can move forward or sideways
        return (dx == 0 && dy == forwardDirection) || (dx == 1 && dy == 0)
    }
    
    func movePiece(from: Position, to: Position) {
        // First verify that there is a piece at the 'from' position and it belongs to current player
        guard let movingPiece = pieceAt(position: from) else { return }
        
        // Verify it's the current player's piece
        guard movingPiece.color == currentPlayer else { return }
        
        // Verify the move is valid
        guard isValidMove(from: from, to: to) else { return }
        
        // Find the exact moving piece by ID
        guard let fromIndex = pieces.firstIndex(where: { $0.id == movingPiece.id }) else { return }
        
        // Check for capture
        if let capturedPiece = pieceAt(position: to) {
            // Find and remove the captured piece by ID
            if let captureIndex = pieces.firstIndex(where: { $0.id == capturedPiece.id }) {
                pieces.remove(at: captureIndex)
                
                // If the captured piece was before our moving piece in the array,
                // we need to adjust the index of our moving piece
                if captureIndex < fromIndex {
                    // Find the new index of our moving piece after the capture
                    guard let newFromIndex = pieces.firstIndex(where: { $0.id == movingPiece.id }) else { return }
                    // Update the moving piece's position
                    pieces[newFromIndex].position = to
                    pieces[newFromIndex].hasMoved = true
                } else {
                    // The captured piece was after our moving piece, so the index is still valid
                    pieces[fromIndex].position = to
                    pieces[fromIndex].hasMoved = true
                }
            }
        } else {
            // No capture, just move the piece
            pieces[fromIndex].position = to
            pieces[fromIndex].hasMoved = true
        }
        
        // Switch turns
        currentPlayer = currentPlayer == .red ? .black : .red
        
        // Check for check and checkmate
        let opponentColor = currentPlayer // Since we already switched turns
        isCheck = isInCheck(color: opponentColor)
        if isCheck {
            isCheckmate = isInCheckmate(color: opponentColor)
        } else {
            isCheckmate = false
        }
    }
    
    private func isInCheck(color: PieceColor) -> Bool {
        // Find the general's position
        guard let general = pieces.first(where: { $0.type == .general && $0.color == color }) else {
            return false
        }
        
        // Check if any opponent's piece can capture the general
        for piece in pieces where piece.color != color {
            if isValidMove(from: piece.position, to: general.position) {
                return true
            }
        }
        
        return false
    }
    
    private func isInCheckmate(color: PieceColor) -> Bool {
        // If not in check, can't be in checkmate
        if !isInCheck(color: color) {
            return false
        }
        
        // Get all pieces of the current player
        let playerPieces = pieces.filter { $0.color == color }
        
        // Try every possible move for each piece
        for piece in playerPieces {
            for y in 0..<10 {
                for x in 0..<9 {
                    let targetPosition = Position(x: x, y: y)
                    
                    // If this is a valid move
                    if isValidMove(from: piece.position, to: targetPosition) {
                        // Try the move
                        let originalPosition = piece.position
                        let capturedPiece = pieces.first(where: { $0.position == targetPosition })
                        
                        // Make the move temporarily
                        if let capturedIndex = pieces.firstIndex(where: { $0.position == targetPosition }) {
                            pieces.remove(at: capturedIndex)
                        }
                        if let pieceIndex = pieces.firstIndex(where: { $0.id == piece.id }) {
                            pieces[pieceIndex].position = targetPosition
                        }
                        
                        // Check if this move gets out of check
                        let stillInCheck = isInCheck(color: color)
                        
                        // Undo the move
                        if let pieceIndex = pieces.firstIndex(where: { $0.id == piece.id }) {
                            pieces[pieceIndex].position = originalPosition
                        }
                        if let capturedPiece = capturedPiece {
                            pieces.append(capturedPiece)
                        }
                        
                        // If we found a move that prevents check, it's not checkmate
                        if !stillInCheck {
                            return false
                        }
                    }
                }
            }
        }
        
        // If we haven't found any valid moves that prevent check, it's checkmate
        return true
    }
} 