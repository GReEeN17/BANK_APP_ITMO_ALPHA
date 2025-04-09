import Foundation
import Combine

protocol BalanceViewModelProtocol {
    var balanceResult: AnyPublisher<Result<Balance, Error>, Never> { get }
    var transactionsResult: AnyPublisher<Result<[Transaction], Error>, Never> { get }
    var currenciesResult: AnyPublisher<Result<[Currency], Error>, Never> { get }
    var showError: AnyPublisher<String, Never> { get }
    
    func loadBalance(userId: String)
    func loadTransactions(userId: String)
    func loadCurrencies(page: Int)
}
