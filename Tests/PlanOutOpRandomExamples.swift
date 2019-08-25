//
//  PlanOutOpRandomExamples.swift
//  PlanOutKitTests
//
//  Created by David Christiandy on 19/08/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

import Quick
import Nimble
@testable import PlanOutKit

final class PlanOutOpRandomSharedExamplesConfiguration: QuickConfiguration {
    override class func configure(_ configuration: Configuration) {
        sharedExamples(SharedBehavior.randomOperator.rawValue) { context in
            let op = context() [SharedBehavior.Keys.op.rawValue] as! PlanOutExecutable
            let ctx = SimpleMockContext()

            itBehavesLike(.simpleOperator) { [.op: op] }

            describe("Unit value resolution") {
                it("throws if unit key does not exist in arguments") {
                    let args: [String: Any] = ["salt": "x"]

                    expect { try op.executeOp(args: args, context: ctx) }.to(throwError(errorType: OperationError.self))
                }

                it("throws if unit value is numeric type") {
                    let unitValue = 10
                    let args: [String: Any] = ["unit": unitValue, "salt": "x"]

                    expect { try op.executeOp(args: args, context: ctx) }.to(throwError(errorType: OperationError.self))
                }
                it("throws if unit value is dictionary type") {
                    let unitValue = ["foo": "Bar"]
                    let args: [String: Any] = ["unit": unitValue, "salt": "x"]

                    expect { try op.executeOp(args: args, context: ctx) }.to(throwError(errorType: OperationError.self))
                }
                it("throws if unit value is boolean type") {
                    let unitValue = false
                    let args: [String: Any] = ["unit": unitValue, "salt": "x"]

                    expect { try op.executeOp(args: args, context: ctx) }.to(throwError(errorType: OperationError.self))
                }
                it("throws if unit value is non literal type") {
                    struct Foo {}
                    let unitValue = Foo()
                    let args: [String: Any] = ["unit": unitValue, "salt": "x"]

                    expect { try op.executeOp(args: args, context: ctx) }.to(throwError(errorType: OperationError.self))
                }
            }

            it("is a random operator") {
                expect(op.isRandomOperator) == true
            }
        }
    }
}
