import UIKit
import Combine

final class ListViewController: UIViewController {
    private let viewModel: ListViewModelProtocol
    private let router: RouterProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = DSColors.background
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = DSColors.primary
        control.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return control
    }()
    
    private lazy var emptyStateView: DSEmptyStateView = {
        let view = DSEmptyStateView()
        view.configure(with: DSEmptyStateViewModel(
            title: "No Items",
            message: "There are no items to display",
            image: UIImage(systemName: "list.bullet")
        ))
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var tableManager: TableManagerProtocol?
    
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
        view.backgroundColor = DSColors.background
        title = viewModel.screenTitle
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(didTapAddButton)
        )
        navigationItem.rightBarButtonItem?.tintColor = DSColors.primary
        
        tableView.refreshControl = refreshControl
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DSSpacing.large),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DSSpacing.large)
        ])
    }
    
    private func setupTableManager() {
        let manager = TableManager(tableView: tableView)
        manager.registerCell(DSListCell.self, for: DSListCellModel.self)
        manager.setDelegate(self)
        self.tableManager = manager
    }
    
    private func bindViewModel() {
        viewModel.itemsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.refreshControl.endRefreshing()
                self?.tableManager?.update(with: items)
                self?.emptyStateView.isHidden = !items.isEmpty
            }
            .store(in: &cancellables)
        
        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                isLoading ? self?.refreshControl.beginRefreshing() : self?.refreshControl.endRefreshing()
            }
            .store(in: &cancellables)
        
        viewModel.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                guard let self = self else { return }
                self.showErrorAlert(message: errorMessage)
            }
            .store(in: &cancellables)
    }
    
    @objc internal func refreshData() {
        viewModel.refreshData()
    }
    
    @objc private func didTapAddButton() {
        viewModel.didTapAdd()
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ListViewController: TableManagerDelegate {
    func willDisplayItem(at index: Int) {
        viewModel.willDisplayItem(at: index)
    }
    func didSelectItem(at index: Int) {
        viewModel.didSelectItem(at: index)
    }
    
    func didDeselectItem(at index: Int) {
        viewModel.didDeselectItem(at: index)
    }
}
