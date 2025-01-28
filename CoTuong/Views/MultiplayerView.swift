import SwiftUI

struct MultiplayerView: View {
    @ObservedObject var gameConnection: GameConnection
    @Binding var showingConnectionSheet: Bool
    @Binding var playerColor: PieceColor
    
    var body: some View {
        if gameConnection.state == .notConnected {
            HStack {
                Button("Host Game") {
                    gameConnection.startHosting()
                    playerColor = .red
                    showingConnectionSheet = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button("Join Game") {
                    gameConnection.startBrowsing()
                    playerColor = .black
                    showingConnectionSheet = true
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        } else {
            VStack {
                if gameConnection.state == .connected {
                    Text("Playing as \(playerColor == .red ? "Red" : "Black")")
                        .font(.headline)
                        .padding(.bottom)
                } else {
                    Text("Connecting...")
                        .font(.headline)
                        .padding(.bottom)
                    
                    Button("Return") {
                        gameConnection.stopConnection()
                        showingConnectionSheet = false
                    }
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
    }
}

// Add a disconnect button view
struct DisconnectButton: View {
    @ObservedObject var gameConnection: GameConnection
    let resetGame: () -> Void
    
    var body: some View {
        Button("Disconnect") {
            gameConnection.stopConnection()
            resetGame()
        }
        .padding()
        .background(Color.red)
        .foregroundColor(.white)
        .cornerRadius(8)
    }
} 