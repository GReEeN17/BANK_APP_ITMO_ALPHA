protocol AuthManagerProtocol {
    func login(username: String, password: String, completion: @escaping (Result<User, Error>) -> Void)
    func logout(completion: @escaping (Result<Void, Error>) -> Void)
    func register(username: String, password: String, completion: @escaping (Result<User, Error>) -> Void)
}
