import UIKit

class DSTextField: UITextField {
    private let errorLabel = UILabel()
    
    func configure(with viewModel: DSTextFieldViewModel) {
        placeholder = viewModel.placeholder
        font = DSTypography.body
        textColor = DSColors.textPrimary
        backgroundColor = DSColors.background
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = viewModel.type == .error ? DSColors.error.cgColor : DSColors.primary.cgColor
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        switch viewModel.type {
        case .email:
            keyboardType = .emailAddress
            autocapitalizationType = .none
            autocorrectionType = .no
        case .password:
            isSecureTextEntry = true
        case .decimalPad:
            keyboardType = .decimalPad
        default:
            break
        }
        
        setupErrorLabel(with: viewModel.errorMessage)
    }
    
    private func setupErrorLabel(with message: String?) {
        guard let message = message else {
            errorLabel.isHidden = true
            return
        }
        
        errorLabel.text = message
        errorLabel.font = DSTypography.caption
        errorLabel.textColor = DSColors.error
        errorLabel.isHidden = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
    }
}
