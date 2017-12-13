
import Foundation
import CoreData

extension Conversation {
    static func insertConversation(in context: NSManagedObjectContext, with userId: String) -> Conversation? {
        if let conversation = NSEntityDescription.insertNewObject(forEntityName: "Conversation", into: context) as? Conversation {
            conversation.conversationId = userId
            return conversation
        }
        return nil
    }
    
    static func findOrInsertConversation(in context: NSManagedObjectContext, with userId: String) -> Conversation? {
        guard (context.persistentStoreCoordinator?.managedObjectModel) != nil else {
            print("Model is not available in context!")
            assert(false)
            return nil
        }
        
        var conversation: Conversation?
        let fetchRequest: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", "conversationId", userId)
        
        do {
            let results = try context.fetch(fetchRequest)
            assert(results.count <= 1, "Multiple Conversations with same conversationId found!")
            if let foundConversation = results.first {
                conversation = foundConversation
            }
        } catch _ as NSError { }
        
        if conversation == nil {
            conversation = Conversation.insertConversation(in: context, with: userId)
        }
        
        return conversation
    }
}
