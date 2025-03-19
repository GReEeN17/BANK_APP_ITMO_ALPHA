protocol TransferManagerProtocol {
    func getUsers(completion: @escaping (Result<[User], Error>) -> Void)
}
