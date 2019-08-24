//
//  ArraySpec.swift
//  PlanOutKitTests
//
//  Created by David Christiandy on 19/08/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

import Quick
import Nimble
@testable import PlanOutKit

final class ArraySpec: QuickSpec {
    override func spec() {
        describe("Array operator") {
            let op = PlanOutOperation.Array()

            it("throws if values key does not exist") {
                let args = ["a": 1]
                let context = MockNumstringContext()

                expect { try op.execute(args, context) }.to(throwError(errorType: OperationError.self))
            }

            it("returns an array containing evaluated values") {
                let values: [Any] = [1, 2, 3, 4]
                let args: [String: Any] = ["values": values]
                let context = MockNumstringContext()
                var result: Any?

                expect { result = try op.execute(args, context) }.toNot(throwError())
                expect((result as! [String])) == ["1", "2", "3", "4"]
            }

            it("should be able to produce array with nil values") {
                let values: [Any] = [1, 2, 10, 4]
                let args: [String: Any] = ["values": values]
                let context = MockNumstringContext()
                var result: Any?

                expect { result = try op.execute(args, context) }.toNot(throwError())
                expect((result as! [String?])) == ["1", "2", nil, "4"]
            }
        }
    }
}

private struct MockNumstringContext: PlanOutOpContext {
    var experimentSalt: String = ""

    // evaluates integer value to string equivalent
    func evaluate(_ value: Any) throws -> Any? {
        guard let intValue = value as? Int else {
            return value
        }

        // for testing nullability case.
        if intValue == 10 {
            return nil
        }

        return String(intValue)
    }

    func set(_ name: String, value: Any) {
        // no op
    }

    func get(_ name: String) throws -> Any? {
        return nil
    }

    func get<T>(_ name: String, defaultValue: T) throws -> T {
        return defaultValue
    }

    func getParams() throws -> [String : Any] {
        return [:]
    }

}
