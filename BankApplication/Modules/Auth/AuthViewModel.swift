import Foundation

class AuthViewModel: AuthViewModelProtocol {
    private let authManager: AuthManagerProtocol
    
    init(authService: AuthManagerProtocol) {
        self.authManager = authService
    }
    
    func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        authManager.login(email: email, password: password, completion: completion)
    }
    
    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        authManager.logout(completion: completion)
    }
    
    func register(email: String, username: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        authManager.register(email: email, username: username, password: password, completion: completion)
    }

    func validateEmail(_ email: String?) -> Bool {
        guard let email = email else { return false }
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    func validatePassword(_ password: String?) -> Bool {
        guard let password = password else { return false }
        return password.count >= 6
    }
}
