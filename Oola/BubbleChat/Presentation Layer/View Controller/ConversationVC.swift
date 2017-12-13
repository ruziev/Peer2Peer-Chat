
import UIKit

class ConversationVC: UIViewController {
    var conversationId: String!
    
    var textAvailable = false
    
    @IBOutlet weak var messagesTableView: UITableView!
    var communicationManager: ICommunicationManager!
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    var dataProvider: MessagesDataProvider?
    
    // MARK: - Emitter Animator
    lazy var emitterAnimator = Emitter(image: #imageLiteral(resourceName: "particle"), view: view)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataProvider?.register(tableView: messagesTableView, conversationId: conversationId)
        dataProvider?.delegate = self
        dataProvider?.startUpdating()
        
        messagesTableView.dataSource = self
        messagesTableView.delegate = self
        
        textView.delegate = self
        
        addObserversForKeyboardAppearance()
        
        emitterAnimator.setUpGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        messagesTableView.scrollToBottom(animated: false)
        // make messages READ
        communicationManager.messagesAreRead(in: conversationId)
    }

    @IBAction func onSendButtonTap(_ sender: UIButton) {
        let text = textView.text!
        /// validating message
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            // string contains only whitespace characters
            return
        }
        communicationManager.sendMessage(in: conversationId, text: text, completion: { [weak self] (success, error) in
            if success {
                self?.textView.text = ""
                self?.textView.resignFirstResponder()
                self?.messagesTableView.scrollToBottom(animated: false)
                if self != nil {
                    self!.textViewDidChange(self!.textView)
                }
            } else if let error = error {
                let alertVC = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alertVC, animated: true, completion: nil)
            }
        })
    }
}

extension ConversationVC: UITableViewDataSource {
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
        var cell = MessageCell()
        if let message = dataProvider?.fetchedResultsController.object(at: indexPath) {
            guard let text = message.text, let date = message.date else {
                assert(false, "Message has no text or/and date!")
            }
            let messageDisplayModel = MessageDisplayModel(text: text, date: date, type: message.isIncoming ? .incoming : .outgoing)
            let cellReuseIdentifier = message.isIncoming ? "incomingMessageCell" : "outgoingMessageCell"
            cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! MessageCell
            messageDisplayModel.prepareCell(cell: cell)
        }
        return cell
    }
}

extension ConversationVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let messageCell = cell as! MessageCell
        guard let message = dataProvider?.fetchedResultsController.object(at: indexPath) else {
            fatalError("Wrong indexPath!")
        }
        guard let text = message.text, let date = message.date else {
            assert(false, "Message has no text or/and date!")
        }
        let messageDisplayModel = MessageDisplayModel(text: text, date: date, type: message.isIncoming ? .incoming : .outgoing)
        messageCell.layoutIfNeeded()
        messageDisplayModel.layoutCell(cell: messageCell)
    }
}

extension ConversationVC: MessagesDataProviderDelegate {
    func conversationStatusDidChange(online: Bool) {
        if online && textAvailable {
            if self.sendButton.isEnabled { return }
            UIView.transition(with: sendButton, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.sendButton.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                self.sendButton.setTitleColor(UIColor.red, for: .normal)
                self.sendButton.isEnabled = true
            }, completion: { (completed) in
                self.sendButton.transform = CGAffineTransform.identity
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.sendButton.isEnabled = false
                self.sendButton.setTitleColor(UIColor.lightGray, for: .normal)
            })
        }
    }
}

extension ConversationVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text!
        /// validating message
        if !text.trimmingCharacters(in: .whitespaces).isEmpty {
            // string contains only whitespace characters
            textAvailable = true
        } else {
            textAvailable = false
        }
        dataProvider?.tellConversationStatus()
    }
}

