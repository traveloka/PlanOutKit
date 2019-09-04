//
//  InterpreterSpec.swift
//  PlanOutKitTests
//
//  Created by David Christiandy on 17/08/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

import Quick
import Nimble
@testable import PlanOutKit

final class InterpreterSpec: QuickSpec {
    override func spec() {
        describe("Interpreter") {
            let serialization = StubReader.getDictionary("sample")

            it("has to be able to create interpreter and get params") {
                let interpreter = Interpreter(serialization: serialization, salt: "foo", unit: Unit(keys: ["userid"], inputs: ["userid": "123454"]))

                expect { try interpreter.getParams() }.toNot(throwError())
                expect { try interpreter.getParams() }.toNot(beNil())
                expect { try interpreter.get("specific_goal") as? Bool } == true
            }
            
            it("should be able to override when the value is valid") {
                let interpreter = Interpreter(serialization: serialization, salt: "foo", unit: Unit(keys: ["userid"], inputs: ["userid": "123454"], overrides: ["specific_goal": false]))

                expect { try interpreter.getParams() }.toNot(throwError())
                expect { try interpreter.getParams() }.toNot(beNil())
                expect { try interpreter.get("specific_goal") as? Bool } == false
            }
            
            it("shouldn't be able to override when the value is invalid.") {
                let interpreter = Interpreter(serialization: serialization, salt: "foo", unit: Unit(keys: ["userid"], inputs: ["userid": "123454"], overrides: ["userid": "123454"]))

                expect { try interpreter.getParams() }.toNot(throwError())
                expect { try interpreter.getParams() }.toNot(beNil())
                expect { try interpreter.get("specific_goal") as? Bool }.to(beTrue())
                
            }
            
            it("has to be able to use default when the input is invalid.") {
                let interpreter = Interpreter(serialization: serialization, salt: "foo", unit: Unit(keys: ["userid"], inputs: ["cookieid": "123454"], overrides: ["userid": "123454"]))

                expect { try interpreter.getParams() }.toNot(throwError())
                expect { try interpreter.getParams() }.toNot(beNil())
            }
        }
    }
}
