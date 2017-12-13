

import Foundation
import CoreData

extension User {
    static func insertUser(in context: NSManagedObjectContext, userId: String) -> User? {
        if let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as? User {
            user.userId = userId
            return user
        }
        return nil
    }
    
    static func insertUser(in context: NSManagedObjectContext) -> User? {
        if let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as? User {
            return user
        }
        return nil
    }
    
    static func findOrInsertUser(in context: NSManagedObjectContext, userId: String) -> User? {
        guard (context.persistentStoreCoordinator?.managedObjectModel) != nil else {
            print("Model is not available in context!")
            assert(false)
            return nil
        }
        
        var user: User?
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", "userId", userId)
        
        do {
            let results = try context.fetch(fetchRequest)
            assert(results.count <= 1, "Multiple Users with same userId found!")
            if let foundUser = results.first {
                user = foundUser
            }
        } catch let _ as NSError { }
        
        if user == nil {
            user = User.insertUser(in: context, userId: userId)
        }
        
        return user
    }
}
