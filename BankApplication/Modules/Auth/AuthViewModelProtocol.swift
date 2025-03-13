protocol AuthViewModelProtocol {
    func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void)
    func logout(completion: @escaping (Result<Void, Error>) -> Void)
    func register(email: String, username: String, password: String, completion: @escaping (Result<User, Error>) -> Void)
    func validateEmail(_ email: String?) -> Bool
    func validatePassword(_ password: String?) -> Bool
}
