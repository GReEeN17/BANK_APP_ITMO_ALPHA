import Foundation
import Combine

final class BalanceViewModel: BalanceViewModelProtocol {
    private let balanceManager: BalanceManagerProtocol
    private let currencyManager: CurrencyManagerProtocol
    
    private let balanceSubject = PassthroughSubject<Result<Balance, Error>, Never>()
    private let transactionsSubject = PassthroughSubject<Result<[Transaction], Error>, Never>()
    private let currenciesSubject = PassthroughSubject<Result<[Currency], Error>, Never>()
    private let errorSubject = PassthroughSubject<String, Never>()
    
    var balanceResult: AnyPublisher<Result<Balance, Error>, Never> {
        balanceSubject.eraseToAnyPublisher()
    }
    
    var transactionsResult: AnyPublisher<Result<[Transaction], Error>, Never> {
        transactionsSubject.eraseToAnyPublisher()
    }
    
    var currenciesResult: AnyPublisher<Result<[Currency], Error>, Never> {
        currenciesSubject.eraseToAnyPublisher()
    }
    
    var showError: AnyPublisher<String, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    init(balanceManager: BalanceManagerProtocol, currencyManager: CurrencyManagerProtocol) {
        self.balanceManager = balanceManager
        self.currencyManager = currencyManager
    }
    
    func loadBalance(userId: String) {
        balanceManager.getBalance(userId: userId) { [weak self] result in
            switch result {
            case .success(let balance):
                self?.balanceSubject.send(.success(balance))
            case .failure(let error):
                self?.balanceSubject.send(.failure(error))
                self?.errorSubject.send("Failed to load balance: \(error.localizedDescription)")
            }
        }
    }
    
    func loadTransactions(userId: String) {
        balanceManager.getTransactions(userId: userId) { [weak self] result in
            switch result {
            case .success(let transactions):
                self?.transactionsSubject.send(.success(transactions))
            case .failure(let error):
                self?.transactionsSubject.send(.failure(error))
                self?.errorSubject.send("Failed to load transactions: \(error.localizedDescription)")
            }
        }
    }
    
    func loadCurrencies(page: Int) {
        currencyManager.fetchCurrencies(page: page) { [weak self] result in
            switch result {
            case .success(let currencies):
                self?.currenciesSubject.send(.success(currencies))
            case .failure(let error):
                self?.currenciesSubject.send(.failure(error))
                self?.errorSubject.send("Failed to load currencies: \(error.localizedDescription)")
            }
        }
    }
}
