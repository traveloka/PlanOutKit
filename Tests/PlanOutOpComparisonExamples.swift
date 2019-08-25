//
//  PlanOutOpComparisonExamples.swift
//  PlanOutKitTests
//
//  Created by David Christiandy on 18/08/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

import Quick
import Nimble
@testable import PlanOutKit

func comparisonArgsBuilder(_ minValue: Any, _ maxValue: Any) -> [String: Any] {
    return [PlanOutOperation.Keys.left.rawValue: minValue, PlanOutOperation.Keys.right.rawValue: maxValue]
}

final class PlanOutOpComparisonSharedExamplesConfiguration: QuickConfiguration {
    override class func configure(_ configuration: Configuration) {
        sharedExamples(SharedBehavior.comparisonOperator.rawValue) { context in
            let op = context() [SharedBehavior.Keys.op.rawValue] as! PlanOutExecutable

            itBehavesLike(SharedBehavior.binaryOperator.rawValue) { [SharedBehavior.Keys.op.rawValue: op] }


            it("should not throw errors for arguments with numeric types") {
                let leftValue = 1
                let rightValue = 1
                let args: [String: Any] = [
                    PlanOutOperation.Keys.left.rawValue: leftValue,
                    PlanOutOperation.Keys.right.rawValue: rightValue
                ]

                expect { try op.executeOp(args: args, context: Interpreter()) }.toNot(throwError())
            }

            it("should not throw errors for arguments with different numeric types") {
                let leftValue = 1.0
                let rightValue = 2
                let args: [String: Any] = [
                    PlanOutOperation.Keys.left.rawValue: leftValue,
                    PlanOutOperation.Keys.right.rawValue: rightValue
                ]

                expect { try op.executeOp(args: args, context: Interpreter()) }.toNot(throwError())
            }

            it("throws error when left argument is nil") {
                let leftValue: Any? = nil
                let rightValue = 1
                let args: [String: Any] = [
                    PlanOutOperation.Keys.left.rawValue: leftValue as Any,
                    PlanOutOperation.Keys.right.rawValue: rightValue
                ]

                expect { try op.executeOp(args: args, context: Interpreter()) }.to(throwError(errorType: OperationError.self))
            }

            it("throws error when right argument is nil") {
                let leftValue = 1
                let rightValue: Any? = nil
                let args: [String: Any] = [
                    PlanOutOperation.Keys.left.rawValue: leftValue,
                    PlanOutOperation.Keys.right.rawValue: rightValue as Any
                ]

                expect { try op.executeOp(args: args, context: Interpreter()) }.to(throwError(errorType: OperationError.self))
            }

            it("throws error when both arguments are nil") {
                let leftValue: Any? = nil
                let rightValue: Any? = nil
                let args: [String: Any] = [
                    PlanOutOperation.Keys.left.rawValue: leftValue as Any,
                    PlanOutOperation.Keys.right.rawValue: rightValue as Any
                ]

                expect { try op.executeOp(args: args, context: Interpreter()) }.to(throwError(errorType: OperationError.self))
            }

            it("throws error for arguments with array types") {
                let leftValue = [1, 2, 3]
                let rightValue = [1, 2]
                let args: [String: Any] = [
                    PlanOutOperation.Keys.left.rawValue: leftValue,
                    PlanOutOperation.Keys.right.rawValue: rightValue
                ]

                expect { try op.executeOp(args: args, context: Interpreter()) }.to(throwError(errorType: OperationError.self))
            }

            it("throws error for arguments with dictionary types") {
                let leftValue = ["a": "b"]
                let rightValue = ["c": "d"]
                let args: [String: Any] = [
                    PlanOutOperation.Keys.left.rawValue: leftValue,
                    PlanOutOperation.Keys.right.rawValue: rightValue
                ]

                expect { try op.executeOp(args: args, context: Interpreter()) }.to(throwError(errorType: OperationError.self))
            }

            it("throws error for arguments with different comparable types") {
                let leftValue = "2"
                let rightValue = 3
                let args: [String: Any] = [
                    PlanOutOperation.Keys.left.rawValue: leftValue,
                    PlanOutOperation.Keys.right.rawValue: rightValue
                ]

                expect { try op.executeOp(args: args, context: Interpreter()) }.to(throwError(errorType: OperationError.self))
            }

            it("throws error for arguments with non literal types") {
                struct Foo {}
                let leftValue = Foo()
                let rightValue = Foo()
                let args: [String: Any] = [
                    PlanOutOperation.Keys.left.rawValue: leftValue,
                    PlanOutOperation.Keys.right.rawValue: rightValue
                ]

                expect { try op.executeOp(args: args, context: Interpreter()) }.to(throwError(errorType: OperationError.self))
            }
        }
    }
}
