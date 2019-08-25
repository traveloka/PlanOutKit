//
//  Not.swift
//  PlanoutKit
//
//  Created by David Christiandy on 14/08/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

extension PlanOutOperation {
    /// Returns the opposite of given boolean value.
    final class Not: PlanOutOpUnary {
        typealias ResultType = Bool

        func unaryExecute(_ value: Any?) throws -> Bool? {
            guard let someValue = value else {
                return true
            }
            
            return !Literal(someValue).boolValue
        }
    }
}
