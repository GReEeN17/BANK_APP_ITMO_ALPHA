import UIKit

struct DSListCellModel: TableCellModelProtocol {
    let id: String
    let title: String
    let subtitle: String
    let icon: UIImage?
    var isSelected: Bool
    
    var cellIdentifier: String {
        return String(describing: DSListCell.self)
    }
    
    var cellHeight: CGFloat {
        return 72
    }
    
    var selectionStyle: UITableViewCell.SelectionStyle {
        return .default
    }
    
    func configure(cell: UITableViewCell) {
        guard let cell = cell as? DSListCell else { return }
        cell.configure(with: self)
    }
}
