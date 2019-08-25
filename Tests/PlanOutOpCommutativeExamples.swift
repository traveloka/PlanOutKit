//
//  PlanOutOpCommutativeSharedExamples.swift
//  PlanOutKitTests
//
//  Created by David Christiandy on 18/08/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

import Quick
import Nimble
@testable import PlanOutKit

func commutativeArgsBuilder(_ values: [Any]) -> [String: Any] {
    return [PlanOutOperation.Keys.values.rawValue: values]
}

final class PlanOutOpCommutativeSharedExamplesConfiguration: QuickConfiguration {
    override class func configure(_ configuration: Configuration) {
        sharedExamples(SharedBehavior.commutativeOperator.rawValue) { context in
            let op = context() [SharedBehavior.Keys.op.rawValue] as! PlanOutExecutable
            let ctx = Interpreter()

            itBehavesLike(.simpleOperator) { [.op: op] }

            it("should not throw errors for arguments with numeric types") {
                let values = [1, 2, 3]
                let args: [String: Any] = commutativeArgsBuilder(values)

                expect { try op.executeOp(args: args, context: ctx) }.toNot(throwError())
            }

            it("should not throw errors for arguments with mixed numeric types") {
                let values = [1, 2.0, 3.0]
                let args: [String: Any] = commutativeArgsBuilder(values)

                expect { try op.executeOp(args: args, context: ctx) }.toNot(throwError())
            }

            it("throws error if values are not numeric type") {
                let values = ["foo", "bar", "baz"]
                let args: [String: Any] = commutativeArgsBuilder(values)

                expect { try op.executeOp(args: args, context: ctx) }.to(throwError(errorType: OperationError.self))
            }

            it("throws error if values does not exist") {
                let values = ["foo", "bar", "baz"]
                let args: [String: Any] = ["foo": values]

                expect { try op.executeOp(args: args, context: ctx) }.to(throwError(errorType: OperationError.self))
            }

            it("throws if there are nil values within the collection") {
                let values: Any? = [1, nil, 3]
                let args: [String: Any] = ["foo": values as Any]

                expect { try op.executeOp(args: args, context: ctx) }.to(throwError(errorType: OperationError.self))
            }
        }
    }
}

