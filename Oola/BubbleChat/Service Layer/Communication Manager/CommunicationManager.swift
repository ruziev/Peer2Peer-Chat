
import UIKit

class CommunicationManager: ICommunicationManager, ICommunicatorDelegate {
    var coreDataStack: CoreDataStack!
    
    var displayedUsername: String {
        didSet {
            communicator.displayedUsername = displayedUsername
        }
    }
    
    private var communicator: ICommunicator = MultipeerCommunicator()
    
    var online: Bool = false {
        didSet {
            communicator.online = online
        }
    }
    
    init() {
        displayedUsername = communicator.displayedUsername
        communicator.delegate = self
    }
    
    func didFoundUser(userId: String, userName: String?) {
        guard let saveContext = coreDataStack.saveContext else {
            fatalError("Core data stack save context is nil!")
        }
        guard let user = User.findOrInsertUser(in: saveContext, userId: userId) else {
            fatalError("Could not create/find new user!")
        }
        user.name = userName
        guard let userId = user.userId else {
            fatalError("Found/created user has no userId!")
        }
        let conversation = Conversation.findOrInsertConversation(in: saveContext, with: userId)
        conversation?.user = user
        conversation?.online = true
        coreDataStack.performSave(context: saveContext, completionHandler: nil)
    }
    
    func didLostUser(userId: String) {
        guard let saveContext = coreDataStack.saveContext else {
            fatalError("Core data stack save context is nil!")
        }
        let conversation = Conversation.findOrInsertConversation(in: saveContext, with: userId)
        conversation?.online = false
        coreDataStack.performSave(context: saveContext, completionHandler: nil)
    }
    
    func failedToStartBrowsingForUsers(error: Error) {
        
    }
    
    func failedToStartAdvertising(error: Error) {
        
    }
    
    func didReceiveMessage(text: String, from conversationId: String, to destinationUserId: String) {
        // this implementation assumes toUser is current user (owner)
        guard let saveContext = coreDataStack.saveContext else {
            fatalError("Core data stack save context is nil!")
        }
        guard let conversation = Conversation.findOrInsertConversation(in: saveContext, with: conversationId) else {
            fatalError("New message, but could not find conversation with such conversationId!")
        }
        let message = Message.insertMessage(in: saveContext)
        message?.conversation = conversation
        message?.text = text
        message?.date = Date()
        message?.isIncoming = true
        conversation.hasUnreadMessages = true
        conversation.lastMessage = message
        coreDataStack.performSave(context: saveContext, completionHandler: nil)
    }
    
    func sendMessage(in conversationId: String, text: String, completion: ((Bool,Error?) -> ())?) {
        communicator.sendMessage(text: text, to: conversationId, completionHandler: { [weak self] (success, error) in
            if success {
                guard let saveContext = self?.coreDataStack.saveContext else {
                    fatalError("Core data stack save context is nil!")
                }
                guard let conversation = Conversation.findOrInsertConversation(in: saveContext, with: conversationId) else {
                    fatalError("New message, but could not find conversation with such conversationId!")
                }
                let message = Message.insertMessage(in: saveContext)
                message?.conversation = conversation
                message?.text = text
                message?.date = Date()
                message?.isIncoming = false
                conversation.lastMessage = message
                self?.coreDataStack.performSave(context: saveContext, completionHandler: nil)
            }
            DispatchQueue.main.async {
                completion?(success, error)
            }
        })
    }
    
    func messagesAreRead(in conversationId: String) {
        guard let saveContext = coreDataStack.saveContext else {
            fatalError("Core data stack save context is nil!")
        }
        guard let conversation = Conversation.findOrInsertConversation(in: saveContext, with: conversationId) else {
            fatalError("New message, but could not find conversation with such conversationId!")
        }
        conversation.hasUnreadMessages = false
        coreDataStack.performSave(context: saveContext, completionHandler: nil)
    }
}
