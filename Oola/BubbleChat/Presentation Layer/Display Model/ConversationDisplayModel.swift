
import Foundation
import UIKit

struct ConversationDisplayModel {
    var username: String
    var lastMessage: String?
    var date: Date?
    var online: Bool
    var hasUnreadMessages: Bool
}

extension ConversationDisplayModel {
    // IConversationCell
    func prepareCell(cell: IConversationCell) {
        cell.nameLabel.text = username
        if let lastMessage = lastMessage {
            cell.messageLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .regular)
            cell.messageLabel.text = lastMessage
        } else {
            cell.messageLabel.font = UIFont(name: "Courier", size: 14.0)
            cell.messageLabel.text = "No messages yet"
            // why font change won't apply ?
        }
        if let date = date {
            if date.timeIntervalSinceNow > -3600*24.0 {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm"
                cell.dateLabel.text = dateFormatter.string(from: date)
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMM"
                cell.dateLabel.text = dateFormatter.string(from: date)
            }
        } else {
            cell.dateLabel.text = ""
        }
        if online {
            cell.backgroundColor = UIColor(rgb: 0xf1c40f, alpha: 0.2)
        } else {
            cell.backgroundColor = UIColor.white
        }
        if hasUnreadMessages {
            cell.messageLabel.font = UIFont.boldSystemFont(ofSize: cell.messageLabel.font.pointSize)
            cell.messageLabel.textColor = UIColor(white: 0, alpha: 0.9)
        } else {
            cell.messageLabel.font = UIFont.systemFont(ofSize: cell.messageLabel.font.pointSize)
            cell.messageLabel.textColor = UIColor.darkGray
        }
    }
}
