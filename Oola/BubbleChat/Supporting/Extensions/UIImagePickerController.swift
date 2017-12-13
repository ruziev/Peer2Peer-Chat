
import UIKit

extension UIImagePickerController {
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.navigationBar.topItem?.rightBarButtonItem?.tintColor = UIColor.blue
        self.navigationBar.topItem?.rightBarButtonItem?.isEnabled = true
    }
}
