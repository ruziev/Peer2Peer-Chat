

import MultipeerConnectivity

class MultipeerCommunicator: NSObject, ICommunicator {
    var displayedUsername = UIDevice.current.name {
        didSet {
            online = false
            online = true
        }
    }
    fileprivate func reinit() {
        // sync
        if online {
            browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
            advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: ["userName": displayedUsername], serviceType: serviceType)
            browser?.delegate = self
            advertiser?.delegate = self
            browser?.startBrowsingForPeers()
            advertiser?.startAdvertisingPeer()
        } else {
            browser?.stopBrowsingForPeers()
            advertiser?.stopAdvertisingPeer()
            browser = nil
            advertiser = nil
        }
    }
    
    var online: Bool = false {
        didSet {
            DispatchQueue.global(qos: .userInitiated).async {
                self.reinit()
            }
        }
    }
    weak var delegate: ICommunicatorDelegate?
    private let serviceType = "bubble-chat"
    
    private let myPeerID: MCPeerID
    private var browser: MCNearbyServiceBrowser?
    private var advertiser: MCNearbyServiceAdvertiser?
    
    private var sessions: [MCPeerID: MCSession] = [:]
    private var usernames: [MCPeerID: String] = [:]
    
    
    
    override init() {
        guard let idForVendor = UIDevice.current.identifierForVendor else {
            fatalError("Current device has no identifierForVendor")
        }
        myPeerID = MCPeerID(displayName: idForVendor.description)
        
        super.init()
    }
    
    
    func sendMessage(text: String, to userID: String, completionHandler: ((Bool, Error?) -> ())?) {
        var peerID: MCPeerID?
        for peer in sessions.keys {
            if peer.displayName == userID {
                peerID = peer
                break
            }
        }
        if let peerID = peerID {
            let sendingMessageId = MultipeerCommunicatorMessage.generateRandomMessageId()
            let message = MultipeerCommunicatorMessage(text: text, messageId: sendingMessageId)
            do {
                try sessions[peerID]!.send(JSONEncoder().encode(message), toPeers: [peerID], with: .reliable)
                completionHandler?(true, nil)
            } catch {
                completionHandler?(false, error)
            }
        } else {
            completionHandler?(false, NSError(domain: "no such active user", code: 228, userInfo: nil))
        }
    }
}

extension MultipeerCommunicator: MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        delegate?.failedToStartBrowsingForUsers(error: error)
        online = false
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if let username = info?["userName"] {
            usernames[peerID] = username
        }
        // creating session
        let session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        sessions[peerID] = session
        // inviting peer to session
        browser.invitePeer(peerID, to: session, withContext: encodedInvitationContext, timeout: 0)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        delegate?.didLostUser(userId: peerID.displayName)
        sessions.removeValue(forKey: peerID)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        delegate?.failedToStartAdvertising(error: error)
        online = false
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // create session
        let session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        sessions[peerID] = session
        // accept invitation
        invitationHandler(true, session)
        // save username for this peer
        if let username = decodeUsernameFromInvitationContext(from: context) {
            usernames[peerID] = username
        }
    }
}

extension MultipeerCommunicator: MCSessionDelegate {
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // not implemented
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // not implemented
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // not implemented
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            delegate?.didFoundUser(userId: peerID.displayName, userName: usernames[peerID])
        case .notConnected:
            delegate?.didLostUser(userId: peerID.displayName)
        default:
            break
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            let message = try JSONDecoder().decode(MultipeerCommunicatorMessage.self, from: data)
            delegate?.didReceiveMessage(text: message.text, from: peerID.displayName, to: myPeerID.displayName)
        } catch {
            return
        }
    }
}

extension MultipeerCommunicator {
    private var encodedInvitationContext: Data {
        // JSON encoded discoveryInfo to send while inviting to session
        let discoveryInfo = ["userName": displayedUsername]
        let data: Data
        do {
            data = try JSONEncoder().encode(discoveryInfo)
        } catch {
            fatalError("Could not JSON encode Discovery Info")
        }
        return data
    }
    
    func decodeUsernameFromInvitationContext(from data: Data?) -> String? {
        // get username or nil from invitationContext when someone invites to session
        guard let fromData = data else { return nil }
        do {
            let username = try JSONDecoder().decode([String:String].self, from: fromData)["userName"]
            if username != nil {
                return username
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
}

struct MultipeerCommunicatorMessage: Codable {
    var text: String
    var messageId: String
    var eventType: String = "TextMessage"
    
    init(text: String, messageId: String) {
        self.text = text
        self.messageId = messageId
    }
    
    static func generateRandomMessageId() -> String {
        let string = "\(arc4random_uniform(UINT32_MAX))+\(Date.timeIntervalSinceReferenceDate)+\(arc4random_uniform(UINT32_MAX))".data(using: .utf8)?.base64EncodedString()
        return string!
    }
}
