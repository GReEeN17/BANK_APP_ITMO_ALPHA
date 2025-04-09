import UIKit

class DSButton: UIButton {
    private var activityIndicator: UIActivityIndicatorView?
    
    func configure(with viewModel: DSButtonViewModel) {
        setTitle(viewModel.title, for: .normal)
        isEnabled = viewModel.isEnabled
        alpha = viewModel.isEnabled ? 1.0 : 0.5
        
        if let icon = viewModel.icon {
            setImage(icon, for: .normal)
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: DSSpacing.small)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: DSSpacing.small, bottom: 0, right: 0)
        }
        
        switch viewModel.type {
        case .primary:
            backgroundColor = DSColors.primary
            setTitleColor(.white, for: .normal)
        case .secondary:
            backgroundColor = .clear
            setTitleColor(DSColors.primary, for: .normal)
            layer.borderWidth = 1
            layer.borderColor = DSColors.primary.cgColor
        case .error:
            backgroundColor = DSColors.error
            setTitleColor(.white, for: .normal)
        }
        
        titleLabel?.font = DSTypography.body
        layer.cornerRadius = 8
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 4
        
        if viewModel.isLoading {
            showLoading()
        } else {
            hideLoading()
        }
    }
    
    private func showLoading() {
        if activityIndicator == nil {
            let indicator = UIActivityIndicatorView(style: .medium)
            indicator.color = titleColor(for: .normal)
            addSubview(indicator)
            indicator.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                indicator.centerXAnchor.constraint(equalTo: centerXAnchor),
                indicator.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
            activityIndicator = indicator
        }
        activityIndicator?.startAnimating()
        setTitle("", for: .normal)
        imageView?.isHidden = true
        isUserInteractionEnabled = false
    }
    
    private func hideLoading() {
        activityIndicator?.stopAnimating()
        activityIndicator?.removeFromSuperview()
        activityIndicator = nil
        imageView?.isHidden = false
        isUserInteractionEnabled = true
    }
}
