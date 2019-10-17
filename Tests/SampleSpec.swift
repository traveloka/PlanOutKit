//
//  SampleSpec.swift
//  PlanOutKitTests
//
//  Created by David Christiandy on 19/08/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

import Quick
import Nimble
@testable import PlanOutKit

final class SampleSpec: QuickSpec {
    override func spec() {
        describe("Sample random operator") {
            let opType = PlanOutOperation.Sample.self
            let op = opType.init()

            itBehavesLike(.randomOperator) { [.op: op] }

            describe("Arguments validation") {
                context("when choices does not exist") {
                    it("returns empty array") {
                        let ctx = SimpleMockContext()
                        let draws = 2
                        let args: [String: Any] = [
                            PlanOutOperation.Keys.unit.rawValue: "x",
                            PlanOutOperation.Keys.draws.rawValue: draws
                        ]

                        var result: Any?

                        expect { result = try op.execute(args, ctx) }.toNot(throwError())
                        expect((result as! [Any])).to(beEmpty())
                    }
                }

                context("when number of draws is not provided") {
                    it("returns the full choices") {
                        let ctx = SimpleMockContext()
                        let choices = [1, 2, 3]
                        let args: [String: Any] = [
                            PlanOutOperation.Keys.unit.rawValue: "x",
                            PlanOutOperation.Keys.choices.rawValue: choices
                        ]

                        var result: Any?

                        expect { result = try op.execute(args, ctx) }.toNot(throwError())
                        expect((result as! [Any]).count) == choices.count
                    }
                }

                context("when number of draws is negative") {
                    it("throws error") {
                        let ctx = SimpleMockContext()
                        let choices = [1, 2, 3]
                        let draws = -1
                        let args: [String: Any] = [
                            PlanOutOperation.Keys.unit.rawValue: "x",
                            PlanOutOperation.Keys.choices.rawValue: choices,
                            PlanOutOperation.Keys.draws.rawValue: draws
                        ]

                        expect { try op.execute(args, ctx) }.to(throwError(errorType: OperationError.self))
                    }
                }

                context("when number of draws is zero") {
                    it("returns empty array") {
                        let ctx = SimpleMockContext()
                        let choices = [1, 2, 3]
                        let draws = 0
                        let args: [String: Any] = [
                            PlanOutOperation.Keys.unit.rawValue: "x",
                            PlanOutOperation.Keys.choices.rawValue: choices,
                            PlanOutOperation.Keys.draws.rawValue: draws
                        ]

                        var result: Any?

                        expect { result = try op.execute(args, ctx) }.toNot(throwError())
                        expect((result as! [Any])).to(beEmpty())
                    }
                }

                context("when number of draws is greater than size of choices") {
                    it("throws error") {
                        let ctx = SimpleMockContext()
                        let choices = [1, 2, 3]
                        let draws = 4
                        let args: [String: Any] = [
                            PlanOutOperation.Keys.unit.rawValue: "x",
                            PlanOutOperation.Keys.choices.rawValue: choices,
                            PlanOutOperation.Keys.draws.rawValue: draws
                        ]

                        expect { try op.execute(args, ctx) }.to(throwError(errorType: OperationError.self))
                    }
                }
            }

            describe("Quick eval method") {
                it("produces different value based on provided unit") {
                    let choices = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                    let draws = 4

                    let array1 = try! opType.quickEval(choices: choices, draws: draws, unit: "1")! as! [Int]
                    let array2 = try! opType.quickEval(choices: choices, draws: draws, unit: "2")! as! [Int]

                    expect(array1) != array2
                }

                it("produces same value based on provided unit") {
                    let choices = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                    let draws = 4

                    let array1 = try! opType.quickEval(choices: choices, draws: draws, unit: "1")! as! [Int]
                    let array2 = try! opType.quickEval(choices: choices, draws: draws, unit: "1")! as! [Int]

                    expect(array1) == array2
                }
            }

            describe("Distribution correctness") {
                context("when number of draws equals to size of choices") {
                    it("samples the choices with uniform distribution") {
                        let choices = [1, 2, 3]
                        let draws = 3
                        let args: [String: Any] = [
                            PlanOutOperation.Keys.choices.rawValue: choices,
                            PlanOutOperation.Keys.draws.rawValue: draws
                        ]
                        let valueMasses: [(Any, Double)] = [(1, 1), (2, 1), (3, 1)]

                        distributionTester(RandomOperatorBuilder(op: op, args: args), valueMass: valueMasses)
                    }
                }

                context("when number of draws is less than size of choices") {
                    it("samples the choices with uniform distribution") {
                        let choices = [1, 2, 3]
                        let draws = 3
                        let args: [String: Any] = [
                            PlanOutOperation.Keys.choices.rawValue: choices,
                            PlanOutOperation.Keys.draws.rawValue: draws
                        ]
                        let valueMasses: [(Any, Double)] = [(1, 1), (2, 1), (3, 1)]

                        distributionTester(RandomOperatorBuilder(op: op, args: args), valueMass: valueMasses)
                    }
                }

                context("when there are duplicated values within the choices") {
                    it("samples the choices with added weight for the duplicated choices") {
                        let choices = [2, 2, 3]
                        let draws = 3
                        let args: [String: Any] = [
                            PlanOutOperation.Keys.choices.rawValue: choices,
                            PlanOutOperation.Keys.draws.rawValue: draws
                        ]
                        let valueMasses: [(Any, Double)] = [(2, 2), (3, 1)]

                        distributionTester(RandomOperatorBuilder(op: op, args: args), valueMass: valueMasses)
                    }
                }
            }
        }
    }
}
