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

/// Build a valid JSON Schema "object" with properties and required fields.
func jsonSchema(
    properties: [String: Value],
    required: [String] = []
) -> Value {
    var schema: [String: Value] = [
        "type": .string("object"),
        "properties": .object(properties),
    ]
    if !required.isEmpty {
        schema["required"] = .array(required.map { .string($0) })
    }
    return .object(schema)
}

/// Build a JSON Schema property of type "string" with a description.
func stringProperty(_ description: String) -> Value {
    .object([
        "type": .string("string"),
        "description": .string(description),
    ])
}
