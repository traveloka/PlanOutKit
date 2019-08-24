//
//  Get.swift
//  PlanoutKit
//
//  Created by David Christiandy on 14/08/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

import Foundation

extension PlanOutOperation {
    /// Obtain values from the provided context.
    final class Get: PlanOutOp {
        func execute(_ args: [String: Any], _ context: PlanOutOpContext) throws -> Any? {
            guard let value = args[Keys.variable.rawValue] else {
                throw OperationError.missingArgs(args: Keys.variable.rawValue, type: self)
            }

            guard let varName = value as? String else {
                throw OperationError.invalidArgs(expected: "\(Keys.variable.rawValue) to be String", got: String(describing: value))
            }

            return try context.get(varName)
        }
    }
}
