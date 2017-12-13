
import UIKit
protocol IMessageCell: class {
    var label: UILabel! {get set}
    func layoutIncoming()
    func layoutOutgoing()
}
