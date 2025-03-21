import Foundation

class AuthManager: AuthManagerProtocol {
    private let baseURL = "https://echo.free.beeceptor.com/sample-request"

    func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "email", value: email),
            URLQueryItem(name: "password", value: password)
        ]

        guard let url = components?.url else {
            completion(.failure(NSError(domain: "AuthError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "AuthError", code: 404, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let parsedQueryParams = json?["parsedQueryParams"] as? [String: String],
                   let email = parsedQueryParams["email"],
                   let password = parsedQueryParams["password"] {
                    // Эмуляция успешной авторизации
                    let user = User(id: UUID().uuidString, email: email, username: email, password: password)
                    completion(.success(user))
                } else {
                    completion(.failure(NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                }
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }

    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }

    func register(email: String, username: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        let newUser = User(id: UUID().uuidString, email: email, username: username, password: password)
        completion(.success(newUser))
    }
}
