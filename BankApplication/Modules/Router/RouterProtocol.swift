import Foundation

protocol RouterProtocol {
    func showAuthScreen()
    func showRegistrationScreen()
    func showBalanceScreen(user: User)
    
    func showListScreen()
    func showProfileScreen(user: User)
    func showTransferScreen(user: User)
    func showBankingServicesScreen(user: User, endpointURL: URL?)
    
    func popViewController(animated: Bool)
    func popToRootViewController(animated: Bool)
}
