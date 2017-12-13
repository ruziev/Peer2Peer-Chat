
import UIKit
import CoreData

class ConversationsVC: UIViewController {
    
    // MARK: - Dependencies
    var communicationManager: ICommunicationManager!
    var profileManager: IProfileManager!
    var dataProvider: ConversationsDataProvider?
    
    // MARK: - IBOutlets
    @IBOutlet weak var conversationsTableView: UITableView!
    
    // MARK: - Emitter Animator
    lazy var emitterAnimator = Emitter(image: #imageLiteral(resourceName: "particle"), view: view)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataProvider?.register(tableView: conversationsTableView)
        profileManager.delegate = self
        profileManager.restore()
        
        conversationsTableView.dataSource = self
        conversationsTableView.delegate = self
        
        emitterAnimator.setUpGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        conversationsTableView.reloadData()
    }
    @IBAction func toProfileButtonTap(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileVCID") as! ProfileVC
        profileVC.profileManager = profileManager
        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        navigationController.pushViewController(profileVC, animated: false)
        present(navigationController, animated: true, completion: nil)
    }
}

extension ConversationsVC: IDataManagerDelegate {
    func didRestore(_ dataManager: IDataManager, restored: IProfileManager?) {
        if let restored = restored {
            profileManager = restored
            if let username = profileManager.name {
                communicationManager.displayedUsername = username
            }
        }
        communicationManager.online = true
    }
    
    func didSave(_ dataManager: IDataManager, success: Bool) {
        
    }
}

extension ConversationsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let frc = dataProvider?.fetchedResultsController, let sections = frc.sections else {
            return nil
        }
        return sections[section].indexTitle == "1" ? "Online" : "History"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let frc = dataProvider?.fetchedResultsController, let sectionsCount = frc.sections?.count else {
            return 0
        }
        return sectionsCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let frc = dataProvider?.fetchedResultsController, let sections = frc.sections else {
            return 0
        }
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conversationsListCell", for: indexPath) as! ConversationCell
        if let conversation = dataProvider?.fetchedResultsController.object(at: indexPath) {
            var conversationDisplayModel = ConversationDisplayModel(username: conversation.user?.name ?? "Unknown", lastMessage: nil, date: nil, online: conversation.online, hasUnreadMessages: conversation.hasUnreadMessages)
            if let lastMessage = conversation.lastMessage {
                conversationDisplayModel.lastMessage = lastMessage.text
                conversationDisplayModel.date = lastMessage.date
            }
            conversationDisplayModel.prepareCell(cell: cell)
        }
        return cell
    }
}

extension ConversationsVC: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        guard let cell = cell as? ConversationCell else { return }
//
//        UIView.transition(with: cell.nameLabel, duration: 1.0, options: .transitionCrossDissolve, animations: {
//            if cell.backgroundColor != .white {
//                cell.nameLabel.textColor = .green
//            }
//        }, completion: nil)
//
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "fromConversationsListToConversation", sender: indexPath)
        let selectedCell = tableView.cellForRow(at: indexPath)
        selectedCell?.isSelected = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromConversationsListToConversation" {
            guard let indexPath = sender as? IndexPath, let conversation = dataProvider?.fetchedResultsController.object(at: indexPath) else {
                fatalError("Wrong indexPath selected or sender is not of type IndexPath!")
            }
            // MARK: - Inject dependencies
            let destinationVC = segue.destination as! ConversationVC
            destinationVC.dataProvider = MessagesDataProvider()
            destinationVC.dataProvider?.context = dataProvider?.context
            destinationVC.conversationId = conversation.conversationId
            destinationVC.title = conversation.user?.name
            destinationVC.communicationManager = communicationManager
        }
    }
}
