
import UIKit

class ProfileVC: UIViewController {
    var profileManager: IProfileManager = ProfileManager()
    lazy var dataManager: IDataManager = profileManager
    @IBOutlet weak var newImageButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var saveButton: RoundedButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let imagePicker = UIImagePickerController()
    
    // MARK: - Emitter Animator
    lazy var emitterAnimator = Emitter(image: #imageLiteral(resourceName: "particle"), view: view)
    
    var inputDataChanged: Bool = false {
        didSet {
            if inputDataChanged && !processingDataManager {
                enableButtons()
            } else {
                disableButtons()
            }
        }
    }
    
    var processingDataManager: Bool = false {
        didSet {
            if inputDataChanged && !processingDataManager {
                enableButtons()
            } else {
                disableButtons()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataManager.delegate = self
        imagePicker.delegate = self
        nameTextField.delegate = self
        descriptionTextView.delegate = self
        
        addObserversForKeyboardAppearance()
        
        layout()
        
        emitterAnimator.setUpGestureRecognizer()
    }
    
    // CLOSE THIS MODAL SCREEN
    @IBAction func onCloseScreen(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UI programmaticaly changes
extension ProfileVC {
    
    // MARK: - Custom UI Drawings
    func layout() {
        let newImageButtonCornerRadius = newImageButton.frame.height / 2.0
        newImageButton.layer.cornerRadius = newImageButtonCornerRadius
        profileImageView.layer.cornerRadius = newImageButtonCornerRadius
        profileImageView.layer.masksToBounds = true
        disableButtons()
        dataManager.restore()
        activityIndicator.startAnimating()
    }
    
    // MARK: - UIButton state changes
    func enableButtons() {
        saveButton.isEnabled = true
    }
    func disableButtons() {
        saveButton.isEnabled = false
    }
    
}

// MARK: - DataManagerDelegate - save/restore operations results
extension ProfileVC: IDataManagerDelegate {
    func didRestore(_ dataManager: IDataManager, restored: IProfileManager?) {
        activityIndicator.stopAnimating()
        nameTextField.text = profileManager.name ?? "My name"
        descriptionTextView.text = profileManager.info ?? "About myself"
        profileImageView.image = profileManager.image ?? profileImageView.image
    }
    
    @IBAction func onSaveButtonTap(_ sender: UIButton) {
        let newName = nameTextField.text
        let newInfo = descriptionTextView.text
        let newImage = profileImageView.image
        
        let dataManager = profileManager
        
        if profileManager.update(name: newName, info: newInfo, image: newImage) {
            activityIndicator.startAnimating()
            dataManager.save(profileManager)
            processingDataManager = true
        }
    }
    
    func didSave(_ dataManager: IDataManager, success: Bool) {
        if success {
            activityIndicator.stopAnimating()
            let alertVC = UIAlertController(title: "Данные сохранены", message: nil, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertVC, animated: true, completion: nil)
            processingDataManager = false
            inputDataChanged = false
        } else {
            let alertVC = UIAlertController(title: "Ошибка", message: "Не удалось сохранить данные", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.activityIndicator.stopAnimating()
                self.processingDataManager = false
            }))
            alertVC.addAction(UIAlertAction(title: "Повторить", style: .default, handler: { _ in
                dataManager.save(self.profileManager)
            }))
        }
    }
}


// MARK: - Image Picker View Delegate
extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBAction func onNewImageButton(_ sender: UIButton) {
        let optionsAlertVC = UIAlertController(title: "Выбери изображение профиля", message: nil, preferredStyle: .actionSheet)
        
        typealias AlertActionHandler = (_: UIAlertAction) -> Void
        
        let fromGalleryHandler: AlertActionHandler = { _ in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        optionsAlertVC.addAction(UIAlertAction(title: "Галерея", style: .default, handler: fromGalleryHandler))
        
        let fromCameraHandler: AlertActionHandler = { _ in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        optionsAlertVC.addAction(UIAlertAction(title: "Новое фото", style: .default, handler: fromCameraHandler))
        // видимо в ios11 баг - иногда не появляется navigation bar при выборе галереи.
        // пока что extension это исправляет (иногда cancel прыгает)
        
        let fromInternetHandler: AlertActionHandler = { [weak self] _ in
            guard let imageSearchVC = self?.storyboard?.instantiateViewController(withIdentifier: "imageSearchVC") as? ProfileImageSearchVC else {
                return
            }
            imageSearchVC.delegate = self
            self?.present(imageSearchVC, animated: true, completion: nil)
        }
        optionsAlertVC.addAction(UIAlertAction(title: "Загрузить", style: .default, handler: fromInternetHandler))
        
        optionsAlertVC.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        present(optionsAlertVC, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImageView.contentMode = .scaleAspectFill
            profileImageView.image = pickedImage
            enableButtons()
        }
        
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - ImageSearchVC - from internet - delegate
extension ProfileVC: ImageSearchVCDelegate {
    func didPick(image: UIImage) {
        profileImageView.image = image
        inputDataChanged = true
    }
}


// MARK: - Helper Functions to dismiss keyboard
extension ProfileVC: UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        inputDataChanged = true
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            inputDataChanged = true
            return false
        }
        return true
    }
}
