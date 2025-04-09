import UIKit

struct DSLabelViewModel {
    enum LabelType {
        case largeTitle
        case title
        case body
        case caption
        case error
    }
    
    let text: String
    let type: LabelType
    let textAlignment: NSTextAlignment
    
    init(text: String,
         type: LabelType = .body,
         textAlignment: NSTextAlignment = .left) {
        self.text = text
        self.type = type
        self.textAlignment = textAlignment
    }
}
