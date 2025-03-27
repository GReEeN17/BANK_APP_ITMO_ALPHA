import UIKit

class BalanceViewController: UIViewController {
    private let viewModel: BalanceViewModelProtocol
    private let user: User
    private let router: RouterProtocol?

    private let balanceLabel = UILabel()
    private let transactionsLabel = UILabel()
    private let transferButton = UIButton(type: .system)
    private let currencyLabel = UILabel()
    private let loadMoreButton = UIButton(type: .system)
    
    private var currentPage = 0

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
        view.backgroundColor = UIColor(red: 0.85, green: 1.0, blue: 0.85, alpha: 1.0)

        setupUI()
        loadBalanceAndTransactions()
        loadCurrencies(page: currentPage)
    }
    
    private func setupUI() {
        let profileButton = UIButton(type: .system)
        profileButton.setImage(UIImage(systemName: "person.circle.fill"), for: .normal)
        profileButton.tintColor = UIColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0)
        profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        profileButton.translatesAutoresizingMaskIntoConstraints = false

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton)

        configureLabel(balanceLabel, text: "Loading balance...", fontSize: 24)
        configureLabel(transactionsLabel, text: "Transactions will appear here", fontSize: 18)
        configureLabel(currencyLabel, text: "Loading currencies...", fontSize: 18)
        transactionsLabel.numberOfLines = 0
        currencyLabel.numberOfLines = 0

        configureButton(transferButton, title: "Transfer Money", action: #selector(transferButtonTapped))
        configureButton(loadMoreButton, title: "Load More", action: #selector(loadMoreButtonTapped))

        view.addSubview(balanceLabel)
        view.addSubview(transactionsLabel)
        view.addSubview(transferButton)
        view.addSubview(currencyLabel)
        view.addSubview(loadMoreButton)

        NSLayoutConstraint.activate([
            balanceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            balanceLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),

            transactionsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            transactionsLabel.topAnchor.constraint(equalTo: balanceLabel.bottomAnchor, constant: 20),
            transactionsLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),

            currencyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currencyLabel.topAnchor.constraint(equalTo: transactionsLabel.bottomAnchor, constant: 20),
            currencyLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),

            transferButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            transferButton.topAnchor.constraint(equalTo: currencyLabel.bottomAnchor, constant: 30),
            transferButton.widthAnchor.constraint(equalToConstant: 200),
            transferButton.heightAnchor.constraint(equalToConstant: 40),

            loadMoreButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadMoreButton.topAnchor.constraint(equalTo: transferButton.bottomAnchor, constant: 20),
            loadMoreButton.widthAnchor.constraint(equalToConstant: 200),
            loadMoreButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }

    private func configureLabel(_ label: UILabel, text: String, fontSize: CGFloat) {
        label.text = text
        label.textAlignment = .center
        label.textColor = UIColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0)
        label.font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureButton(_ button: UIButton, title: String, action: Selector) {
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8.0
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 4.0
        button.translatesAutoresizingMaskIntoConstraints = false
    }

    private func loadBalanceAndTransactions() {
        viewModel.getBalance(userId: user.id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let balance):
                    self?.balanceLabel.text = "Balance: \(balance.amount)"
                    self?.loadTransactions()
                case .failure(let error):
                    self?.balanceLabel.text = "Error loading balance"
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }

    private func loadTransactions() {
        viewModel.getTransactions(userId: user.id) { [weak self] (result: Result<[Transaction], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let transactions):
                    let transactionsText = transactions.map { "\($0.receipt): \($0.amount)" }.joined(separator: "\n")
                    self?.transactionsLabel.text = transactionsText.isEmpty ? "No transactions yet" : transactionsText
                case .failure(let error):
                    self?.transactionsLabel.text = "Error loading transactions"
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func loadMoreButtonTapped() {
        currentPage += 1
        loadCurrencies(page: currentPage)
    }

    private func loadCurrencies(page: Int) {
        viewModel.fetchCurrencies(page: page) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let currencies):
                    let currenciesText = currencies.map { "\($0.code): \($0.rate)" }.joined(separator: "\n")
                    self?.currencyLabel.text = (self?.currencyLabel.text ?? "") + "\n" + currenciesText
                case .failure(let error):
                    self?.currencyLabel.text = "Error loading currencies"
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }

    @objc private func transferButtonTapped() {
        router?.showTransferScreen(user: user)
    }
    
    @objc private func profileButtonTapped() {
        router?.showProfileScreen(user: user)
    }
}
