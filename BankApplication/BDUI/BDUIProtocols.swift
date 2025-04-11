import UIKit

protocol BDUIViewProtocol {
    var type: String { get }
    var content: [String: Any]? { get }
    var subviews: [BDUIView]? { get }
    var actions: [String: BDUIAction]? { get }
}

protocol BDUIActionProtocol {
    var type: String { get }
    var payload: [String: Any]? { get }
}

protocol BDUIViewMapperProtocol {
    func map(viewModel: BDUIViewProtocol) -> UIView
}
