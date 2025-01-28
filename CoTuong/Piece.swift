import Foundation

enum PieceType {
    case general // tướng/將
    case advisor // sĩ/仕
    case elephant // tượng/相
    case horse // mã/馬
    case chariot // xe/車
    case cannon // pháo/炮
    case soldier // tốt/兵
}

enum PieceColor {
    case red
    case black
}

struct Piece: Identifiable, Equatable, CustomStringConvertible {
    let id: String
    let type: PieceType
    let color: PieceColor
    var position: Position
    var hasMoved: Bool = false
    
    var description: String {
        return "\(color) \(type) at \(position) (ID: \(id))"
    }
    
    init(type: PieceType, color: PieceColor, position: Position, index: Int) {
        self.id = "\(color)_\(type)_\(index)"
        self.type = type
        self.color = color
        self.position = position
    }
    
    static func == (lhs: Piece, rhs: Piece) -> Bool {
        let equal = lhs.id == rhs.id
        return equal
    }
    
    var imageName: String {
        let colorPrefix = color == .red ? "red" : "black"
        let typeName: String
        switch type {
        case .general: typeName = "general"
        case .advisor: typeName = "advisor"
        case .elephant: typeName = "elephant"
        case .horse: typeName = "horse"
        case .chariot: typeName = "chariot"
        case .cannon: typeName = "cannon"
        case .soldier: typeName = "soldier"
        }
        return "\(colorPrefix)_\(typeName)"
    }
}

struct Position: Equatable, CustomStringConvertible {
    var x: Int // 0-8 (9 columns)
    var y: Int // 0-9 (10 rows)
    
    var description: String {
        return "(\(x), \(y))"
    }
    
    static func ==(lhs: Position, rhs: Position) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
} 