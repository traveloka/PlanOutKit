//
//  UniformChoice.swift
//  PlanoutKit
//
//  Created by David Christiandy on 14/08/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

extension PlanOutOperation {
    /// Deterministically make a random choice with uniform probability based on given unit.
    final class UniformChoice: PlanOutOpRandom<Any> {
        override func randomExecute() throws -> Any? {
            guard let choices = args[Keys.choices.rawValue] as? [Any], !choices.isEmpty else {
                return nil
            }

            let length = choices.count
            let randomizedIndex = Int(try hash() % Int64(length))

            return choices[randomizedIndex]
        }
    }
}

