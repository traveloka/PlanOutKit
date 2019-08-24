//
//  Coalesce.swift
//  PlanoutKit
//
//  Created by David Christiandy on 14/08/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

extension PlanOutOperation {
    /// Returns the first evaluated result that is not nil.
    final class Coalesce: PlanOutOp {
        func execute(_ args: [String : Any], _ context: PlanOutOpContext) throws -> Any? {
            return try Array().execute(args, context)?.compactMap { $0 }.first
        }
    }
}
