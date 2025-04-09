import UIKit

class ProfileViewController: UIViewController {
    private let user: User
    private let router: RouterProtocol
    
    private let stackView = DSStackView(spacing: DSSpacing.xLarge)
    private let usernameLabel = DSLabel()
    private let emailLabel = DSLabel()
    private let logoutButton = DSButton()
    private let avatarImageView = UIImageView()
    init(user: User, router: RouterProtocol) {
        self.user = user
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = DSColors.background
        title = "Profile"
        
        stackView.axis = .vertical
        stackView.alignment = .center
        view.addSubview(stackView)
        
        avatarImageView.image = UIImage(systemName: "person.circle.fill")
        avatarImageView.tintColor = DSColors.primary
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        
        usernameLabel.configure(with: DSLabelViewModel(
            text: user.username,
            type: .title,
        ))
        
        emailLabel.configure(with: DSLabelViewModel(
            text: user.email,
            type: .body,
        ))
        
        logoutButton.configure(with: DSButtonViewModel(
            title: "Logout",
            type: .error
        ))
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        
        stackView.addArrangedSubview(avatarImageView)
        stackView.addArrangedSubview(usernameLabel)
        stackView.addArrangedSubview(emailLabel)
        stackView.addArrangedSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DSSpacing.large),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DSSpacing.large),
            
            avatarImageView.widthAnchor.constraint(equalToConstant: 100),
            avatarImageView.heightAnchor.constraint(equalToConstant: 100),
            
            logoutButton.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            logoutButton.heightAnchor.constraint(equalToConstant: DSSpacing.xLarge)
        ])
    }

    @objc private func logoutButtonTapped() {
        let alert = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to logout?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel
        ))
        
        alert.addAction(UIAlertAction(
            title: "Logout",
            style: .destructive,
            handler: { [weak self] _ in
                self?.router.popToRootViewController(animated: true)
            }
        ))
        
        present(alert, animated: true)
    }
}
