import Foundation

class BalanceViewModel: BalanceViewModelProtocol {
    private let balanceManager: BalanceManagerProtocol
    private let currencyManager: CurrencyManagerProtocol
    
    init(balanceManager: BalanceManagerProtocol, currencyManager: CurrencyManagerProtocol) {
        self.balanceManager = balanceManager
        self.currencyManager = currencyManager
    }
    
    func fetchCurrencies(page: Int, completion: @escaping (Result<[Currency], Error>) -> Void) {
        currencyManager.fetchCurrencies(page: page, completion: completion)
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
}
