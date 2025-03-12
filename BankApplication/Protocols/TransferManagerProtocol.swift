protocol TransferManagerProtocol {
    func performTransaction(amount: Double, recepient: String, completion: @escaping (Result<Transaction, Error>) -> Void)
}
