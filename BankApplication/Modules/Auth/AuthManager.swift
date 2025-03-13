import Foundation

class AuthManager: AuthManagerProtocol {
    private let users: [User] = [
        User(id: "1", username: "user1", password: "password1"),
        User(id: "2", username: "user2", password: "password2"),
        User(id: "3", username: "user3", password: "password3")
    ]

    func login(username: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        if let user = users.first(where: { $0.username == username }) {
            if user.password == password {
                completion(.success(user))
            } else {
                let error = NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Invalid password"])
                completion(.failure(error))
            }
        } else {
            let error = NSError(domain: "AuthError", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
            completion(.failure(error))
        }
    }

    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }
    
    func register(username: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        let newUser = User(id: UUID().uuidString, username: username, password: password)
        completion(.success(newUser))
    }
}
