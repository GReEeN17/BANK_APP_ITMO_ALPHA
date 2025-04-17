import UIKit

class BankingServicesViewController: UIViewController {
    private let mapper: BDUIViewMapper
    private let actionHandler: BDUIActionHandler
    private let endpointURL: URL
    
    init(router: Router, user: User, endpointURL: URL) {
        let tempActionHandler = BDUIActionHandler(
            router: router,
            user: user
        )
        
        print("Creating BDUIViewMapper with action handler: \(tempActionHandler)")
        
        let mapper = BDUIViewMapper(actionHandler: tempActionHandler)
        
        self.mapper = mapper
        self.actionHandler = tempActionHandler
        self.endpointURL = endpointURL
        
        super.init(nibName: nil, bundle: nil)
        
        self.actionHandler.setViewController(self)
        self.actionHandler.reloadHandler = { [weak self] in
            print("Reload handler called")
            self?.loadUI()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUI()
    }
    
    private func loadUI() {
        view.subviews.forEach { $0.removeFromSuperview() }
        
        loadJSONFromServer { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let jsonData):
                    do {
                        let decoder = JSONDecoder()
                        let viewModel = try decoder.decode(BDUIView.self, from: jsonData)
                        
                        print("Top-level actions: \(viewModel.actions?.keys)")
                        
                        let view = self?.mapper.map(viewModel: viewModel)
                        view?.translatesAutoresizingMaskIntoConstraints = false
                        
                        if let view = view {
                            self?.view.addSubview(view)
                            
                            NSLayoutConstraint.activate([
                                view.topAnchor.constraint(equalTo: self?.view.safeAreaLayoutGuide.topAnchor ?? NSLayoutYAxisAnchor()),
                                view.leadingAnchor.constraint(equalTo: self?.view.leadingAnchor ?? NSLayoutXAxisAnchor()),
                                view.trailingAnchor.constraint(equalTo: self?.view.trailingAnchor ?? NSLayoutXAxisAnchor()),
                                view.bottomAnchor.constraint(equalTo: self?.view.safeAreaLayoutGuide.bottomAnchor ?? NSLayoutYAxisAnchor())
                            ])
                        }
                    } catch {
                        print("Decoding error: \(error)")
                        self?.showErrorView()
                    }
                case .failure(let error):
                    print("Network error: \(error)")
                    self?.showErrorView()
                }
            }
        }
    }
    
    private func loadJSONFromServer(completion: @escaping (Result<Data, Error>) -> Void) {
        let username = "368200"
        let password = "Zy-AJ9NqXOnv"
        
        var request = URLRequest(url: endpointURL)
        request.httpMethod = "GET"
        
        let loginString = "\(username):\(password)"
        guard let loginData = loginString.data(using: .utf8) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Auth encoding failed"])))
            return
        }
        let base64LoginString = loginData.base64EncodedString()
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server returned status code \(httpResponse.statusCode)"])))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            completion(.success(data))
        }
        
        task.resume()
    }
    
    private func showErrorView() {
        let errorView = DSEmptyStateView()
        errorView.configure(with: DSEmptyStateViewModel(
            title: "Ошибка загрузки",
            message: "Не удалось загрузить данные сервисов",
            image: UIImage(systemName: "exclamationmark.triangle")
        ))
        
        view.addSubview(errorView)
        errorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            errorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DSSpacing.large),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DSSpacing.large)
        ])
    }
}
