
import UIKit

struct MessageDisplayModel {
    var text: String
    var date: Date
    var type: MessageDisplayModelType
}

enum MessageDisplayModelType {
    case incoming
    case outgoing
}

extension MessageDisplayModel {
    // for IMessageCell
    func prepareCell(cell: IMessageCell) {
        cell.label.text = text
    }
    
    func layoutCell(cell: IMessageCell) {
        switch type {
        case .incoming:
            cell.layoutIncoming()
        case .outgoing:
            cell.layoutOutgoing()
        }
    }
}
