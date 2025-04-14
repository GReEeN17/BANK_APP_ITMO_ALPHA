import UIKit

fileprivate struct DynamicCodingKeys: CodingKey {
    var stringValue: String
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    var intValue: Int?
    init?(intValue: Int) {
        return nil
    }
}

struct AnyDecodableDictionary: Decodable {
    let value: [String: Any]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        var dict = [String: Any]()
        
        for key in container.allKeys {
            if let val = try? container.decode(Bool.self, forKey: key) {
                dict[key.stringValue] = val
            } else if let val = try? container.decode(Int.self, forKey: key) {
                dict[key.stringValue] = val
            } else if let val = try? container.decode(Double.self, forKey: key) {
                dict[key.stringValue] = val
            } else if let val = try? container.decode(String.self, forKey: key) {
                dict[key.stringValue] = val
            } else if let val = try? container.decode(AnyDecodableDictionary.self, forKey: key) {
                dict[key.stringValue] = val.value
            } else if let val = try? container.decode([Any].self, forKey: key) {
                dict[key.stringValue] = val
            }
        }
        self.value = dict
    }
}

struct AnyDecodableArray: Decodable {
    let value: [Any]
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var array = [Any]()
        
        while !container.isAtEnd {
            if let val = try? container.decode(Bool.self) {
                array.append(val)
            } else if let val = try? container.decode(Int.self) {
                array.append(val)
            } else if let val = try? container.decode(Double.self) {
                array.append(val)
            } else if let val = try? container.decode(String.self) {
                array.append(val)
            } else if let val = try? container.decode(AnyDecodableDictionary.self) {
                array.append(val.value)
            }
        }
        self.value = array
    }
}

struct BDUIView: BDUIViewProtocol, Decodable {
    let type: String
    let content: [String: Any]?
    let subviews: [BDUIView]?
    let actions: [String: BDUIAction]?
    
    private enum CodingKeys: String, CodingKey {
        case type, content, subviews, actions
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        content = try container.decodeIfPresent([String: Any].self, forKey: .content)
        subviews = try container.decodeIfPresent([BDUIView].self, forKey: .subviews)
        actions = try container.decodeIfPresent([String: BDUIAction].self, forKey: .actions)
    }
}

extension KeyedDecodingContainer {
    func decode(_ type: [String: Any].Type, forKey key: K) throws -> [String: Any] {
        let container = try self.nestedContainer(keyedBy: DynamicCodingKeys.self, forKey: key)
        var dictionary = [String: Any]()
        
        for key in container.allKeys {
            if let value = try? container.decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = value
            } else if let value = try? container.decode(String.self, forKey: key) {
                dictionary[key.stringValue] = value
            } else if let value = try? container.decode(Int.self, forKey: key) {
                dictionary[key.stringValue] = value
            } else if let value = try? container.decode(Double.self, forKey: key) {
                dictionary[key.stringValue] = value
            } else if let nestedDictionary = try? container.decode([String: Any].self, forKey: key) {
                dictionary[key.stringValue] = nestedDictionary
            } else if let nestedArray = try? container.decode([Any].self, forKey: key) {
                dictionary[key.stringValue] = nestedArray
            }
        }
        return dictionary
    }
    
    func decodeIfPresent(_ type: [String: Any].Type, forKey key: K) throws -> [String: Any]? {
        guard contains(key) else { return nil }
        return try decode(type, forKey: key)
    }
    
    func decode(_ type: [Any].Type, forKey key: K) throws -> [Any] {
        var container = try self.nestedUnkeyedContainer(forKey: key)
        var array: [Any] = []
        
        while !container.isAtEnd {
            if let value = try? container.decode(Bool.self) {
                array.append(value)
            } else if let value = try? container.decode(String.self) {
                array.append(value)
            } else if let value = try? container.decode(Int.self) {
                array.append(value)
            } else if let value = try? container.decode(Double.self) {
                array.append(value)
            } else if let nestedDictionary = try? container.decode([String: Any].self) {
                array.append(nestedDictionary)
            }
        }
        return array
    }
    
    func decodeIfPresent(_ type: [Any].Type, forKey key: K) throws -> [Any]? {
        guard contains(key) else { return nil }
        return try decode(type, forKey: key)
    }
}

extension UnkeyedDecodingContainer {
    mutating func decode(_ type: [String: Any].Type) throws -> [String: Any] {
        let container = try self.nestedContainer(keyedBy: DynamicCodingKeys.self)
        var dictionary = [String: Any]()
        
        for key in container.allKeys {
            if let value = try? container.decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = value
            } else if let value = try? container.decode(String.self, forKey: key) {
                dictionary[key.stringValue] = value
            } else if let value = try? container.decode(Int.self, forKey: key) {
                dictionary[key.stringValue] = value
            } else if let value = try? container.decode(Double.self, forKey: key) {
                dictionary[key.stringValue] = value
            }
        }
        return dictionary
    }
}
