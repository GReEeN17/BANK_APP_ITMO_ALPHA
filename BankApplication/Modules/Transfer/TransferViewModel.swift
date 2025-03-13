class TransferViewModel: TransferViewModelProtocol {
    private let balanceManager: BalanceManagerProtocol
    private let transferManager: TransferManagerProtocol

    init(balanceManager: BalanceManagerProtocol, transferManager: TransferManagerProtocol) {
        self.balanceManager = balanceManager
        self.transferManager = transferManager
    }
    
    func getUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        transferManager.getUsers(completion: completion)
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
        balanceManager.transferMoney(from: senderId, to: recipientId, amount: amount, completion: completion)
    }
    
    func validateAmount(_ amountText: String?) -> Double? {
        guard let amountText = amountText, let amount = Double(amountText) else {
            return nil
        }
        return amount
    }
}
