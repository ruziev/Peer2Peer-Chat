

import UIKit

class StorageManager: IStorageManager {
    weak var delegate: IStorageManagerDelegate?
    var coreDataStack: CoreDataStack!
    
    func save(_ appUser: AppUser) {
        guard let saveContext = coreDataStack.saveContext else {
            assert(false, "Save context is not available")
        }
        coreDataStack.performSave(context: saveContext) { [weak self] in
            if let strongSelf = self {
                strongSelf.delegate?.didSave(strongSelf, success: true)
            }
        }
    }
    
    func restoreAppUser() {
        // object passed to delegate is in saveContext
        guard let saveContext = coreDataStack.saveContext else {
            assert(false, "Save context is not available")
        }
        let appUser = AppUser.findOrInsertAppUser(in: saveContext)
        coreDataStack.performSave(context: saveContext) { [weak self] in
            if let strongSelf = self {
                strongSelf.delegate?.didRestore(strongSelf, restored: appUser)
            }
        }
    }
}
