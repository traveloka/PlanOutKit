//
//  PlanOutOpUnary.swift
//  PlanoutKit
//
//  Created by David Christiandy on 11/08/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

import Foundation

protocol PlanOutOpUnary: PlanOutOpSimple {
    func unaryExecute(_ value: Any?) throws -> ResultType?
}

extension PlanOutOpUnary {
    func simpleExecute(_ args: [String: Any?], _ context: PlanOutOpContext) throws -> ResultType? {
        guard let value = args[PlanOutOperation.Keys.value.rawValue] else {
            throw OperationError.missingArgs(args: PlanOutOperation.Keys.value.rawValue, type: self)
        }

        return try unaryExecute(value)
    }
}
