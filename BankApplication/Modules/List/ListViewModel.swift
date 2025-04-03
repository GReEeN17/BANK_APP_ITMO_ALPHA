import Foundation
import UIKit
import Combine

final class ListViewModel: ListViewModelProtocol {
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    private let itemsSubject = CurrentValueSubject<[DSListCellModel], Never>([])
    private let errorSubject = PassthroughSubject<String, Never>()
    
    var itemsPublisher: AnyPublisher<[DSListCellModel], Never> {
        itemsSubject.eraseToAnyPublisher()
    }
    
    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }
    
    var errorPublisher: AnyPublisher<String, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    var screenTitle: String {
        return "Пользователи"
    }
    
    private var cancellables = Set<AnyCancellable>()
    private var selectedIndices: Set<Int> = []
    private var currentPage = 0
    private let itemsPerPage = 20
    private var canLoadMore = true
    
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
    
    func didTapAdd() {
        // Что-то
    }
    
    func refreshData() {
        currentPage = 0
        canLoadMore = true
        loadData()
    }
    
    func willDisplayItem(at index: Int) {
        guard canLoadMore,
              index >= itemsSubject.value.count - 5,
              !isLoadingSubject.value else { return }
        loadMoreData()
    }
    
    private func loadData() {
        guard !isLoadingSubject.value else { return }
        
        isLoadingSubject.send(true)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            
            let mockModels = self.generateMockData(count: self.itemsPerPage)
            
            DispatchQueue.main.async {
                self.itemsSubject.send(mockModels)
                self.isLoadingSubject.send(false)
            }
        }
    }
    
    private func loadMoreData() {
        guard canLoadMore, !isLoadingSubject.value else { return }
        
        currentPage += 1
        isLoadingSubject.send(true)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            
            let newItems = self.generateMockData(count: self.itemsPerPage)
            let allItems = self.itemsSubject.value + newItems
            
            if self.currentPage >= 3 {
                self.canLoadMore = false
            }
            
            DispatchQueue.main.async {
                self.itemsSubject.send(allItems)
                self.isLoadingSubject.send(false)
            }
        }
    }
    
    private func updateModelsSelection() {
        var currentItems = itemsSubject.value
        for (index, _) in currentItems.enumerated() {
            currentItems[index].isSelected = selectedIndices.contains(index)
        }
        itemsSubject.send(currentItems)
    }
    
    private func generateMockData(count: Int) -> [DSListCellModel] {
        return (0..<count).map { index in
            DSListCellModel(
                id: "\(currentPage * itemsPerPage + index)",
                title: "Item \(currentPage * itemsPerPage + index + 1)",
                subtitle: "Description for item \(currentPage * itemsPerPage + index + 1)",
                icon: UIImage(systemName: ["folder", "doc", "photo", "trash", "heart"].randomElement()!),
                isSelected: selectedIndices.contains(currentPage * itemsPerPage + index)
            )
        }
    }
}
