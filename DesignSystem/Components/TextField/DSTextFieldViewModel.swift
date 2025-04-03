import UIKit

struct DSTextFieldViewModel {
    enum TextFieldType {
        case standard
        case email
        case password
        case decimalPad
        case error
    }
    
    let placeholder: String
    let type: TextFieldType
    let errorMessage: String?
    
    init(placeholder: String,
         type: TextFieldType = .standard,
         errorMessage: String? = nil) {
        self.placeholder = placeholder
        self.type = type
        self.errorMessage = errorMessage
    }
}
