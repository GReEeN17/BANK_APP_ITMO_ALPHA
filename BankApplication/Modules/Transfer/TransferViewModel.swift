class TransferViewModel {
    private let balanceManager: BalanceManagerProtocol
    let users: [User]

    init(balanceManager: BalanceManagerProtocol, users: [User]) {
        self.balanceManager = balanceManager
        self.users = users
    }
    
    func getTransactions(userId: String, completion: @escaping (Result<[Transaction], Error>) -> Void) {
        balanceManager.getTransactions(userId: userId, completion: completion)
    }

    func getBalance(userId: String, completion: @escaping (Result<Balance, Error>) -> Void) {
        balanceManager.getBalance(userId: userId, comletion: completion)
    }

    func deposit(userId: String, amount: Double, completion: @escaping (Result<Balance, Error>) -> Void) {
        balanceManager.deposit(userId: userId, amount: amount, completion: completion)
    }

    func withdraw(userId: String, amount: Double, completion: @escaping (Result<Balance, Error>) -> Void) {
        balanceManager.withdraw(userId: userId, amount: amount, completion: completion)
    }

    func transferMoney(from senderId: String, to recipientId: String, amount: Double, completion: @escaping (Result<Void, Error>) -> Void) {
        balanceManager.withdraw(userId: senderId, amount: amount) { withdrawResult in
            switch withdrawResult {
            case .success:
                self.balanceManager.deposit(userId: recipientId, amount: amount) { depositResult in
                    switch depositResult {
                    case .success:
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
