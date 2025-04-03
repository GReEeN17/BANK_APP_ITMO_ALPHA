import Combine

protocol RegistrationViewModelProtocol {
    func register(email: String, username: String, password: String)
    var isLoading: AnyPublisher<Bool, Never> { get }
    var registrationResult: PassthroughSubject<Result<User, Error>, Never> { get }
    var showError: PassthroughSubject<String, Never> { get }
}
