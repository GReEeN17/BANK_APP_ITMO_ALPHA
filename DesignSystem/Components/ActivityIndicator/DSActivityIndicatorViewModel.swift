import UIKit

struct DSActivityIndicatorViewModel {
    enum Size {
        case small
        case medium
        case large
        
        var value: CGFloat {
            switch self {
            case .small: return 20
            case .medium: return 30
            case .large: return 40
            }
        }
    }
    
    let size: Size
    let color: UIColor?
    
    init(size: Size = .medium, color: UIColor? = DSColors.primary) {
        self.size = size
        self.color = color
    }
}
