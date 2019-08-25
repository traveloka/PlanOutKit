//
//  EqualsSpec.swift
//  PlanOutKitTests
//
//  Created by David Christiandy on 19/08/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

import Quick
import Nimble
@testable import PlanOutKit

final class EqualsSpec: QuickSpec {
    override func spec() {
        describe("Equals binary operator") {
            let op = PlanOutOperation.Equals()

            itBehavesLike(.binaryOperator) { [.op: op] }

            /*
             Further tests regarding value equality is covered in the LiteralSpec (Equatable tests)
             */

            it("returns the remainder value from the argument") {
                let left = 4
                let right = 3
                let args = binaryArgsBuilder(left, right)
                var result: Bool?

                expect { result = try op.execute(args, Interpreter()) }.toNot(throwError())
                expect(result!).to(equal(false))
            }

            context("when given nil values") {
                it("returns false when only lefthand value is nil") {
                    let left: Any? = nil
                    let right = 3
                    let args = binaryArgsBuilder(left as Any, right)
                    var result: Bool?

                    expect { result = try op.execute(args, Interpreter()) }.toNot(throwError())
                    expect(result!) == false
                }
                it("returns false when only righthand value is nil") {
                    let left = 4
                    let right: Any? = nil
                    let args = binaryArgsBuilder(left, right as Any)
                    var result: Bool?

                    expect { result = try op.execute(args, Interpreter()) }.toNot(throwError())
                    expect(result!) == false
                }
                it("returns true when both values are nil") {
                    let left: Any? = nil
                    let right: Any? = nil
                    let args = binaryArgsBuilder(left as Any, right as Any)
                    var result: Bool?

                    expect { result = try op.execute(args, Interpreter()) }.toNot(throwError())
                    expect(result!) == true
                }
            }
        }
    }
}
