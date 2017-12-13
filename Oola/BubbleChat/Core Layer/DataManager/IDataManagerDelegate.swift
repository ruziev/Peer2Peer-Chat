

import UIKit

protocol IDataManagerDelegate: class {
    func didSave(_ dataManager: IDataManager, success: Bool)
    func didRestore(_ dataManager: IDataManager, restored: IProfileManager?)
}


