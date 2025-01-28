import Foundation
import MultipeerConnectivity

enum GameConnectionState {
    case notConnected
    case connecting
    case connected
}

class GameConnection: NSObject, ObservableObject {
    @Published var state = GameConnectionState.notConnected
    @Published var availablePeers: [MCPeerID] = []
    @Published var receivedInvite: Bool = false
    @Published var invitationHandler: ((Bool, MCSession?) -> Void)?
    
    private let serviceType = "co-tuong-game"
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private var session: MCSession?
    private var serviceAdvertiser: MCNearbyServiceAdvertiser?
    private var serviceBrowser: MCNearbyServiceBrowser?
    
    var isHost: Bool = false
    var onMoveMade: ((Position, Position) -> Void)?
    
    override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session?.delegate = self
    }
    
    func startHosting() {
        isHost = true
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        serviceAdvertiser?.delegate = self
        serviceAdvertiser?.startAdvertisingPeer()
        state = .connecting
    }
    
    func startBrowsing() {
        isHost = false
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
        serviceBrowser?.delegate = self
        serviceBrowser?.startBrowsingForPeers()
        state = .connecting
    }
    
    func stopConnection() {
        serviceAdvertiser?.stopAdvertisingPeer()
        serviceBrowser?.stopBrowsingForPeers()
        session?.disconnect()
        state = .notConnected
        availablePeers.removeAll()
    }
    
    func connectTo(peer: MCPeerID) {
        guard let browser = serviceBrowser,
              let session = session else { return }
        
        browser.invitePeer(peer, to: session, withContext: nil, timeout: 30)
    }
    
    func sendMove(from: Position, to: Position) {
        guard let session = session,
              !session.connectedPeers.isEmpty else { return }
        
        let moveData = ["from": ["x": from.x, "y": from.y],
                       "to": ["x": to.x, "y": to.y]]
        
        do {
            let data = try JSONEncoder().encode(moveData)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Error sending move: \(error)")
        }
    }
    
    func acceptInvitation(accept: Bool) {
        guard let invitationHandler = invitationHandler else { return }
        invitationHandler(accept, session)
        self.invitationHandler = nil
        receivedInvite = false
        if accept {
            state = .connected
        }
    }
}

extension GameConnection: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                self.state = .connected
            case .notConnected:
                self.state = .notConnected
            case .connecting:
                self.state = .connecting
            @unknown default:
                break
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let moveData = try? JSONDecoder().decode([String: [String: Int]].self, from: data),
              let fromDict = moveData["from"],
              let toDict = moveData["to"],
              let fromX = fromDict["x"],
              let fromY = fromDict["y"],
              let toX = toDict["x"],
              let toY = toDict["y"] else { return }
        
        let fromPosition = Position(x: fromX, y: fromY)
        let toPosition = Position(x: toX, y: toY)
        
        DispatchQueue.main.async {
            self.onMoveMade?(fromPosition, toPosition)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

extension GameConnection: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        DispatchQueue.main.async {
            self.receivedInvite = true
            self.invitationHandler = invitationHandler
        }
    }
}

extension GameConnection: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async {
            if !self.availablePeers.contains(peerID) {
                self.availablePeers.append(peerID)
            }
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.availablePeers.removeAll(where: { $0 == peerID })
        }
    }
} 