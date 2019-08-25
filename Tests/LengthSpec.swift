//
//  LengthSpec.swift
//  PlanOutKitTests
//
//  Created by David Christiandy on 19/08/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

import Quick
import Nimble
@testable import PlanOutKit

final class LengthSpec: QuickSpec {
    override func spec() {
        describe("Length unary operator") {
            let op = PlanOutOperation.Length()

            itBehavesLike(.unaryOperator) { [.op: op] }

            context("when given string types") {
                it("returns the length of the text") {
                    let value = "some string!"
                    let args = [PlanOutOperation.Keys.value.rawValue: value]
                    var result: Int?

                    expect { result = try op.execute(args, Interpreter()) }.toNot(throwError())
                    expect(result!).to(equal(value.count))
                }
            }
            context("when given numeric types") {
                it("throws") {
                    let value = 1.0
                    let args = [PlanOutOperation.Keys.value.rawValue: value]

                    expect { try op.execute(args, Interpreter()) }.to(throwError(errorType: OperationError.self))
                }
            }
            context("when given list types") {
                it("returns the number of elements in the list") {
                    let value = [1, 2, 3]
                    let args = [PlanOutOperation.Keys.value.rawValue: value]
                    var result: Int?

                    expect { result = try op.execute(args, Interpreter()) }.toNot(throwError())
                    expect(result!).to(equal(value.count))
                }
            }
            context("when given dictionary types") {
                it("returns the number of key value pairs in the dictionary") {
                    let value = ["a": 1, "b": 2, "c": 3, "d": 4]
                    let args = [PlanOutOperation.Keys.value.rawValue: value]
                    var result: Int?

                    expect { result = try op.execute(args, Interpreter()) }.toNot(throwError())
                    expect(result!).to(equal(value.count))
                }
            }

            context("when given nil values") {
                it("returns 0") {
                    let value: Any? = nil
                    let args = [PlanOutOperation.Keys.value.rawValue: value as Any]
                    var result: Int?

                    expect { result = try op.execute(args, Interpreter()) }.toNot(throwError())
                    expect(result!) == 0
                }
            }

            context("when given non literal types") {
                it("throws") {
                    let value = [1: 2, 2: 3]
                    let args = [PlanOutOperation.Keys.value.rawValue: value]

                    expect { try op.execute(args, Interpreter()) }.to(throwError(errorType: OperationError.self))
                }
            }
        }
    }
}
