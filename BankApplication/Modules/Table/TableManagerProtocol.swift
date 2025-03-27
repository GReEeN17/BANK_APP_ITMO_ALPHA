import UIKit

protocol TableManagerProtocol: AnyObject {
    func update(with models: [TableCellModel])
    func setDelegate(_ delegate: TableManagerDelegate)
}

protocol TableManagerDelegate: AnyObject {
    func didSelectItem(at index: Int)
    func didDeselectItem(at index: Int)
    func refreshData()
}
