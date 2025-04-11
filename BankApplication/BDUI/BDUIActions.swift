import UIKit

struct BDUIAction: BDUIActionProtocol, Decodable {
    let type: String
    let payload: [String: Any]?
    
    private enum CodingKeys: String, CodingKey {
        case type, payload
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        payload = try container.decodeIfPresent([String: Any].self, forKey: .payload)
    }
}

enum BDUIActionType: String {
    case navigate
    case reload
    case apiRequest
    case showAlert
    case dismiss
    case showToast
}
