class TransferManager: TransferManagerProtocol {
    let users: [User]
    
    init(users: [User]) {
        self.users = users
    }
    
    func getUsers(completion: @escaping (Result<[User], any Error>) -> Void) {
        completion(.success(users))
    }
}
