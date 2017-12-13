
import UIKit
import CoreData

protocol MessagesDataProviderDelegate : class {
    func conversationStatusDidChange(online: Bool)
}

class MessagesDataProvider: NSObject {
    var fetchedResultsController: NSFetchedResultsController<Message>!
    var frcForThisConversation: NSFetchedResultsController<Conversation>!
    var tableView: UITableView!
    var context: NSManagedObjectContext!
    weak var delegate: MessagesDataProviderDelegate?
    
    
    func register(tableView: UITableView, conversationId: String) {
        self.tableView = tableView
        let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "conversation.conversationId == %@", conversationId)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: true)
        ]
        fetchedResultsController = NSFetchedResultsController<Message>(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        let thisConversationFetchRequest: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        thisConversationFetchRequest.predicate = NSPredicate(format: "conversationId == %@", conversationId)
        thisConversationFetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "conversationId", ascending: true)
        ]
        frcForThisConversation = NSFetchedResultsController<Conversation>.init(fetchRequest: thisConversationFetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frcForThisConversation.delegate = self
    }
    
    func startUpdating() {
        do {
            try self.fetchedResultsController.performFetch()
            try self.frcForThisConversation.performFetch()
            
            tellConversationStatus()
        } catch let error as NSError {
            print("Error fetching: \(error.description)")
        }
    }
    
    func tellConversationStatus() {
        guard let thisConversation = frcForThisConversation.fetchedObjects?.first else {
            print("Could not fetch this conversation!")
            return
        }
        DispatchQueue.main.async {
            self.delegate?.conversationStatusDidChange(online: thisConversation.online)
        }
    }
}

extension MessagesDataProvider: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == fetchedResultsController {
            tableView.beginUpdates()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == fetchedResultsController {
            tableView.endUpdates()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange  anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if controller == fetchedResultsController {
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
        
        if controller == frcForThisConversation {
            tellConversationStatus()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        if controller == fetchedResultsController {
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
}

