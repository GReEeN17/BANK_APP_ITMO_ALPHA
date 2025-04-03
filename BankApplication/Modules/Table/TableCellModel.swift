struct TableCellModel {
    let id: String
    let title: String
    let subtitle: String?
    let imageUrl: String?
    var isSelected: Bool
    
    var viewModel: UserCellViewModel {
        UserCellViewModel(
            id: id,
            title: title,
            subtitle: subtitle,
            imageUrl: imageUrl,
            isSelected: isSelected
        )
    }
    
    static func mockData(count: Int) -> [TableCellModel] {
        return (0..<count).map { index in
            TableCellModel(
                id: "\(index)",
                title: "Item \(index + 1)",
                subtitle: "Description \(index + 1)",
                imageUrl: "https://picsum.photos/200/200?random=\(index)",
                isSelected: false
            )
        }
    }
}

struct UserCellViewModel {
    let id: String
    let title: String
    let subtitle: String?
    let imageUrl: String?
    let isSelected: Bool
}
