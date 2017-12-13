

protocol IStorageManager: class {
    weak var delegate: IStorageManagerDelegate? {get set}
    func save(_ appUser: AppUser)
    func restoreAppUser()
}

protocol IStorageManagerDelegate: class {
    func didSave(_ storageManager: IStorageManager, success: Bool)
    func didRestore(_ storageManager: IStorageManager, restored: AppUser?)
}
