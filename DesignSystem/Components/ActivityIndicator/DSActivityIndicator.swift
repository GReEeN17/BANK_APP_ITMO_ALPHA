import UIKit

class DSActivityIndicatorView: UIView {
    private let activityIndicator = UIActivityIndicatorView()
    
    func configure(with viewModel: DSActivityIndicatorViewModel) {
        activityIndicator.style = .medium
        activityIndicator.color = viewModel.color
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            widthAnchor.constraint(equalToConstant: viewModel.size.value),
            heightAnchor.constraint(equalToConstant: viewModel.size.value)
        ])
        
        backgroundColor = .clear
    }
    
    func startAnimating() {
        activityIndicator.startAnimating()
    }
    
    func stopAnimating() {
        activityIndicator.stopAnimating()
    }
    
    var isAnimating: Bool {
        return activityIndicator.isAnimating
    }
}
