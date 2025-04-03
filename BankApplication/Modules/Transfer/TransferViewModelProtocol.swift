import Combine

protocol TransferViewModelProtocol {
    func getUsers()
    func getTransactions(userId: String, completion: @escaping (Result<[Transaction], Error>) -> Void)
    func getBalance(userId: String, completion: @escaping (Result<Balance, Error>) -> Void)
    func deposit(userId: String, amount: Double, completion: @escaping (Result<Balance, Error>) -> Void)
    func withdraw(userId: String, amount: Double, completion: @escaping (Result<Balance, Error>) -> Void)
    func transferMoney(from senderId: String, to recipientId: String, amount: Double)

    func validateAmount(_ amountText: String?) -> Double?

    var users: [User] { get }
    var usersPublisher: AnyPublisher<[User], Never> { get }
    var transferResult: PassthroughSubject<Result<Void, Error>, Never> { get }

    var user: User { get }
}
