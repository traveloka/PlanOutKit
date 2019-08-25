//
//  MapSpec.swift
//  PlanOutKitTests
//
//  Created by David Christiandy on 19/08/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

import Quick
import Nimble
@testable import PlanOutKit

final class MapSpec: QuickSpec {
    override func spec() {
        describe("Map simple operator") {
            let op = PlanOutOperation.Map()

            itBehavesLike(.simpleOperator) { [.op: op] }

            it("returns a copy of arguments") {
                let args = ["a": 1, "b": 2]
                var result: [String: Any?]?

                expect { result = try op.execute(args, Interpreter()) }.toNot(throwError())
                expect((result! as! [String: Int])) == args
            }

            it("strips op and salt from the copied arguments") {
                let args: [String: Any] = ["a": 1, "op": "foo", "salt": "123"]
                var result: [String: Any?]?

                expect { result = try op.execute(args, Interpreter()) }.toNot(throwError())
                expect(result!["op"]).to(beNil())
                expect(result!["salt"]).to(beNil())
            }

            it("does not mutate original arguments") {
                let args: [String: Any] = ["a": 1, "op": "foo", "salt": "123"]

                expect { try op.execute(args, Interpreter()) }.toNot(throwError())
                expect(args["op"]).toNot(beNil())
                expect(args["salt"]).toNot(beNil())
            }
        }
    }
}

