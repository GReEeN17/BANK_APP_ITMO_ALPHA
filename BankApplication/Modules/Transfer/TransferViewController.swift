import UIKit
import Combine

class TransferViewController: UIViewController {
    private let viewModel: TransferViewModelProtocol
    private var cancellables = Set<AnyCancellable>()

    private let tableView = UITableView()
    private let amountTextField = UITextField()
    private let transferButton = UIButton(type: .system)
    private var tableManager: TableManager!

    init(viewModel: TransferViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.85, green: 1.0, blue: 0.85, alpha: 1.0)

        configureTextField(amountTextField, placeholder: "Enter amount")
        configureButton(transferButton, title: "Transfer", action: #selector(transferButtonTapped))

        tableManager = TableManager(tableView: tableView)
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(amountTextField)
        view.addSubview(transferButton)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            amountTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            amountTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            amountTextField.widthAnchor.constraint(equalToConstant: 200),
            amountTextField.heightAnchor.constraint(equalToConstant: 40),

            transferButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            transferButton.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 20),
            transferButton.widthAnchor.constraint(equalToConstant: 200),
            transferButton.heightAnchor.constraint(equalToConstant: 40),

            tableView.topAnchor.constraint(equalTo: transferButton.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        bindViewModel()
        loadUsers()
    }

    private func bindViewModel() {
        viewModel.usersPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] users in
                let cellModels = users.map { TableCellModel(title: $0.username, isSelected: false) }
                self?.tableManager.update(with: cellModels)
            }
            .store(in: &cancellables)

        viewModel.transferResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case .success:
                    self?.showAlert(message: "Transfer successful!")
                case .failure(let error):
                    self?.showAlert(message: "Transfer failed: \(error.localizedDescription)")
                }
            }
            .store(in: &cancellables)
    }

    private func configureTextField(_ textField: UITextField, placeholder: String) {
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .white
        textField.textColor = UIColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0)
        textField.layer.borderColor = UIColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0).cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 8.0
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowOffset = CGSize(width: 0, height: 2)
        textField.layer.shadowOpacity = 0.1
        textField.layer.shadowRadius = 4.0
        textField.translatesAutoresizingMaskIntoConstraints = false
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

    private func loadUsers() {
        viewModel.getUsers()
    }

    @objc private func transferButtonTapped() {
        guard let amount = viewModel.validateAmount(amountTextField.text) else {
            showAlert(message: "Please enter a valid amount.")
            return
        }

        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            let recipient = viewModel.users[selectedIndexPath.row]
            viewModel.transferMoney(from: viewModel.user.id, to: recipient.id, amount: amount) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.showAlert(message: "Transfer successful!")
                    case .failure(let error):
                        self?.showAlert(message: "Transfer failed: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            showAlert(message: "Please select a recipient.")
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
