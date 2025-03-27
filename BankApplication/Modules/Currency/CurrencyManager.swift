import Foundation

class CurrencyManager: CurrencyManagerProtocol {
    private let baseURL = "http://apilayer.net/api/live"
    private let accessKey = "aec5d7738801b7a013c9358436bc6735"
    private let cacheFileName = "currencyCache.json"
    private let cacheExpirationTime: TimeInterval = 300
    
    private var allCurrencies: [Currency] = []
    private var currentPage = 0
    private let itemsPerPage = 2
    
    init() {}
    
    func fetchCurrencies(page: Int, completion: @escaping (Result<[Currency], Error>) -> Void) {
        if let cachedCurrencies = loadCachedCurrencies(), isCacheValid() {
            allCurrencies = cachedCurrencies
            let paginatedCurrencies = getPaginatedCurrencies(page: page)
            completion(.success(paginatedCurrencies))
            return
        }
        
        let urlString = "\(baseURL)?access_key=\(accessKey)&currencies=EUR,GBP,CAD,PLN,RUB&source=USD&format=1"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 404, userInfo: nil)))
                return
            }
            
            do {
                let currencyResponse = try JSONDecoder().decode(CurrencyResponse.self, from: data)
                self.allCurrencies = currencyResponse.quotes.map { Currency(code: $0.key, rate: $0.value) }
                
                self.saveCurrenciesToCache(self.allCurrencies)
                
                let paginatedCurrencies = self.getPaginatedCurrencies(page: page)
                completion(.success(paginatedCurrencies))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    private func getPaginatedCurrencies(page: Int) -> [Currency] {
        let startIndex = page * itemsPerPage
        let endIndex = min(startIndex + itemsPerPage, allCurrencies.count)
        return Array(allCurrencies[startIndex..<endIndex])
    }
    
    private func loadCachedCurrencies() -> [Currency]? {
        guard let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent(cacheFileName),
              let data = try? Data(contentsOf: cacheURL),
              let currencies = try? JSONDecoder().decode([Currency].self, from: data) else {
            return nil
        }
        return currencies
    }
    
    private func saveCurrenciesToCache(_ currencies: [Currency]) {
        guard let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent(cacheFileName),
              let data = try? JSONEncoder().encode(currencies) else {
            return
        }
        try? data.write(to: cacheURL)
    }
    
    private func isCacheValid() -> Bool {
        guard let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent(cacheFileName),
              let attributes = try? FileManager.default.attributesOfItem(atPath: cacheURL.path),
              let modificationDate = attributes[.modificationDate] as? Date else {
            return false
        }
        return Date().timeIntervalSince(modificationDate) < cacheExpirationTime
    }
}
