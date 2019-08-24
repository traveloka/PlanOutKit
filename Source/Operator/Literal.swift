//
//  Literal.swift
//  PlanoutKit
//
//  Created by David Christiandy on 09/08/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

enum Literal {
    /// String literal representation.
    case string(String)

    /// Number literal representation.
    ///
    /// Numbers are represented by `Double`, since it can correctly represent both integers and floating points. `Int` values will be type-casted to `Double`.
    case number(Double)

    /// Boolean literal representation.
    case boolean(Bool)

    /// Array literal representation.
    case list([Any?])

    /// Dictionary representation based on compiled PlanOut script.
    case dictionary([String: Any?])

    /// Other values that are not representable by literal types.
    case nonLiteral

    init(_ value: Any) {
        switch value {
        case let val as String:
            self = .string(val)
        case let val as Bool:
            self = .boolean(val)
        case let val as Int:
            self = .number(Double(val))
        case let val as Double:
            self = .number(val)
        case let val as [Any?]:
            self = .list(val)
        case let val as [String: Any?]:
            self = .dictionary(val)
        default:
            self = .nonLiteral
        }
    }


    /// Private initializer to simplify nil value processing.
    ///
    /// - Parameter optionalValue: Optional value
    private init?(with optionalValue: Any?) {
        guard let someValue = optionalValue else {
            return nil
        }

        self.init(someValue)
    }
}

extension Literal {
    /// Converts the literal value to boolean.
    ///
    /// The conversion decision follows the original PlanOut interpreter implementation, which follows Python's
    /// implicit typecast from its `Any`-equivalent type to `Bool`:
    /// - String: `true` if not empty
    /// - Numeric: `true` if value is not 0
    /// - Array: `true` if not empty
    /// - Dictionary: `true` if not empty
    /// - Non-literals and others are `false` by default.
    var boolValue: Bool {
        switch self {
        case .string(let stringValue):
            return !stringValue.isEmpty
        case .number(let doubleValue):
            return doubleValue != 0
        case .boolean(let boolValue):
            return boolValue
        case .list(let arrayValue):
            return !arrayValue.isEmpty
        case .dictionary(let dictionaryValue):
            return !dictionaryValue.isEmpty
        default:
            return false
        }
    }
}

extension Literal: Equatable {

    static func == (lhs: Literal, rhs: Literal) -> Bool {
        switch (lhs, rhs) {
        case (string(let left), string(let right)):
            return left == right

        case (number(let left), number(let right)):
            return left == right

        case (boolean(let left), boolean(let right)):
            return left == right

        case (list(let left), list(let right)):
            // Equatable operator cannot be used for arrays where the elements are not guaranteed Equatable. Therefore, both values should be mapped to Literal first, and then compared.
            return left.map { Literal(with: $0) } == right.map { Literal(with: $0) }

        case (dictionary(let left), dictionary(let right)):
            // For a dictionary literal to equal to each other, it should have:
            // - The same set of keys.
            // - Equal values for the given the keys.
            return left.mapValues { Literal(with: $0) } == right.mapValues { Literal(with: $0) }

        // for boolean vs other types, compare against their boolValues
        case (boolean(let left), _):
            return left == rhs.boolValue

        case (_, boolean(let right)):
            return lhs.boolValue == right

        case (nonLiteral, nonLiteral):
            // If both types are not literals, then should it be equal to each other?
            // Non literals, such as nil types, custom objects, and structs are generalized as "non-literal", and thus they are equal when compared to each other.
            return true

        default:
            // If the literal is different, then obviously they are not equal.
            return false
        }
    }
}

extension Literal: Encodable {
    func encode(to encoder: Encoder) throws {
        switch self {
        case .string(let stringValue):
            try stringValue.encode(to: encoder)
        case .number(let doubleValue):
            try doubleValue.encode(to: encoder)
        case .boolean(let boolValue):
            try boolValue.encode(to: encoder)
        case .list(let arrayValue):
            // transform to encodable array.
            try arrayValue.map { Literal(with: $0) }.encode(to: encoder)
        case .dictionary(let dictionaryValue):
            // transform to encodable dictionary.
            try dictionaryValue.mapValues { Literal(with: $0) }.encode(to: encoder)
        default:
            throw OperationError.unexpected("Cannot encode \(self)")
        }
    }
}
