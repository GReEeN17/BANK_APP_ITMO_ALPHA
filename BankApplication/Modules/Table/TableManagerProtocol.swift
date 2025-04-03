import UIKit

protocol TableManagerProtocol: AnyObject {
    func update(with models: [TableCellModelProtocol])
    func setDelegate(_ delegate: TableManagerDelegate)
    func registerCell<Cell: UITableViewCell, Model: TableCellModelProtocol>(
        _ cellType: Cell.Type,
        for modelType: Model.Type
    ) where Cell: ConfigurableCell, Model == Cell.Model
}

protocol TableManagerDelegate: AnyObject {
    func didSelectItem(at index: Int)
    func didDeselectItem(at index: Int)
    func willDisplayItem(at index: Int)
    func refreshData()
}
