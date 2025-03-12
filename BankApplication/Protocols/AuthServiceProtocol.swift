protocol AuthServiceProtocol {
    func login(username: String, password: String, completion: @escaping (Result<User, Error>) -> Void)
    func logout(completion: @escaping (Result<Void, Error>) -> Void)
}
