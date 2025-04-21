import UIKit

final class Router: RouterProtocol {
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    func showAuthScreen() {
        let authService = AuthManager()
        let viewModel = AuthViewModel(authService: authService)
        let authVC = AuthViewController(viewModel: viewModel, router: self)
        navigationController?.setViewControllers([authVC], animated: true)
    }
    
    func showRegistrationScreen() {
        let authService = AuthManager()
        let viewModel = RegistrationViewModel(authService: authService)
        let registrationVC = RegistrationViewController(viewModel: viewModel, router: self)
        navigationController?.pushViewController(registrationVC, animated: true)
    }
    
    func showBalanceScreen(user: User) {
        let balanceManager = BalanceManager(users: [user])
        let currencyManager = CurrencyManager()
        let viewModel = BalanceViewModel(balanceManager: balanceManager, currencyManager: currencyManager)
        let balanceVC = BalanceViewController(viewModel: viewModel, user: user, router: self)
        navigationController?.pushViewController(balanceVC, animated: true)
    }
    
    func showListScreen() {
        let viewModel = ListViewModel()
        let listVC = ListViewController(viewModel: viewModel, router: self)
        navigationController?.pushViewController(listVC, animated: true)
    }
    
    func showProfileScreen(user: User) {
        let profileVC = ProfileViewController(user: user, router: self)
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func showTransferScreen(user: User) {
        let users = UserManager.shared.getAllUsers()
        let balanceManager = BalanceManager(users: users)
        let transferManager = TransferManager(users: users)
        let viewModel = TransferViewModel(
            balanceManager: balanceManager,
            transferManager: transferManager,
            user: user
        )
        
        let tableView = UITableView()
        let tableManager = TableManager(tableView: tableView)
        let transferVC = TransferViewController(
            viewModel: viewModel,
            router: self,
            tableManager: tableManager
        )
        navigationController?.pushViewController(transferVC, animated: true)
    }
    
    func showBankingServicesScreen(user: User, endpointURL: URL? = nil) {
        let defaultURL = URL(string: "https://alfa-itmo.ru/server/v1/storage/banking-services-zelen")!
        let viewController = BankingServicesViewController(
            router: self,
            user: user,
            endpointURL: endpointURL ?? defaultURL
        )
        navigationController?.pushViewController(viewController, animated: true)
    }
   
    func popViewController(animated: Bool) {
        navigationController?.popViewController(animated: animated)
    }
    
    func popToRootViewController(animated: Bool) {
        navigationController?.popToRootViewController(animated: animated)
    }
}
