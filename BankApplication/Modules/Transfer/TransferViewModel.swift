import Combine

class TransferViewModel: TransferViewModelProtocol {
    private let balanceManager: BalanceManagerProtocol
    private let transferManager: TransferManagerProtocol
    let user: User
    
    @Published private(set) var users: [User] = []
    var usersPublisher: AnyPublisher<[User], Never> {
        $users.eraseToAnyPublisher()
    }
    
    var transferResult = PassthroughSubject<Result<Void, Error>, Never>()

    init(balanceManager: BalanceManagerProtocol, transferManager: TransferManagerProtocol, user: User) {
        self.balanceManager = balanceManager
        self.transferManager = transferManager
        self.user = user
    }
    
    func getUsers() {
        transferManager.getUsers { [weak self] result in
            switch result {
            case .success(let users):
                self?.users = users
            case .failure(let error):
                self?.transferResult.send(.failure(error))
            }
        }
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
