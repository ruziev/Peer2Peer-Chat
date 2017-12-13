

import UIKit

class ProfileManager : IProfileManager {
    weak var delegate: IDataManagerDelegate?
    var appUser: AppUser?
    var storageManager: IStorageManager! {
        didSet {
            storageManager.delegate = self
        }
    }
    
    var image: UIImage? {
        if let data = appUser?.user?.image {
            return UIImage(data: data)
        } else {
            return nil
        }
    }
    var name: String? {
        return appUser?.user?.name
    }
    var info: String? {
        return appUser?.user?.info
    }
    
    func update(name: String? = nil, info: String? = nil, image: UIImage? = nil) -> Bool {
        var hasChanged = false
        if let newName = name, newName != self.name {
            self.appUser?.user?.name = newName
            hasChanged = true
        }
        if let newInfo = info, newInfo != self.info {
            self.appUser?.user?.info = newInfo
            hasChanged = true
        }
        if let newImage = image, newImage != self.image {
            self.appUser?.user?.image = UIImagePNGRepresentation(newImage)
            hasChanged = true
        }
        return hasChanged
    }

}

extension ProfileManager : IDataManager {
    func save(_ profileManager: IProfileManager) {
        if let appUser = self.appUser {
            storageManager.save(appUser)
        }
    }
    
    func restore() {
        storageManager.restoreAppUser()
    }
}

extension ProfileManager : IStorageManagerDelegate {
    func didSave(_ storageManager: IStorageManager, success: Bool) {
        DispatchQueue.main.async {
            self.delegate?.didSave(self, success: success)
        }
    }
    
    func didRestore(_ storageManager: IStorageManager, restored: AppUser?) {
        appUser = restored
        DispatchQueue.main.async {
            self.delegate?.didRestore(self, restored: self)
        }
    }
}
