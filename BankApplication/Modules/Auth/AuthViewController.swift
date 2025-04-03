import UIKit
import Combine

class AuthViewController: UIViewController {
    private let viewModel: AuthViewModelProtocol
    private let router: RouterProtocol?
    private var cancellables = Set<AnyCancellable>()
    
    private let stackView = DSStackView(spacing: DSSpacing.medium)
    
    private lazy var emailTextField: DSTextField = {
        let textField = DSTextField()
        textField.configure(with: DSTextFieldViewModel(
            placeholder: "Email",
            type: .email
        ))
        return textField
    }()
    
    private lazy var passwordTextField: DSTextField = {
        let textField = DSTextField()
        textField.configure(with: DSTextFieldViewModel(
            placeholder: "Password",
            type: .password
        ))
        return textField
    }()
    
    private lazy var emailErrorLabel: DSLabel = {
        let label = DSLabel()
        label.configure(with: DSLabelViewModel(
            text: "Invalid email",
            type: .error,
            textAlignment: .left
        ))
        label.isHidden = true
        return label
    }()
    
    private lazy var passwordErrorLabel: DSLabel = {
        let label = DSLabel()
        label.configure(with: DSLabelViewModel(
            text: "Password must be at least 6 characters",
            type: .error,
            textAlignment: .left
        ))
        label.isHidden = true
        return label
    }()
    
    private lazy var loginButton: DSButton = {
        let button = DSButton()
        button.configure(with: DSButtonViewModel(
            title: "Login",
            type: .primary
        ))
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var registerButton: DSButton = {
        let button = DSButton()
        button.configure(with: DSButtonViewModel(
            title: "Register",
            type: .secondary
        ))
        button.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var logoutButton: DSButton = {
        let button = DSButton()
        button.configure(with: DSButtonViewModel(
            title: "Logout",
            type: .error
        ))
        button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        return button
    }()
    
    init(viewModel: AuthViewModelProtocol, router: RouterProtocol) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DSColors.primaryLight
        setupUI()
        bindViewModel()
        setupTextFields()
    }
    
    private func setupUI() {
        stackView.axis = .vertical
        stackView.alignment = .fill
        view.addSubview(stackView)
        
        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(emailErrorLabel)
        stackView.addArrangedSubview(passwordTextField)
        stackView.addArrangedSubview(passwordErrorLabel)
        stackView.addArrangedSubview(loginButton)
        stackView.addArrangedSubview(registerButton)
        stackView.addArrangedSubview(logoutButton)
        
        stackView.setCustomSpacing(DSSpacing.small, after: emailTextField)
        stackView.setCustomSpacing(DSSpacing.small, after: passwordTextField)
        stackView.setCustomSpacing(DSSpacing.xLarge, after: passwordErrorLabel)
        stackView.setCustomSpacing(DSSpacing.large, after: loginButton)
        stackView.setCustomSpacing(DSSpacing.large, after: registerButton)
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DSSpacing.large),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DSSpacing.large),
            
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            loginButton.heightAnchor.constraint(equalToConstant: 44),
            registerButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func bindViewModel() {
        viewModel.isLoginButtonEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.loginButton.configure(with: DSButtonViewModel(
                    title: "Login",
                    type: .primary,
                    isEnabled: isEnabled
                ))
            }
            .store(in: &cancellables)

        viewModel.isRegisterButtonEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.registerButton.configure(with: DSButtonViewModel(
                    title: "Register",
                    type: .secondary,
                    isEnabled: isEnabled
                ))
            }
            .store(in: &cancellables)

        viewModel.emailError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.emailErrorLabel.isHidden = error == nil
                if let error = error {
                    self?.emailErrorLabel.configure(with: DSLabelViewModel(
                        text: error,
                        type: .error,
                        textAlignment: .left
                    ))
                }
            }
            .store(in: &cancellables)

        viewModel.passwordError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.passwordErrorLabel.isHidden = error == nil
                if let error = error {
                    self?.passwordErrorLabel.configure(with: DSLabelViewModel(
                        text: error,
                        type: .error,
                        textAlignment: .left
                    ))
                }
            }
            .store(in: &cancellables)

        viewModel.loginResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case .success(let user):
                    self?.navigateToBalanceScreen(user: user)
                case .failure(let error):
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
        emailTextField.addTarget(self, action: #selector(emailTextFieldDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(passwordTextFieldDidChange), for: .editingChanged)
    }
    
    @objc private func emailTextFieldDidChange() {
        viewModel.updateEmail(emailTextField.text)
    }

    @objc private func passwordTextFieldDidChange() {
        viewModel.updatePassword(passwordTextField.text)
    }

    @objc private func loginButtonTapped() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        viewModel.login(email: email, password: password)
    }

    @objc private func registerButtonTapped() {
        router?.showRegistrationScreen()
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
        router?.showBalanceScreen(user: user)
    }

    private func navigateToAuthScreen() {
        router?.showAuthScreen()
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
