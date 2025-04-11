import UIKit

class BankingServicesViewController: UIViewController {
    private let mapper: BDUIViewMapper
    private let actionHandler: BDUIActionHandler
    
    init(router: Router, user: User) {
        let tempActionHandler = BDUIActionHandler(
            router: router,
            user: user
        )
        
        print("Creating BDUIViewMapper with action handler: \(tempActionHandler)")
        
        let mapper = BDUIViewMapper(actionHandler: tempActionHandler)
        
        self.mapper = mapper
        self.actionHandler = tempActionHandler
        
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
        
        if let jsonData = loadJSONFromFile(named: "bankingServices") {
            do {
                let decoder = JSONDecoder()
                let viewModel = try decoder.decode(BDUIView.self, from: jsonData)
                
                print("Top-level actions: \(viewModel.actions?.keys)")
                
                let view = mapper.map(viewModel: viewModel)
                view.translatesAutoresizingMaskIntoConstraints = false
                self.view.addSubview(view)
                
                NSLayoutConstraint.activate([
                    view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
                    view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                    view.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
                ])
                
            } catch {
                print("Decoding error: \(error)")
                showErrorView()
            }
        } else {
            showErrorView()
        }
    }
    
    private func loadJSONFromFile(named filename: String) -> Data? {
        guard let path = Bundle.main.path(forResource: filename, ofType: "json") else {
            print("Файл \(filename).json не найден в bundle")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            print("Успешно загружен JSON файл \(filename).json, размер: \(data.count) байт")
            return data
        } catch {
            print("Ошибка загрузки JSON файла \(filename).json: \(error)")
            return nil
        }
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
