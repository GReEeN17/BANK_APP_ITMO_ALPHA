import UIKit

class BalanceViewController: UIViewController {
    private let viewModel: BalanceViewModel
    private let user: User

    private let balanceLabel = UILabel()
    private let transactionsLabel = UILabel()
    private let transferButton = UIButton(type: .system)

    init(viewModel: BalanceViewModel, user: User) {
        self.viewModel = viewModel
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.85, green: 1.0, blue: 0.85, alpha: 1.0)

        let profileButton = UIButton(type: .system)
        profileButton.setImage(UIImage(systemName: "person.circle.fill"), for: .normal)
        profileButton.tintColor = UIColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0)
        profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        profileButton.translatesAutoresizingMaskIntoConstraints = false

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton)

        configureLabel(balanceLabel, text: "Loading balance...", fontSize: 24)
        configureLabel(transactionsLabel, text: "Transactions will appear here", fontSize: 18)
        transactionsLabel.numberOfLines = 0

        configureButton(transferButton, title: "Transfer Money", action: #selector(transferButtonTapped))

        view.addSubview(balanceLabel)
        view.addSubview(transactionsLabel)
        view.addSubview(transferButton)

        NSLayoutConstraint.activate([
            balanceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            balanceLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),

            transactionsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            transactionsLabel.topAnchor.constraint(equalTo: balanceLabel.bottomAnchor, constant: 20),
            transactionsLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),

            transferButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            transferButton.topAnchor.constraint(equalTo: transactionsLabel.bottomAnchor, constant: 30),
            transferButton.widthAnchor.constraint(equalToConstant: 200),
            transferButton.heightAnchor.constraint(equalToConstant: 40),
        ])

        loadBalanceAndTransactions()
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

    private func loadTransactions() {
        viewModel.getTransactions(userId: user.id) { [weak self] (result: Result<[Transaction], Error>) in
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

    @objc private func transferButtonTapped() {
        let users = [
            User(id: "1", username: "user1", password: "password1"),
            User(id: "2", username: "user2", password: "password2"),
            User(id: "3", username: "user3", password: "password3")
        ]
        let balanceManager = BalanceManager(users: users)
        let transferViewModel = TransferViewModel(balanceManager: balanceManager, users: users)
        let transferVC = TransferViewController(viewModel: transferViewModel, user: user)
        self.navigationController?.pushViewController(transferVC, animated: true)
    }
    
    @objc private func profileButtonTapped() {
        let profileVC = ProfileViewController(user: user)
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
}
