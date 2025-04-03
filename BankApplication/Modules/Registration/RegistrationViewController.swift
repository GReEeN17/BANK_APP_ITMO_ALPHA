import UIKit
import Combine

class RegistrationViewController: UIViewController {
    private let viewModel: RegistrationViewModelProtocol
    private let router: RouterProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private let stackView = DSStackView(spacing: DSSpacing.large)
    private let emailTextField = DSTextField()
    private let usernameTextField = DSTextField()
    private let passwordTextField = DSTextField()
    private let registerButton = DSButton()
    private let errorLabel = DSLabel()
    private let loadingIndicator = DSActivityIndicatorView()

    init(viewModel: RegistrationViewModelProtocol, router: RouterProtocol) {
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
        bindViewModel()
    }
    
    private func setupUI() {
        view.backgroundColor = DSColors.background
        title = "Registration"
        
        stackView.axis = .vertical
        stackView.alignment = .fill
        view.addSubview(stackView)
        
        emailTextField.configure(with: DSTextFieldViewModel(
            placeholder: "Email",
            type: .email,
        ))
        
        usernameTextField.configure(with: DSTextFieldViewModel(
            placeholder: "Username",
            type: .standard,
        ))
        
        passwordTextField.configure(with: DSTextFieldViewModel(
            placeholder: "Password",
            type: .password,
        ))
        
        registerButton.configure(with: DSButtonViewModel(
            title: "Register",
            type: .primary
        ))
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        
        errorLabel.configure(with: DSLabelViewModel(
            text: "",
            type: .error,
        ))
        errorLabel.isHidden = true
        
        loadingIndicator.configure(with: DSActivityIndicatorViewModel(size: .medium))
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
        
        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(usernameTextField)
        stackView.addArrangedSubview(passwordTextField)
        stackView.addArrangedSubview(errorLabel)
        stackView.addArrangedSubview(registerButton)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: DSSpacing.xLarge),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DSSpacing.large),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DSSpacing.large),
            
            emailTextField.heightAnchor.constraint(equalToConstant: DSSpacing.xLarge),
            usernameTextField.heightAnchor.constraint(equalToConstant: DSSpacing.xLarge),
            passwordTextField.heightAnchor.constraint(equalToConstant: DSSpacing.xLarge),
            registerButton.heightAnchor.constraint(equalToConstant: DSSpacing.xLarge),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.registrationResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.loadingIndicator.isHidden = true
                self?.registerButton.isEnabled = true
                
                switch result {
                case .success:
                    self?.router.popViewController(animated: true)
                case .failure(let error):
                    self?.showError(message: error.localizedDescription)
                }
            }
            .store(in: &cancellables)
        
        viewModel.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
                self?.registerButton.isEnabled = !isLoading
            }
            .store(in: &cancellables)
    }
    
    @objc private func registerButtonTapped() {
        errorLabel.isHidden = true
        
        guard let email = emailTextField.text, !email.isEmpty,
              let username = usernameTextField.text, !username.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showError(message: "Please fill in all fields")
            return
        }
        
        viewModel.register(email: email, username: username, password: password)
    }
    
    private func showError(message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }
}
