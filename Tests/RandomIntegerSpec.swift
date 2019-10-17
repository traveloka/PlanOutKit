//
//  RandomIntegerSpec.swift
//  PlanOutKitTests
//
//  Created by David Christiandy on 19/08/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

import Quick
import Nimble
@testable import PlanOutKit

final class RandomIntegerSpec: QuickSpec {
    override func spec() {
        describe("RandomInteger random operator") {
            let opType = PlanOutOperation.RandomInteger.self
            let op = opType.init()

            itBehavesLike(.randomOperator) { [.op: op] }

            describe("Argument validation") {
                it("throws if min value does not exist in the arguments") {
                    let ctx = SimpleMockContext()
                    let maxValue = 1
                    let args: [String: Any] = [
                        PlanOutOperation.Keys.unit.rawValue: "x",
                        PlanOutOperation.Keys.max.rawValue: maxValue
                    ]

                    expect { try op.execute(args, ctx) }.to(throwError(errorType: OperationError.self))
                }

                it("throws if min value does not exist in the arguments") {
                    let ctx = SimpleMockContext()
                    let minValue = 1
                    let args: [String: Any] = [
                        PlanOutOperation.Keys.unit.rawValue: "x",
                        PlanOutOperation.Keys.min.rawValue: minValue
                    ]

                    expect { try op.execute(args, ctx) }.to(throwError(errorType: OperationError.self))
                }

                it("throws if min value is larger than max value") {
                    let ctx = SimpleMockContext()
                    let minValue = 4
                    let maxValue = 1
                    let args: [String: Any] = [
                        PlanOutOperation.Keys.unit.rawValue: "x",
                        PlanOutOperation.Keys.min.rawValue: minValue,
                        PlanOutOperation.Keys.max.rawValue: maxValue
                    ]

                    expect { try op.execute(args, ctx) }.to(throwError(errorType: OperationError.self))
                }
            }

            describe("Quick eval method") {
                it("produces different value based on provided unit") {
                    let x = try! opType.quickEval(min: 1, max: 1000, unit: "x")!
                    let y = try! opType.quickEval(min: 1, max: 1000, unit: "y")!

                    expect(x) != y
                }

                it("produces equal value if provided unit is the same") {
                    let x1 = try! opType.quickEval(min: 1, max: 1000, unit: "x")!
                    let x2 = try! opType.quickEval(min: 1, max: 1000, unit: "x")!

                    expect(x1) == x2
                }

                it("debug") {
                    let value: String = "f64fa0499c25757"
                    let numericHash = Int(value, radix: 16)
                    print(numericHash)
                }
            }

            describe("Distribution correctness") {
                it("generates random integers with uniform distribution") {
                    let minVal = 1
                    let maxVal = 5
                    let args = [
                        PlanOutOperation.Keys.min.rawValue: minVal,
                        PlanOutOperation.Keys.max.rawValue: maxVal,
                    ]

                    // produces [(1, 1), (2, 1), (3, 1), (4, 1), (5, 1)]
                    let valueMasses: [(Any, Double)] = (minVal...maxVal).map { ($0, 1) }

                    distributionTester(RandomOperatorBuilder(op: op, args: args), valueMass: valueMasses)
                }
            }
        }
    }
}
