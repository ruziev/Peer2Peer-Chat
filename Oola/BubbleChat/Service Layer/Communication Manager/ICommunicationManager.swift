
protocol ICommunicationManager {
    var online: Bool {get set}
    var displayedUsername: String {get set}
    func sendMessage(in conversationId: String, text: String, completion: ((Bool,Error?) -> ())?)
    func messagesAreRead(in conversationId: String)
}
