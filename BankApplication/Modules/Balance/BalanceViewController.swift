import UIKit
import Combine

final class BalanceViewController: UIViewController {
    private let viewModel: BalanceViewModelProtocol
    private let user: User
    private let router: RouterProtocol?
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 0
    
    private let stackView = DSStackView(spacing: DSSpacing.medium)
    
    private lazy var balanceLabel: DSLabel = {
        let label = DSLabel()
        label.configure(with: DSLabelViewModel(
            text: "Loading balance...",
            type: .largeTitle,
            textAlignment: .center
        ))
        return label
    }()
    
    private lazy var transactionsLabel: DSLabel = {
        let label = DSLabel()
        label.configure(with: DSLabelViewModel(
            text: "Transactions will appear here",
            type: .body,
            textAlignment: .center
        ))
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var currencyLabel: DSLabel = {
        let label = DSLabel()
        label.configure(with: DSLabelViewModel(
            text: "Loading currencies...",
            type: .body,
            textAlignment: .center
        ))
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var transferButton: DSButton = {
        let button = DSButton()
        button.configure(with: DSButtonViewModel(
            title: "Transfer Money",
            type: .primary
        ))
        button.addTarget(self, action: #selector(transferButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var loadMoreButton: DSButton = {
        let button = DSButton()
        button.configure(with: DSButtonViewModel(
            title: "Load More",
            type: .secondary
        ))
        button.addTarget(self, action: #selector(loadMoreButtonTapped), for: .touchUpInside)
        return button
    }()
    init(viewModel: BalanceViewModelProtocol, user: User, router: RouterProtocol) {
        self.viewModel = viewModel
        self.user = user
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DSColors.primaryLight
        setupNavigationBar()
        setupUI()
        bindViewModel()
        loadInitialData()
    }
    
    private func setupNavigationBar() {
        let profileButton = DSButton(type: .system)
        profileButton.configure(with: DSButtonViewModel(
            title: "Профиль", type: .secondary, icon: UIImage(systemName: "person.circle.fill"),
        ))
        profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton)
    }
    
    private func setupUI() {
        stackView.axis = .vertical
        stackView.alignment = .center
        
        view.addSubview(stackView)
        
        stackView.addArrangedSubview(balanceLabel)
        stackView.addArrangedSubview(transactionsLabel)
        stackView.addArrangedSubview(currencyLabel)
        stackView.addArrangedSubview(transferButton)
        stackView.addArrangedSubview(loadMoreButton)
        
        stackView.setCustomSpacing(DSSpacing.xLarge, after: balanceLabel)
        stackView.setCustomSpacing(DSSpacing.xLarge, after: transactionsLabel)
        stackView.setCustomSpacing(DSSpacing.xLarge, after: currencyLabel)
        stackView.setCustomSpacing(DSSpacing.large, after: transferButton)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: DSSpacing.xLarge),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DSSpacing.large),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DSSpacing.large),
            
            balanceLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            transactionsLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            currencyLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            transferButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            loadMoreButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            
            transferButton.heightAnchor.constraint(equalToConstant: 44),
            loadMoreButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func bindViewModel() {
        viewModel.balanceResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case .success(let balance):
                    self?.balanceLabel.configure(with: DSLabelViewModel(
                        text: "Balance: \(balance.amount)",
                        type: .largeTitle,
                        textAlignment: .center
                    ))
                case .failure:
                    self?.balanceLabel.configure(with: DSLabelViewModel(
                        text: "Error loading balance",
                        type: .largeTitle,
                        textAlignment: .center
                    ))
                }
            }
            .store(in: &cancellables)
        
        viewModel.transactionsResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case .success(let transactions):
                    let transactionsText = transactions.map { "\($0.receipt): \($0.amount)" }.joined(separator: "\n")
                    self?.transactionsLabel.configure(with: DSLabelViewModel(
                        text: transactionsText.isEmpty ? "No transactions yet" : transactionsText,
                        type: .body,
                        textAlignment: .center
                    ))
                case .failure:
                    self?.transactionsLabel.configure(with: DSLabelViewModel(
                        text: "Error loading transactions",
                        type: .body,
                        textAlignment: .center
                    ))
                }
            }
            .store(in: &cancellables)
        
        viewModel.currenciesResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case .success(let currencies):
                    let currenciesText = currencies.map { "\($0.code): \($0.rate)" }.joined(separator: "\n")
                    let currentText = self?.currencyLabel.text ?? ""
                    self?.currencyLabel.configure(with: DSLabelViewModel(
                        text: currentText.isEmpty ? currenciesText : currentText + "\n" + currenciesText,
                        type: .body,
                        textAlignment: .center
                    ))
                case .failure:
                    self?.currencyLabel.configure(with: DSLabelViewModel(
                        text: "Error loading currencies",
                        type: .body,
                        textAlignment: .center
                    ))
                }
            }
            .store(in: &cancellables)
    }
    
    private func loadInitialData() {
        viewModel.loadBalance(userId: user.id)
        viewModel.loadTransactions(userId: user.id)
        viewModel.loadCurrencies(page: currentPage)
    }
    
    @objc private func loadMoreButtonTapped() {
        currentPage += 1
        viewModel.loadCurrencies(page: currentPage)
    }

    @objc private func transferButtonTapped() {
        router?.showTransferScreen(user: user)
    }
    
    @objc private func profileButtonTapped() {
        router?.showProfileScreen(user: user)
    }
}
