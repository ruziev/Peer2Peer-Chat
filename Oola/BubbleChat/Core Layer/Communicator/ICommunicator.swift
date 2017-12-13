
import Foundation

protocol ICommunicator {
    func sendMessage(text: String, to userID: String, completionHandler: ((_ success: Bool, _ error: Error?) -> ())?)
    weak var delegate: ICommunicatorDelegate? {get set}
    var online: Bool {get set}
    var displayedUsername: String {get set}
}
