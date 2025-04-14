import Foundation

class APIClient {
    static let shared = APIClient()
    
    func request(endpoint: String, completion: @escaping (Result<Data, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            let mockData: Data?
            
            switch endpoint {
            case "user/profile":
                mockData = """
                {
                    "name": "Иван Иванов",
                    "email": "ivan@example.com",
                    "balance": 12500.50,
                    "currency": "RUB"
                }
                """.data(using: .utf8)
                
            case "transactions":
                mockData = """
                [
                    {
                        "id": 1,
                        "amount": 1500,
                        "description": "Перевод от ООО Ромашка",
                        "date": "2023-05-15"
                    },
                    {
                        "id": 2,
                        "amount": -500,
                        "description": "Оплата услуг",
                        "date": "2023-05-14"
                    }
                ]
                """.data(using: .utf8)
                
            case "services":
                mockData = """
                [
                    {
                        "id": "cashback",
                        "title": "Кешбек",
                        "description": "До 10% возврата",
                        "isActive": true
                    },
                    {
                        "id": "currency",
                        "title": "Обмен валют",
                        "description": "Лучший курс",
                        "isActive": true
                    }
                ]
                """.data(using: .utf8)
                
            case "auth/login":
                mockData = """
                {
                    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.xxxx",
                    "expiresIn": 3600
                }
                """.data(using: .utf8)
                
            default:
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.invalidEndpoint))
                }
                return
            }
            
            // Имитация успешного или неудачного ответа
            DispatchQueue.main.async {
                if let data = mockData {
                    completion(.success(data))
                } else {
                    completion(.failure(NetworkError.mockDataError))
                }
            }
        }
    }
    
    // Дополнительные методы для удобства работы с JSON
    
    func fetchUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        request(endpoint: "user/profile") { result in
            switch result {
            case .success(let data):
                do {
                    let profile = try JSONDecoder().decode(UserProfile.self, from: data)
                    completion(.success(profile))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchTransactions(completion: @escaping (Result<[TransactionMock], Error>) -> Void) {
        request(endpoint: "transactions") { result in
            switch result {
            case .success(let data):
                do {
                    let transactions = try JSONDecoder().decode([TransactionMock].self, from: data)
                    completion(.success(transactions))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

struct UserProfile: Codable {
    let name: String
    let email: String
    let balance: Double
    let currency: String
}

struct TransactionMock: Codable {
    let id: Int
    let amount: Double
    let description: String
    let date: String
}

struct Service: Codable {
    let id: String
    let title: String
    let description: String
    let isActive: Bool
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case invalidEndpoint
    case mockDataError
    case decodingError
}
