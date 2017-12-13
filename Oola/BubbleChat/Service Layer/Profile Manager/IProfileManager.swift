
import UIKit

protocol IProfileManager: IDataManager, IStorageManagerDelegate {
    var image: UIImage? {get}
    var name: String? {get}
    var info: String? {get}
    func update(name: String?, info: String?, image: UIImage?) -> Bool
}
