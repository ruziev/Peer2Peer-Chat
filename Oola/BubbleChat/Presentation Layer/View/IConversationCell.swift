
import UIKit

protocol IConversationCell: class {
    var nameLabel: UILabel! {get}
    var dateLabel: UILabel! {get}
    var messageLabel: UILabel! {get}
    var backgroundColor: UIColor? {get set}
}
