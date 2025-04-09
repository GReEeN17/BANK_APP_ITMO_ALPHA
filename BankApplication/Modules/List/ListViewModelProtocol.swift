import Combine

protocol ListViewModelProtocol {
    var screenTitle: String { get }
    var itemsPublisher: AnyPublisher<[DSListCellModel], Never> { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var errorPublisher: AnyPublisher<String, Never> { get }
    
    func viewDidLoad()
    func didSelectItem(at index: Int)
    func didDeselectItem(at index: Int)
    func didTapAdd()
    func refreshData()
    func willDisplayItem(at index: Int)
}
