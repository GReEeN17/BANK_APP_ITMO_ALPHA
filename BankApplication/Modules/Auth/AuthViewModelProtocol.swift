import Combine
protocol AuthViewModelProtocol {
    func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void)
    func logout(completion: @escaping (Result<Void, Error>) -> Void)
    func register(email: String, username: String, password: String, completion: @escaping (Result<User, Error>) -> Void)
    func validateEmail(_ email: String?) -> Bool
    func validatePassword(_ password: String?) -> Bool
    func updateEmail(_ email: String?)
    func updatePassword(_ password: String?)
    var email: String? { get }
    var password: String? { get }
    var isLoginButtonEnabled: AnyPublisher<Bool, Never> { get }
    var isRegisterButtonEnabled: AnyPublisher<Bool, Never> { get }
    var emailError: AnyPublisher<String?, Never> { get }
    var passwordError: AnyPublisher<String?, Never> { get }
    var loginResult: PassthroughSubject<Result<User, Error>, Never> { get }
    var showError: PassthroughSubject<String, Never> { get }
}
