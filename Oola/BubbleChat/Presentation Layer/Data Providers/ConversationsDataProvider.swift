
import UIKit
import CoreData

class ConversationsDataProvider: NSObject {
    var fetchedResultsController: NSFetchedResultsController<Conversation>!
    var tableView: UITableView!
    var context: NSManagedObjectContext!
    
    func register(tableView: UITableView) {
        self.tableView = tableView
        let fetchRequest: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "online", ascending: false),
            NSSortDescriptor(key: "lastMessage.date", ascending: false),
            NSSortDescriptor(key: "user.name", ascending: true)
        ]
        fetchedResultsController = NSFetchedResultsController<Conversation>(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: #keyPath(Conversation.online), cacheName: nil)
        fetchedResultsController.delegate = self
        
        startUpdating()
    }
    
    func startUpdating() {
        do {
            try self.fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error fetching: \(error.description)")
        }
    }
}

extension ConversationsDataProvider: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // i have custom cell animations further, so this line would bother me
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // i have custom cell animations further, so this line would bother me
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange  anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .move, .update:
            break
        }
    }
}
