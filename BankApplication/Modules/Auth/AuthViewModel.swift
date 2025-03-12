import Foundation
class AuthViewModel {
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
    func login(username: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        authService.login(username: username, password: password, completion: completion)
    }
    
    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        authService.logout(completion: completion)
    }
    
    func register(username: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        let newUser = User(id: UUID().uuidString, username: username, password: password)
        completion(.success(newUser))
    }
}
