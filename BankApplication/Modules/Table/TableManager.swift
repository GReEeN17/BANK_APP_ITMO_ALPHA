import UIKit

class TableManager: NSObject, UITableViewDataSource, UITableViewDelegate {
    private var cellModels: [TableCellModel] = []
    private weak var tableView: UITableView?

    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    func update(with cellModels: [TableCellModel]) {
        self.cellModels = cellModels
        tableView?.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let model = cellModels[indexPath.row]
        cell.textLabel?.text = model.title
        cell.accessoryType = model.isSelected ? .checkmark : .none
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = UIColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var updatedModels = cellModels
        updatedModels[indexPath.row].isSelected.toggle()
        update(with: updatedModels)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        var updatedModels = cellModels
        updatedModels[indexPath.row].isSelected.toggle()
        update(with: updatedModels)
    }
}
