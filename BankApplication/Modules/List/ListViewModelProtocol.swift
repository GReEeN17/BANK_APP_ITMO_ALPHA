protocol ListViewModelProtocol {
    var onUpdate: (([TableCellModel]) -> Void)? { get set }
    func viewDidLoad()
    func didSelectItem(at index: Int)
    func didDeselectItem(at index: Int)
    func refreshData()
}
