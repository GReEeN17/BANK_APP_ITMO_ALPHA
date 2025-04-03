import UIKit
import Combine

class TransferViewController: UIViewController {
    private let viewModel: TransferViewModelProtocol
    private let router: RouterProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private let stackView = DSStackView(spacing: DSSpacing.large)
    private let amountTextField = DSTextField()
    private let transferButton = DSButton()
    private let tableView = UITableView()
    private let emptyStateView = DSEmptyStateView()
    private var tableManager: TableManagerProtocol!
    private let refreshControl = UIRefreshControl()

    init(viewModel: TransferViewModelProtocol, router: RouterProtocol, tableManager: TableManagerProtocol) {
        self.viewModel = viewModel
        self.router = router
        self.tableManager = tableManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRefreshControl()
        setupTableManager()
        bindViewModel()
        loadUsers()
    }
    
    private func setupUI() {
        view.backgroundColor = DSColors.background
        
        stackView.axis = .vertical
        stackView.alignment = .fill
        view.addSubview(stackView)
        
        amountTextField.configure(with: DSTextFieldViewModel(
            placeholder: "Enter amount",
            type: .decimalPad
        ))
        
        transferButton.configure(with: DSButtonViewModel(
            title: "Transfer",
            type: .primary
        ))
        transferButton.addTarget(self, action: #selector(transferButtonTapped), for: .touchUpInside)
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsSelection = true
        tableView.refreshControl = refreshControl
        
        emptyStateView.configure(with: DSEmptyStateViewModel(
            title: "No Recipients",
            message: "There are no recipients available",
            image: UIImage(systemName: "person.2.slash")
        ))
        emptyStateView.isHidden = true
        
        stackView.addArrangedSubview(amountTextField)
        stackView.addArrangedSubview(transferButton)
        stackView.addArrangedSubview(tableView)
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: DSSpacing.xLarge),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DSSpacing.large),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DSSpacing.large),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            amountTextField.heightAnchor.constraint(equalToConstant: 44),
            transferButton.heightAnchor.constraint(equalToConstant: 44),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DSSpacing.large),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DSSpacing.large)
        ])
    }
    
    private func setupRefreshControl() {
        refreshControl.tintColor = DSColors.primary
        refreshControl.addTarget(self, action: #selector(refreshUsers), for: .valueChanged)
    }
    
    private func setupTableManager() {
        tableManager = TableManager(tableView: tableView)
        tableManager.registerCell(DSListCell.self, for: DSListCellModel.self)
        tableManager.setDelegate(self)
    }
    
    @objc private func refreshUsers() {
        loadUsers()
    }
    
    @objc private func transferButtonTapped() {
        guard let amount = viewModel.validateAmount(amountTextField.text) else {
            showAlert(message: "Please enter a valid amount.")
            return
        }

        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            let recipient = viewModel.users[selectedIndexPath.row]
            viewModel.transferMoney(from: viewModel.user.id, to: recipient.id, amount: amount)
        } else {
            showAlert(message: "Please select a recipient.")
        }
    }
    
    private func loadUsers() {
        viewModel.getUsers()
    }
    
    private func bindViewModel() {
        viewModel.usersPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] users in
                guard let self = self else { return }
                
                let cellModels = users.map { user in
                    DSListCellModel(
                        id: user.id,
                        title: user.username,
                        subtitle: "Account: \(user.id.prefix(8))",
                        icon: UIImage(systemName: "person.circle"),
                        isSelected: false,
                    )
                }
                
                self.tableManager.update(with: cellModels)
                self.refreshControl.endRefreshing()
                self.emptyStateView.isHidden = !users.isEmpty
                self.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.transferResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case .success:
                    self?.showAlert(message: "Transfer successful!")
                    self?.router.popViewController(animated: true)
                case .failure(let error):
                    self?.showAlert(message: "Transfer failed: \(error.localizedDescription)")
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "OK",
            style: .default
        ))
        present(alert, animated: true)
    }
}

extension TransferViewController: TableManagerDelegate {
    func didSelectItem(at index: Int) {
        if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? DSListCell {
            cell.setSelected(true, animated: true)
        }
    }
    
    func didDeselectItem(at index: Int) {
        if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? DSListCell {
            cell.setSelected(false, animated: true)
        }
    }
    
    func willDisplayItem(at index: Int) {
        if index == viewModel.users.count - 2 {
            loadUsers()
        }
    }
    
    func refreshData() {
        refreshUsers()
    }
}
