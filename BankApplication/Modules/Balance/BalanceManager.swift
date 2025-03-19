import Foundation

class BalanceManager: BalanceManagerProtocol {
    private var balances: [String: Balance] = [:]
    private var transactions: [String: [Transaction]] = [:]
    
    init(users: [User]) {
        if balances.isEmpty {
            for user in users {
                balances[user.id] = Balance(userId: user.id, amount: 10000)
                transactions[user.id] = []
            }
        }
    }

    func getBalance(userId: String, comletion completion: @escaping (Result<Balance, Error>) -> Void) {
        print(userId)
        print(balances)
        if let balance = balances[userId] {
            completion(.success(balance))
        } else {
            let error = NSError(domain: "BalanceError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Balance not found"])
            completion(.failure(error))
        }
    }
    
    func getTransactions(userId: String, completion: @escaping (Result<[Transaction], Error>) -> Void) {
            if let userTransactions = transactions[userId] {
                completion(.success(userTransactions))
            } else {
                completion(.success([]))
            }
        }

    func deposit(userId: String, amount: Double, completion: @escaping (Result<Balance, Error>) -> Void) {
        if var balance = balances[userId] {
            balance.amount += amount
            balances[userId] = balance
            completion(.success(balance))
        } else {
            let error = NSError(domain: "BalanceError", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
            completion(.failure(error))
        }
    }

    func withdraw(userId: String, amount: Double, completion: @escaping (Result<Balance, Error>) -> Void) {
        if var balance = balances[userId] {
            if balance.amount >= amount {
                balance.amount -= amount
                balances[userId] = balance
                completion(.success(balance))
            } else {
                let error = NSError(domain: "BalanceError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Insufficient funds"])
                completion(.failure(error))
            }
        } else {
            let error = NSError(domain: "BalanceError", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
            completion(.failure(error))
        }
        print(balances)
    }

    func transferMoney(from senderId: String, to recipientId: String, amount: Double, completion: @escaping (Result<Void, Error>) -> Void) {
        withdraw(userId: senderId, amount: amount) { withdrawResult in
            switch withdrawResult {
            case .success:
                self.deposit(userId: recipientId, amount: amount) { depositResult in
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
