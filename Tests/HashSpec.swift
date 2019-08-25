//
//  HashSpec.swift
//  PlanOutKitTests
//
//  Created by David Christiandy on 25/08/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

import Quick
import Nimble
@testable import PlanOutKit

private class MockRandomOp: PlanOutOpRandom<Int> {
    override func randomExecute() throws -> Int? {
        return 0
    }
}

final class HashSpec: QuickSpec {
    override func spec() {
        describe("Random operator hash") {
            context("when operator has not been evaluated yet") {
                it("should throw error") {
                    let op = MockRandomOp()

                    expect { try op.hash() }.to(throwError(errorType: OperationError.self))
                }
            }

            context("when fullSalt is provided as argument") {
                it("prefers fullSalt value over salt value") {
                    let op1 = MockRandomOp()
                    let args1: [String: Any] = [
                        PlanOutOperation.Keys.unit.rawValue: "foo",
                        PlanOutOperation.Keys.fullSalt.rawValue: "fs",
                        PlanOutOperation.Keys.salt.rawValue: "salt1"
                    ]

                    let op2 = MockRandomOp()
                    let args2: [String: Any] = [
                        PlanOutOperation.Keys.unit.rawValue: "foo",
                        PlanOutOperation.Keys.fullSalt.rawValue: "fs",
                        PlanOutOperation.Keys.salt.rawValue: "salt2"
                    ]

                    let _ = try! op1.execute(args1, SimpleMockContext())
                    let _ = try! op2.execute(args2, SimpleMockContext())

                    let hash1 = try! op1.hash()
                    let hash2 = try! op2.hash()
                    expect(hash1) == hash2
                }
            }
        }
    }
}
