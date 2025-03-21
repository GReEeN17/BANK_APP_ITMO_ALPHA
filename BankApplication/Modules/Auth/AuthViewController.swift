import UIKit
import Combine

class AuthViewController: UIViewController {
    private let viewModel: AuthViewModelProtocol

    private let usernameTextField = UITextField()
    private let passwordTextField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let registerButton = UIButton(type: .system)
    private let logoutButton = UIButton(type: .system)

    private let emailErrorLabel = UILabel()
    private let passwordErrorLabel = UILabel()
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: AuthViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.85, green: 1.0, blue: 0.85, alpha: 1.0)

        setupUI()
        bindViewModel()
        setupTextFields()
    }

    private func setupUI() {
        configureTextField(usernameTextField, placeholder: "Email")
        configureTextField(passwordTextField, placeholder: "Password")
        passwordTextField.isSecureTextEntry = true

        configureButton(loginButton, title: "Login", action: #selector(loginButtonTapped))
        configureButton(registerButton, title: "Register", action: #selector(registerButtonTapped))
        configureButton(logoutButton, title: "Logout", action: #selector(logoutButtonTapped))

        configureErrorLabel(emailErrorLabel, text: "Invalid email")
        configureErrorLabel(passwordErrorLabel, text: "Password must be at least 6 characters")
        
        emailErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true

        view.addSubview(usernameTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(registerButton)
        view.addSubview(logoutButton)
        view.addSubview(emailErrorLabel)
        view.addSubview(passwordErrorLabel)

        NSLayoutConstraint.activate([
            usernameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            usernameTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            usernameTextField.widthAnchor.constraint(equalToConstant: 250),
            usernameTextField.heightAnchor.constraint(equalToConstant: 40),

            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            passwordTextField.widthAnchor.constraint(equalToConstant: 250),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),

            emailErrorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailErrorLabel.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 5),
            emailErrorLabel.widthAnchor.constraint(equalToConstant: 250),

            passwordErrorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordErrorLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 5),
            passwordErrorLabel.widthAnchor.constraint(equalToConstant: 250),

            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: passwordErrorLabel.bottomAnchor, constant: 30),
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
    
    private func bindViewModel() {
        viewModel.isLoginButtonEnabled
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: loginButton)
            .store(in: &cancellables)

        viewModel.isRegisterButtonEnabled
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: registerButton)
            .store(in: &cancellables)

        viewModel.emailError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.emailErrorLabel.isHidden = error == nil
                self?.emailErrorLabel.text = error
            }
            .store(in: &cancellables)

        viewModel.passwordError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.passwordErrorLabel.isHidden = error == nil
                self?.passwordErrorLabel.text = error
            }
            .store(in: &cancellables)

        viewModel.loginResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case .success(let user):
                    self?.navigateToBalanceScreen(user: user)
                case .failure(_):
                    break
                }
            }
            .store(in: &cancellables)
        
        viewModel.showError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showError(message: errorMessage)
            }
            .store(in: &cancellables)
    }

    private func setupTextFields() {
        usernameTextField.addTarget(self, action: #selector(emailTextFieldDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(passwordTextFieldDidChange), for: .editingChanged)
    }

    @objc private func emailTextFieldDidChange() {
        viewModel.updateEmail(usernameTextField.text)
        emailErrorLabel.isHidden = viewModel.validateEmail(usernameTextField.text)
        updateButtonStates()
    }

    @objc private func passwordTextFieldDidChange() {
        viewModel.updatePassword(passwordTextField.text)
        passwordErrorLabel.isHidden = viewModel.validatePassword(passwordTextField.text)
        updateButtonStates()
    }

    private func updateButtonStates() {
        let isEmailValid = viewModel.validateEmail(usernameTextField.text)
        let isPasswordValid = viewModel.validatePassword(passwordTextField.text)
        loginButton.isEnabled = isEmailValid && isPasswordValid
        registerButton.isEnabled = isEmailValid && isPasswordValid
        loginButton.alpha = loginButton.isEnabled ? 1.0 : 0.5
        registerButton.alpha = registerButton.isEnabled ? 1.0 : 0.5
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

    private func configureErrorLabel(_ label: UILabel, text: String) {
        label.text = text
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 12)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
    }

    @objc private func loginButtonTapped() {
        guard let email = usernameTextField.text, let password = passwordTextField.text else { return }
        viewModel.login(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self?.navigateToBalanceScreen(user: user)
                case .failure(_):
                    break
                }
            }
        }
    }

    @objc private func registerButtonTapped() {
        let registrationViewModel = RegistrationViewModel(authService: AuthManager())
        let registrationVC = RegistrationViewController(viewModel: registrationViewModel)
        navigationController?.pushViewController(registrationVC, animated: true)
    }

    @objc private func logoutButtonTapped() {
        viewModel.logout { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.navigateToAuthScreen()
                case .failure(_):
                    break
                }
            }
        }
    }

    private func navigateToBalanceScreen(user: User) {
        let balanceManager = BalanceManager(users: [user])
        let currencyManager = CurrencyManager()
        let balanceViewModel = BalanceViewModel(balanceManager: balanceManager, currencyManager: currencyManager)
        let balanceVC = BalanceViewController(viewModel: balanceViewModel, user: user)
        navigationController?.pushViewController(balanceVC, animated: true)
    }

    private func navigateToAuthScreen() {
        let authViewModel = AuthViewModel(authService: AuthManager())
        let authVC = AuthViewController(viewModel: authViewModel)
        navigationController?.setViewControllers([authVC], animated: true)
    }

    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
