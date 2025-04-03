import Foundation
import Combine

class AuthViewModel: AuthViewModelProtocol {
    private let authManager: AuthManagerProtocol
    private var cancellables = Set<AnyCancellable>()

    @Published var email: String?
    @Published var password: String?
    
    init(authService: AuthManagerProtocol) {
        self.authManager = authService
    }
    
    func updateEmail(_ email: String?) {
        self.email = email
    }

    func updatePassword(_ password: String?) {
        self.password = password
    }

    var isLoginButtonEnabled: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest($email, $password)
            .map { email, password in
                self.validateEmail(email) && self.validatePassword(password)
            }
            .eraseToAnyPublisher()
    }

    var isRegisterButtonEnabled: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest($email, $password)
            .map { email, password in
                self.validateEmail(email) && self.validatePassword(password)
            }
            .eraseToAnyPublisher()
    }

    var emailError: AnyPublisher<String?, Never> {
        $email
            .map { email in
                self.validateEmail(email) ? nil : "Invalid email"
            }
            .eraseToAnyPublisher()
    }

    var passwordError: AnyPublisher<String?, Never> {
        $password
            .map { password in
                self.validatePassword(password) ? nil : "Password must be at least 6 characters"
            }
            .eraseToAnyPublisher()
    }

    var loginResult = PassthroughSubject<Result<User, Error>, Never>()
    var showError = PassthroughSubject<String, Never>()
    
    func login(email: String, password: String) {
        authManager.login(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self?.loginResult.send(.success(user))
                case .failure(let error):
                    self?.loginResult.send(.failure(error))
                    self?.showError.send(error.localizedDescription)
                }
            }
        }
    }
    
    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        authManager.logout { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    self?.showError.send(error.localizedDescription)
                }
            }
        }
    }
    
    func register(email: String, username: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        authManager.register(email: email, username: username, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    completion(.success(user))
                case .failure(let error):
                    self?.showError.send(error.localizedDescription)
                }
            }
        }
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
