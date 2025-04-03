import Foundation
import UIKit

protocol TableCellModelProtocol {
    var cellIdentifier: String { get }
    var cellHeight: CGFloat { get }
    var selectionStyle: UITableViewCell.SelectionStyle { get }
    func configure(cell: UITableViewCell)
}

extension TableCellModelProtocol {
    var cellHeight: CGFloat { return UITableView.automaticDimension }
    var selectionStyle: UITableViewCell.SelectionStyle { return .default }
}
