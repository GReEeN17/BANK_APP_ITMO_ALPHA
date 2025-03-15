import Combine
import Foundation

class RegistrationViewModel: RegistrationViewModelProtocol {
    private let authManager: AuthManagerProtocol
    var registrationResult = PassthroughSubject<Result<User, Error>, Never>()
    var showError = PassthroughSubject<String, Never>()

    init(authService: AuthManagerProtocol) {
        self.authManager = authService
    }

    func register(email: String, username: String, password: String) {
        authManager.register(email: email, username: username, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self?.registrationResult.send(.success(user))
                case .failure(let error):
                    self?.showError.send(error.localizedDescription)
                }
            }
        }
    }
}
