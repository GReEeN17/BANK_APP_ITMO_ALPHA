import UIKit

final class DSEmptyStateView: UIView {
    private let stackView = DSStackView(axis: .vertical, spacing: DSSpacing.medium)
    private let imageView = UIImageView()
    private let titleLabel = DSLabel()
    private let messageLabel = DSLabel()
    private let actionButton = DSButton()
    
    var onAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with viewModel: DSEmptyStateViewModel) {
        titleLabel.configure(with: DSLabelViewModel(
            text: viewModel.title,
            type: .title,
            textAlignment: .center
        ))
        
        messageLabel.configure(with: DSLabelViewModel(
            text: viewModel.message,
            type: .body,
            textAlignment: .center
        ))
        
        imageView.image = viewModel.image
        imageView.tintColor = DSColors.textSecondary
        
        if let actionTitle = viewModel.actionTitle {
            actionButton.configure(with: DSButtonViewModel(
                title: actionTitle,
                type: .secondary
            ))
            actionButton.isHidden = false
        } else {
            actionButton.isHidden = true
        }
    }
    
    private func setupUI() {
        stackView.alignment = .center
        
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        actionButton.isHidden = true
        actionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(actionButton)
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: DSSpacing.large),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -DSSpacing.large),
            
            actionButton.widthAnchor.constraint(equalToConstant: 200),
            actionButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func didTapActionButton() {
        onAction?()
    }
}
