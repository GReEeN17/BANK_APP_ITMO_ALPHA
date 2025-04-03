import UIKit

final class TableManager: NSObject {
    private weak var tableView: UITableView?
    private weak var delegate: TableManagerDelegate?
    private var cellModels: [TableCellModel] = []
    
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.register(GenericTableViewCell<UserCellView>.self, forCellReuseIdentifier: "UserCell")
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView?.refreshControl = refreshControl
    }
    
    @objc private func refreshData() {
        delegate?.refreshData()
    }
}

extension TableManager: TableManagerProtocol {
    func update(with models: [TableCellModel]) {
        cellModels = models
        tableView?.refreshControl?.endRefreshing()
        tableView?.reloadData()
    }
    
    func setDelegate(_ delegate: TableManagerDelegate) {
        self.delegate = delegate
    }
}

extension TableManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "UserCell",
            for: indexPath
        ) as? GenericTableViewCell<UserCellView> else {
            return UITableViewCell()
        }
        
        let model = cellModels[indexPath.row]
        cell.configure(with: model.viewModel)
        return cell
    }
}

extension TableManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectItem(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
