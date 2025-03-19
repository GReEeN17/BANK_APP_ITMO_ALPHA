import Foundation

class AuthManager: AuthManagerProtocol {
    func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        if let user = UserManager.shared.getUser(byEmail: email) {
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

    func register(email: String, username: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        let newUser = User(id: UUID().uuidString, email: email, username: username, password: password)
        UserManager.shared.addUser(newUser)
        completion(.success(newUser))
    }
}
