import Foundation

class UserManager {
    static let shared = UserManager()
    private var users: [User] = []

    private init() {
        users = [
            User(id: "1", email: "user1@example.com", username: "user1", password: "password1"),
            User(id: "2", email: "user2@example.com", username: "user2", password: "password2"),
            User(id: "3", email: "user3@example.com", username: "user3", password: "password3")
        ]
    }

    func addUser(_ user: User) {
        users.append(user)
    }

    func getUser(byEmail email: String) -> User? {
        return users.first { $0.email == email }
    }

    func getAllUsers() -> [User] {
        return users
    }
}
