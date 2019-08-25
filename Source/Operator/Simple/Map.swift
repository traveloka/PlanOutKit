//
//  Map.swift
//  PlanoutKit
//
//  Created by David Christiandy on 14/08/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

extension PlanOutOperation {
    // returns a copy of a given dictionary.
    final class Map: PlanOutOpSimple {
        typealias ResultType = [String: Any?]

        func simpleExecute(_ args: [String : Any?], _ context: PlanOutOpContext) throws -> [String: Any?]? {
            var copyArgs = args

            copyArgs.removeValue(forKey: Keys.op.rawValue)
            copyArgs.removeValue(forKey: Keys.salt.rawValue)

            return copyArgs
        }
    }
}
