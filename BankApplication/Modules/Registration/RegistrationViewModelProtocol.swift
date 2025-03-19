import Combine

protocol RegistrationViewModelProtocol {
    func register(email: String, username: String, password: String)
    var registrationResult: PassthroughSubject<Result<User, Error>, Never> { get }
    var showError: PassthroughSubject<String, Never> { get } // Новый Publisher для ошибок
}
