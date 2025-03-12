import UIKit

class AuthViewController: UIViewController {
    private let viewModel: AuthViewModel

    private let usernameTextField = UITextField()
    private let passwordTextField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let registerButton = UIButton(type: .system)
    private let logoutButton = UIButton(type: .system)

    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.85, green: 1.0, blue: 0.85, alpha: 1.0)

        configureTextField(usernameTextField, placeholder: "Username")
        configureTextField(passwordTextField, placeholder: "Password")
        passwordTextField.isSecureTextEntry = true
        configureButton(loginButton, title: "Login", action: #selector(loginButtonTapped))
        configureButton(registerButton, title: "Register", action: #selector(registerButtonTapped))
        configureButton(logoutButton, title: "Logout", action: #selector(logoutButtonTapped))

        view.addSubview(usernameTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(registerButton)
        view.addSubview(logoutButton)

        NSLayoutConstraint.activate([
            usernameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            usernameTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            usernameTextField.widthAnchor.constraint(equalToConstant: 250),
            usernameTextField.heightAnchor.constraint(equalToConstant: 40),

            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            passwordTextField.widthAnchor.constraint(equalToConstant: 250),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),

            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            loginButton.widthAnchor.constraint(equalToConstant: 200),
            loginButton.heightAnchor.constraint(equalToConstant: 40),

            registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            registerButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            registerButton.widthAnchor.constraint(equalToConstant: 200),
            registerButton.heightAnchor.constraint(equalToConstant: 40),

            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 20),
            logoutButton.widthAnchor.constraint(equalToConstant: 200),
            logoutButton.heightAnchor.constraint(equalToConstant: 40),
        ])
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

    @objc private func loginButtonTapped() {
        guard let username = usernameTextField.text, let password = passwordTextField.text else { return }
        viewModel.login(username: username, password: password) { result in
            switch result {
            case .success(let user):
                print("User logged in: \(user.username)")
                self.navigateToBalanceScreen(user: user)
            case .failure(let error):
                print("Login failed: \(error.localizedDescription)")
            }
        }
    }

    @objc private func registerButtonTapped() {
        guard let username = usernameTextField.text, let password = passwordTextField.text else { return }
        viewModel.register(username: username, password: password) { result in
            switch result {
            case .success(let user):
                print("User registered: \(user.username)")
                self.navigateToBalanceScreen(user: user)
            case .failure(let error):
                print("Registration failed: \(error.localizedDescription)")
            }
        }
    }

    @objc private func logoutButtonTapped() {
        viewModel.logout { result in
            switch result {
            case .success:
                print("User logged out")
            case .failure(let error):
                print("Logout failed: \(error.localizedDescription)")
            }
        }
    }

    private func navigateToBalanceScreen(user: User) {
        let users = [
            User(id: "1", username: "user1", password: "password1"),
            User(id: "2", username: "user2", password: "password2"),
            User(id: "3", username: "user3", password: "password3")
        ]
        let balanceManager = BalanceManager(users: users)
        let balanceViewModel = BalanceViewModel(balanceManager: balanceManager)
        let balanceVC = BalanceViewController(viewModel: balanceViewModel, user: user)
        
        self.navigationController?.pushViewController(balanceVC, animated: true)
    }
}
