import UIKit

struct DSEmptyStateViewModel {
    let title: String
    let message: String
    let image: UIImage?
    let actionTitle: String?
    
    init(title: String,
         message: String,
         image: UIImage? = nil,
         actionTitle: String? = nil) {
        self.title = title
        self.message = message
        self.image = image
        self.actionTitle = actionTitle
    }
}
