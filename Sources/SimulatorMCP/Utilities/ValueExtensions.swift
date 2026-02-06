import MCP

extension Value {
    var stringValue: String? {
        if case .string(let s) = self { return s }
        return nil
    }
}

func requiredString(_ key: String, from arguments: [String: Value]?) throws -> String {
    guard let value = arguments?[key]?.stringValue else {
        throw SimulatorError.missingParameter(key)
    }
    return value
}
