//
//  Length.swift
//  PlanoutKit
//
//  Created by David Christiandy on 14/08/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

extension PlanOutOperation {
    /// Calculates the length of a Literal type.
    ///
    /// - For `String` types, it simply returns the length of the string.
    /// - For `Array` types, it returns the number of element contained within the array.
    /// - For `Dictionary` types, it returns the number of key/value pairs within the dictionary.
    final class Length: PlanOutOpUnary {
        typealias ResultType = Int // Length cannot be fractional.

        func unaryExecute(_ value: Any?) throws -> Int? {
            guard let someValue = value else {
                return 0
            }

            switch Literal(someValue) {
            case .string(let stringValue):
                return stringValue.count
            case .list(let arrayValue):
                return arrayValue.count
            case .dictionary(let dictionaryValue):
                return dictionaryValue.keys.count
            default:
                throw OperationError.typeMismatch(expected: "String/List/Dictionary", got: String(describing: value))
            }
        }
    }
}
