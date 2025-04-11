import UIKit

class BDUIActionHandler {
    weak var viewController: UIViewController?
    var reloadHandler: (() -> Void)?
    private let router: Router
    private let user: User

    init(router: Router, user: User, reloadHandler: (() -> Void)? = nil) {
        self.router = router
        self.user = user
        self.reloadHandler = reloadHandler
    }
    
    func setViewController(_ viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func handleAction(_ action: BDUIActionProtocol) {
        print("Action triggered")
        print("Action type: \(action.type)")
        print("Action payload: \(action.payload ?? [:])")
        
        guard let actionType = BDUIActionType(rawValue: action.type) else {
            print("Unknown action type: \(action.type)")
            return
        }
        
        switch actionType {
        case .navigate:
            handleNavigateAction(action)
        case .reload:
            reloadHandler?()
        case .showAlert:
            handleShowAlertAction(action)
        case .dismiss:
            viewController?.dismiss(animated: true)
        case .apiRequest, .showToast:
            break
        }
    }
    
    private func handleNavigateAction(_ action: BDUIActionProtocol) {
        guard let screen = action.payload?["screen"] as? String else { return }
        
        switch screen {
        case "profile":
            router.showProfileScreen(user: user)
        case "balance":
            router.showBalanceScreen(user: user)
        default:
            print("Unknown screen: \(screen)")
        }
    }
    
    private func handleShowToastAction(_ action: BDUIActionProtocol) {
        guard let message = action.payload?["message"] as? String else { return }

        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = .systemFont(ofSize: 14)
        toastLabel.alpha = 0.0
        toastLabel.numberOfLines = 0
        toastLabel.layer.cornerRadius = 8
        toastLabel.clipsToBounds = true
        toastLabel.translatesAutoresizingMaskIntoConstraints = false

        guard let view = viewController?.view else { return }
        view.addSubview(toastLabel)

        NSLayoutConstraint.activate([
            toastLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            toastLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            toastLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
        ])

        UIView.animate(withDuration: 0.5, animations: {
            toastLabel.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: 2.0, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }


    
    private func handleReloadAction() {
        reloadHandler?()
    }
    
    private func handleApiRequestAction(_ action: BDUIActionProtocol) {
        guard let endpoint = action.payload?["endpoint"] as? String else { return }
         
        APIClient.shared.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                print("API request success: \(data)")
            case .failure(let error):
                print("API request failed: \(error)")
            }
        }
    }
    
    private func handleShowAlertAction(_ action: BDUIActionProtocol) {
        guard let title = action.payload?["title"] as? String,
              let message = action.payload?["message"] as? String else { return }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController?.present(alert, animated: true)
    }
    
    private func handleDismissAction() {
        viewController?.dismiss(animated: true)
    }
}
