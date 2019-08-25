//
//  RoundSpec.swift
//  PlanOutKitTests
//
//  Created by David Christiandy on 19/08/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

import Quick
import Nimble
@testable import PlanOutKit

final class RoundSpec: QuickSpec {
    override func spec() {
        describe("Round unary operator") {
            let op = PlanOutOperation.Round()

            itBehavesLike(.unaryOperator) { [.op: op] }

            itBehavesLike(.numericOperator) { [.op: op, .argKeys: [PlanOutOperation.Keys.value.rawValue]] }
            
            it("returns the rounded numerical value") {
                let value = 3.2
                let args = [PlanOutOperation.Keys.value.rawValue: value]
                var result: Double?

                expect { result = try op.execute(args, Interpreter()) }.toNot(throwError())
                expect(result!).to(equal(3.0))
            }

            it("should also round integer values") {
                let value = 4
                let args = [PlanOutOperation.Keys.value.rawValue: value]
                var result: Double?

                expect { result = try op.execute(args, Interpreter()) }.toNot(throwError())
                expect(result!).to(equal(4.0))
            }

            it("throws when given nil value") {
                let value: Any? = nil
                let args = [PlanOutOperation.Keys.value.rawValue: value as Any]

                expect { try op.execute(args, Interpreter()) }.to(throwError(errorType: OperationError.self))
            }
        }
    }
}
