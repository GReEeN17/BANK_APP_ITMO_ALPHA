import UIKit

final class TableManager: NSObject {
    private weak var tableView: UITableView?
    private weak var delegate: TableManagerDelegate?
    private var cellModels: [TableCellModelProtocol] = []
    private var registeredCellIdentifiers = Set<String>()
    
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.separatorStyle = .none
        tableView?.backgroundColor = DSColors.background
        
        registerCell(UserCell.self, for: TableCellModel.self)
        registerCell(DSListCell.self, for: DSListCellModel.self)
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = DSColors.primary
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView?.refreshControl = refreshControl
    }
    
    @objc private func refreshData() {
        delegate?.refreshData()
    }
}

extension TableManager: TableManagerProtocol {
    func update(with models: [TableCellModelProtocol]) {
        cellModels = models
        tableView?.refreshControl?.endRefreshing()
        tableView?.reloadData()
    }
    
    func setDelegate(_ delegate: TableManagerDelegate) {
        self.delegate = delegate
    }
    
    func registerCell<Cell: UITableViewCell, Model: TableCellModelProtocol>(
        _ cellType: Cell.Type,
        for modelType: Model.Type
    ) where Cell: ConfigurableCell, Model == Cell.Model {
        let identifier = String(describing: cellType)
        
        if !registeredCellIdentifiers.contains(identifier) {
            tableView?.register(cellType, forCellReuseIdentifier: identifier)
            registeredCellIdentifiers.insert(identifier)
        }
    }
}

extension TableManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = cellModels[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: model.cellIdentifier, for: indexPath)
        model.configure(cell: cell)
        return cell
    }
}

extension TableManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectItem(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        delegate?.didDeselectItem(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        delegate?.willDisplayItem(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellModels[indexPath.row].cellHeight
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellModels[indexPath.row].cellHeight
    }
}

protocol ConfigurableCell: UITableViewCell {
    associatedtype Model: TableCellModelProtocol
    func configure(with model: Model)
}

extension ConfigurableCell {
    func configure(with model: Model) {
        // Default implementation
    }
}
