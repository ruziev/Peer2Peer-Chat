
import UIKit

protocol IDataManager {
    func save(_ profileManager: IProfileManager)
    func restore()
    weak var delegate: IDataManagerDelegate? {get set}
}

