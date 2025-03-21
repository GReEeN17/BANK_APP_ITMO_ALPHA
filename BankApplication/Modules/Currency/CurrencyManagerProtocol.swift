protocol CurrencyManagerProtocol{
    func fetchCurrencies(page: Int, completion: @escaping (Result<[Currency], Error>) -> Void)
}

