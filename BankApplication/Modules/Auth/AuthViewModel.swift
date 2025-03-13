import Foundation
class AuthViewModel: AuthViewModelProtocol {
    private let authManager: AuthManagerProtocol
    
    init(authService: AuthManagerProtocol) {
        self.authManager = authService
    }
    
    func login(username: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        authManager.login(username: username, password: password, completion: completion)
    }
    
    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        authManager.logout(completion: completion)
    }
    
    func register(username: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        authManager.register(username: username, password: password, completion: completion)
    }
}
