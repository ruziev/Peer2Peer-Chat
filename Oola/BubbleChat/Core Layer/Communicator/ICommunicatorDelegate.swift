

import Foundation

protocol ICommunicatorDelegate : class {
    // discovering
    func didFoundUser(userId: String, userName: String?)
    func didLostUser(userId: String)
    
    // errors
    func failedToStartBrowsingForUsers(error: Error)
    func failedToStartAdvertising(error: Error)
    
    //messages
    func didReceiveMessage(text: String, from conversationId: String, to destinationUserId: String)
}
