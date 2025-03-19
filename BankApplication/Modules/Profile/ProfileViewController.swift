import UIKit

class ProfileViewController: UIViewController {
    private let user: User

    private let usernameLabel = UILabel()
    private let logoutButton = UIButton(type: .system)

    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.85, green: 1.0, blue: 0.85, alpha: 1.0)

        configureLabel(usernameLabel, text: user.username, fontSize: 24)

        configureButton(logoutButton, title: "Logout", action: #selector(logoutButtonTapped))

        view.addSubview(usernameLabel)
        view.addSubview(logoutButton)

        NSLayoutConstraint.activate([
            usernameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            usernameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),

            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 30),
            logoutButton.widthAnchor.constraint(equalToConstant: 200),
            logoutButton.heightAnchor.constraint(equalToConstant: 40),
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

    @objc private func logoutButtonTapped() {
        if let authVC = navigationController?.viewControllers.first(where: { $0 is AuthViewController }) {
            navigationController?.popToViewController(authVC, animated: true)
        } else {
            let authViewModel = AuthViewModel(authService: AuthManager())
            let authVC = AuthViewController(viewModel: authViewModel)
            navigationController?.setViewControllers([authVC], animated: true)
        }
    }
}
