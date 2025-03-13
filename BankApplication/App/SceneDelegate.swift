import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let authService = AuthManager()
        let authViewModel = AuthViewModel(authService: authService)
        let authVC = AuthViewController(viewModel: authViewModel)
        
        let navigationController = UINavigationController(rootViewController: authVC)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
