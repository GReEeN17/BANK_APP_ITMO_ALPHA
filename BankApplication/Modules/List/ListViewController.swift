import UIKit

final class ListViewController: UIViewController {
    private let tableView = UITableView()
    private var tableManager: TableManagerProtocol?
    private var viewModel: ListViewModelProtocol
    private let router: RouterProtocol
    
    init(viewModel: ListViewModelProtocol, router: RouterProtocol) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableManager()
        bindViewModel()
        viewModel.viewDidLoad()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTableManager() {
        let manager = TableManager(tableView: tableView)
        manager.setDelegate(self)
        self.tableManager = manager
    }
    
    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] models in
            self?.tableManager?.update(with: models)
        }
    }
}

extension ListViewController: TableManagerDelegate {
    func didSelectItem(at index: Int) {
        viewModel.didSelectItem(at: index)
    }
    
    func didDeselectItem(at index: Int) {
        viewModel.didDeselectItem(at: index)
    }
    
    func refreshData() {
        viewModel.refreshData()
    }
}
