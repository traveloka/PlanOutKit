//
//  NotSpec.swift
//  PlanOutKitTests
//
//  Created by David Christiandy on 19/08/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

import Quick
import Nimble
@testable import PlanOutKit

final class NotSpec: QuickSpec {
    override func spec() {
        describe("Not unary operator") {
            let op = PlanOutOperation.Not()

            itBehavesLike(.unaryOperator) { [.op: op] }

            /*
             Further tests regarding Literal to boolean value conversion is covered in the LiteralSpec.
             */

            it("returns the negation of boolean equivalent from the value") {
                let value = "some string!"
                let args = [PlanOutOperation.Keys.value.rawValue: value]
                var result: Bool?

                expect { result = try op.execute(args, Interpreter()) }.toNot(throwError())
                expect(result!) == false
            }

            it("returns true when given nil value") {
                let value: Any? = nil
                let args = [PlanOutOperation.Keys.value.rawValue: value as Any]
                var result: Bool?

                expect { result = try op.execute(args, Interpreter()) }.toNot(throwError())
                expect(result!) == true
            }
        }
    }
}
