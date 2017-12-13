
import UIKit

extension UITableView {
    func scrollToBottom(animated: Bool = true) {
        let sections = self.numberOfSections
        let rows = self.numberOfRows(inSection: sections - 1)
        if (rows > 0){
            self.scrollToRow(at: IndexPath.init(row: rows-1, section: sections-1), at: .bottom, animated: animated)
        }
    }
}
