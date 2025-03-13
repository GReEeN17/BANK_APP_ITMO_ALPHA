protocol BalanceManagerProtocol {
    func getBalance(userId: String, comletion: @escaping (Result<Balance, Error>) -> Void)
    func deposit(userId: String, amount: Double, completion: @escaping (Result<Balance, Error>) -> Void)
    func withdraw(userId: String, amount: Double, completion: @escaping (Result<Balance, Error>) -> Void)
    func transferMoney(from senderId: String, to recipientId: String, amount: Double, completion: @escaping (Result<Void, Error>) -> Void)
    func getTransactions(userId: String, completion: @escaping (Result<[Transaction], Error>) -> Void)
}
