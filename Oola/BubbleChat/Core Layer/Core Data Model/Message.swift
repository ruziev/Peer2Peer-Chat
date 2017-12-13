
import Foundation
import CoreData

extension Message {
    static func insertMessage(in context: NSManagedObjectContext) -> Message? {
        if let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as? Message {
            return message
        }
        return nil
    }
    
    
}
