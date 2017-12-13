
import UIKit

extension UIViewController {
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handleKeyboardNotification(_ notification: NSNotification) {
        if let keyboardHeight = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            
            let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
            view.frame.origin.y += isKeyboardShowing ? -(keyboardHeight) : keyboardHeight
        }
    }
    
    func addObserversForKeyboardAppearance() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification(_:)),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification(_:)),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
}

extension UIViewController {
    
    /// simple alert message
    func displayAlert(title: String?, message: String? = nil, actions: [UIAlertAction] = []) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if actions.count == 0 {
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
        } else {
            for action in actions {
                alertController.addAction(action)
            }
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
}
