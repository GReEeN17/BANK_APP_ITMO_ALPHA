import UIKit

struct DSButtonViewModel {
    enum ButtonType {
        case primary
        case secondary
        case error
    }
    
    let title: String
    let type: ButtonType
    let icon: UIImage?
    let isEnabled: Bool
    let isLoading: Bool
    
    init(title: String,
         type: ButtonType = .primary,
         icon: UIImage? = nil,
         isEnabled: Bool = true,
         isLoading: Bool = false) {
        self.title = title
        self.type = type
        self.icon = icon
        self.isEnabled = isEnabled
        self.isLoading = isLoading
    }
}
