import Foundation

final class ListViewModel: ListViewModelProtocol {
    var onUpdate: (([TableCellModel]) -> Void)?
    private var models: [TableCellModel] = []
    private var selectedIndices: Set<Int> = []
    
    func viewDidLoad() {
        loadData()
    }
    
    func didSelectItem(at index: Int) {
        selectedIndices.insert(index)
        updateModelsSelection()
    }
    
    func didDeselectItem(at index: Int) {
        selectedIndices.remove(index)
        updateModelsSelection()
    }
    
    func refreshData() {
        loadData()
    }
    
    private func loadData() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [weak self] in
            let mockModels = TableCellModel.mockData(count: 20)
            
            DispatchQueue.main.async {
                self?.models = mockModels
                self?.updateModelsSelection()
            }
        }
    }
    
    private func updateModelsSelection() {
        for (index, _) in models.enumerated() {
            models[index].isSelected = selectedIndices.contains(index)
        }
        onUpdate?(models)
    }
}
