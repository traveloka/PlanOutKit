//
//  SaltSpec.swift
//  PlanOutKitTests
//
//  Created by David Christiandy on 20/08/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

import Quick
import Nimble
@testable import PlanOutKit

final class SaltSpec: QuickSpec {
    override func spec() {
        describe("Random operator salt behavior") {
            // RandomInteger is used for demonstration purposes.
            // tests regarding the operator's distribution correctness is written at RandomIntegerSpec.
            let op = PlanOutOperation.RandomInteger()
            let unit = Unit(keys: ["i"], inputs: ["i": "20"])

            context("when assigned to different variable name") {
                context("given that the salt is unspecified") {
                    it("yields different randomization results") {
                        // assigning variables with different names and the same unit should yield
                        // different randomizations, when salts are not explicitly specified
                        let interpreter = Interpreter(serialization: [:], salt: "assign_salt_a", unit: unit)
                        let args: [String: Any] = [
                            PlanOutOperation.Keys.min.rawValue: 0,
                            PlanOutOperation.Keys.max.rawValue: 100000,
                            PlanOutOperation.Keys.unit.rawValue: "20"
                        ]

                        try! interpreter.set("x", value: (op, args))
                        try! interpreter.set("y", value: (op, args))

                        let resultX: Int = try! interpreter.get("x")! as! Int
                        let resultY: Int = try! interpreter.get("y")! as! Int

                        expect(resultX) != resultY
                    }
                }
                context("given that salt is specified") {
                    it("yields the same result") {
                        // when salts are specified, they act the same way auto-salting does
                        let interpreter = Interpreter(serialization: [:], salt: "assign_salt_a", unit: unit)
                        let args: [String: Any] = [
                            PlanOutOperation.Keys.min.rawValue: 0,
                            PlanOutOperation.Keys.max.rawValue: 100000,
                            PlanOutOperation.Keys.unit.rawValue: "20",
                            PlanOutOperation.Keys.salt.rawValue: "x"
                        ]

                        try! interpreter.set("x", value: (op, args))
                        try! interpreter.set("y", value: (op, args))

                        let resultX: Int = try! interpreter.get("x")! as! Int
                        let resultY: Int = try! interpreter.get("y")! as! Int

                        expect(resultX) == resultY
                    }
                }
            }

            context("when assigned to the same variable name") {
                context("when the assignment-level salt is the same") {
                    let args: [String: Any] = [
                        PlanOutOperation.Keys.min.rawValue: 0,
                        PlanOutOperation.Keys.max.rawValue: 100000,
                        PlanOutOperation.Keys.unit.rawValue: "20"
                    ]

                    // the assignment salt is the same.
                    let interpreterA = Interpreter(serialization: [:], salt: "assign_salt_a", unit: unit)
                    let interpreterB = Interpreter(serialization: [:], salt: "assign_salt_a", unit: unit)

                    try! interpreterA.set("x", value: (op, args))
                    try! interpreterB.set("x", value: (op, args))

                    let resultA: Int = try! interpreterA.get("x")! as! Int
                    let resultB: Int = try! interpreterB.get("x")! as! Int

                    expect(resultA) == resultB
                }
                context("when the assignment-level salt is different") {
                    it("yields different values") {
                        let args: [String: Any] = [
                            PlanOutOperation.Keys.min.rawValue: 0,
                            PlanOutOperation.Keys.max.rawValue: 100000,
                            PlanOutOperation.Keys.unit.rawValue: "20"
                        ]

                        // the assignment salt is different.
                        let interpreterA = Interpreter(serialization: [:], salt: "assign_salt_a", unit: unit)
                        let interpreterB = Interpreter(serialization: [:], salt: "assign_salt_b", unit: unit)

                        try! interpreterA.set("x", value: (op, args))
                        try! interpreterB.set("x", value: (op, args))

                        let resultA: Int = try! interpreterA.get("x")! as! Int
                        let resultB: Int = try! interpreterB.get("x")! as! Int

                        expect(resultA) != resultB
                    }
                }
            }

            context("when full salt is specified") {
                it("yields the same result when assigned to the same variable name") {
                    let args: [String: Any] = [
                        PlanOutOperation.Keys.min.rawValue: 0,
                        PlanOutOperation.Keys.max.rawValue: 100000,
                        PlanOutOperation.Keys.unit.rawValue: "20",
                        PlanOutOperation.Keys.fullSalt.rawValue: "full_salt"
                    ]

                    // assignment-level salt is different
                    let interpreterA = Interpreter(serialization: [:], salt: "assign_salt_a", unit: unit)
                    let interpreterB = Interpreter(serialization: [:], salt: "assign_salt_b", unit: unit)

                    // variable name is the same
                    try! interpreterA.set("x", value: (op, args))
                    try! interpreterB.set("x", value: (op, args))

                    let resultA: Int = try! interpreterA.get("x")! as! Int
                    let resultB: Int = try! interpreterB.get("x")! as! Int

                    // the result should still use full_salt.
                    expect(resultA) == resultB
                }

                it("yields the same result when assigned to different variable name") {
                    let args: [String: Any] = [
                        PlanOutOperation.Keys.min.rawValue: 0,
                        PlanOutOperation.Keys.max.rawValue: 100000,
                        PlanOutOperation.Keys.unit.rawValue: "20",
                        PlanOutOperation.Keys.fullSalt.rawValue: "full_salt"
                    ]

                    // assignment-level salt is different
                    let interpreterA = Interpreter(serialization: [:], salt: "assign_salt_a", unit: unit)
                    let interpreterB = Interpreter(serialization: [:], salt: "assign_salt_b", unit: unit)

                    // variable name is different
                    try! interpreterA.set("x", value: (op, args))
                    try! interpreterB.set("y", value: (op, args))

                    let resultA: Int = try! interpreterA.get("x")! as! Int
                    let resultB: Int = try! interpreterB.get("y")! as! Int

                    // the result should still use full_salt.
                    expect(resultA) == resultB
                }
            }
        }
    }
}

