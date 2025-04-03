import UIKit

struct DSListCellViewModel {
    let title: String
    let subtitle: String
    let icon: UIImage?
    let isSelected: Bool
    
    init(title: String,
         subtitle: String,
         icon: UIImage? = nil,
         isSelected: Bool = false) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.isSelected = isSelected
    }
}
