import SwiftUI

struct ConnectionView: View {
    @ObservedObject var gameConnection: GameConnection
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            if gameConnection.state == .connected {
                Text("Connected!")
                    .font(.title)
                    .padding()
                Button("Start Playing") {
                    dismiss()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            } else {
                if gameConnection.isHost {
                    Text("Waiting for players to join...")
                        .font(.headline)
                        .padding()
                } else {
                    Text("Available Games")
                        .font(.headline)
                        .padding()
                    
                    List(gameConnection.availablePeers, id: \.self) { peer in
                        Button(peer.displayName) {
                            gameConnection.connectTo(peer: peer)
                        }
                    }
                }
                
                Button("Cancel") {
                    gameConnection.stopConnection()
                    dismiss()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
    }
} 