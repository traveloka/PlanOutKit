//
//  LiteralSpec.swift
//  PlanOutKitTests
//
//  Created by David Christiandy on 16/08/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

import Quick
import Nimble
@testable import PlanOutKit

private struct Foo {}

final class LiteralSpec: QuickSpec {
    override func spec() {
        describe("Literal") {
            describe("Any to Literal type conversion") {
                context("when converting string values") {
                    it("converts String value to string literal") {
                        let anyString: Any = "some string"
                        let value = Literal(anyString)

                        expect(value).to(beStringLiteral(with: "some string"))
                    }

                    it("converts stringified numbers as string literals") {
                        let numberString: Any = "42"
                        let value = Literal(numberString)

                        expect(value).to(beStringLiteral(with: "42"))
                    }
                }

                context("when converting numeric values") {
                    it("converts Double value to numeric literal") {
                        let anyDouble: Any = 1.0
                        let value = Literal(anyDouble)

                        expect(value).to(beNumberLiteral(with: 1.0))
                    }

                    it("converts Int value to numeric literal") {
                        let anyInt: Any = 1
                        let value = Literal(anyInt)

                        expect(value).to(beNumberLiteral(with: 1))
                    }
                }

                context("when converting collection values") {
                    it("converts any Array to list literal") {
                        let array = [1, 2, 3]

                        expect(Literal(array)).to(beListLiteral(withValue: [1, 2, 3]))
                    }

                    it("converts any Array with non-literal values to list literal") {
                        let array: [Any] = [Foo(), Foo()]

                        expect(Literal(array)).to(beListLiteral(withLength: array.count))
                    }

                    it("converts any Array with literal and non-literal values to list literal") {
                        let array: [Any] = [1, Foo(), "one-two-three"]

                        expect(Literal(array)).to(beListLiteral(withLength: array.count))
                    }

                    it("converts any string keyed Dictionary to dictionary literal") {
                        let dictionary: [String: Any] = ["foo": 1, "bar": "baz"]

                        expect(Literal(dictionary)).to(beDictionaryLiteral())

                    }
                    it("converts any Dictionary with non-string keys to non-literals") {
                        let dictionary = [1: 2]

                        expect(Literal(dictionary)).to(beNonLiteral())
                    }
                }

                context("when converting non-literal values") {
                    it("converts other custom objects as non-literals") {
                        expect(Literal(Foo())).to(beNonLiteral())
                    }
                }
            }

            describe("Bool conversion") {
                context("when converting string literal to bool") {
                    it("returns true if the string if not empty") {
                        expect(Literal("string").boolValue) == true
                    }
                    it("returns false if the string if empty") {
                        expect(Literal("").boolValue) == false
                    }
                }

                context("when converting numeric literal to bool") {
                    it("returns true only if the numeric value is not 0.0") {
                        expect(Literal(-51.0).boolValue) == true
                        expect(Literal(1).boolValue) == true
                    }
                    it("returns false if the numeric value is 0.0") {
                        expect(Literal(0.0).boolValue) == false
                        expect(Literal(0).boolValue) == false
                    }
                }

                context("when converting bool literal to bool") {
                    it("returns true if the value is true") {
                        expect(Literal(true).boolValue) == true
                    }
                    it("returns false if the value is false") {
                        expect(Literal(false).boolValue) == false
                    }
                }

                context("when converting array literal to bool") {
                    it("returns true if the array is not empty") {
                        expect(Literal([1, 2]).boolValue) == true
                    }
                    it("returns false if the array is empty") {
                        expect(Literal([]).boolValue) == false
                    }
                }

                context("when converting dictionary literal to bool conversion") {
                    it("returns true if the dictionary is not empty") {
                        expect(Literal(["foo": 2]).boolValue) == true
                    }
                    it("returns false if the dictionary is empty") {
                        expect(Literal([:]).boolValue) == false
                    }
                }

                context("non-literal to bool conversion") {
                    it("always returns false for non-literals") {
                        expect(Literal(Foo()).boolValue) == false
                    }
                }
            }

            describe("Equatable conformance") {
                context("when comparing string literals") {
                    it("returns true for strings with the same value") {
                        expect(Literal("foo") == Literal("foo")) == true
                    }

                    it("returns false for strings with different value") {
                        expect(Literal("foo") == Literal("bar")) == false
                    }

                    it("has transitive property") {
                        let foo = "foo"
                        let bar = "bar"

                        expect(Literal(foo) == Literal(bar)).to(equal(Literal(bar) == Literal(foo)))
                    }
                }

                context("when comparing numeric literals") {
                    it("returns true for numerics with the same value") {
                        expect(Literal(1.0) == Literal(1.0)) == true
                        expect(Literal(1) == Literal(1)) == true
                    }

                    it("returns false for numerics with different value") {
                        expect(Literal(1.5) == Literal(1.2)) == false
                        expect(Literal(1) == Literal(2)) == false
                    }

                    it("returns true for Int and Double value with the same value") {
                        expect(Literal(1.0) == Literal(1)) == true
                    }

                    it("returns true for Int and Double value with the different value") {
                        expect(Literal(1.2) == Literal(1)) == false
                    }

                    it("has transitive property") {
                        let foo = 1
                        let bar = 1.0

                        expect(Literal(foo) == Literal(bar)).to(equal(Literal(bar) == Literal(foo)))
                    }
                }
                
                context("when comparing boolean literals") {
                    it("returns true for the same boolean values") {
                        expect(Literal(true) == Literal(true)) == true
                        expect(Literal(false) == Literal(false)) == true
                    }

                    it("returns false for different boolean values") {
                        expect(Literal(true) == Literal(false)) == false
                    }

                    it("has transitive property") {
                        let foo = true
                        let bar = true

                        expect(Literal(foo) == Literal(bar)).to(equal(Literal(bar) == Literal(foo)))
                    }
                }

                context("when comparing array literals") {
                    it("returns true if the array elements match") {
                        expect(Literal([1, 2, 3]) == Literal([1, 2, 3])) == true
                    }

                    it("returns false if the array elements are different") {
                        expect(Literal([1, 2, 3]) == Literal([1, 2, 5])) == false
                    }

                    it("returns false if the other array is only a subset of the lefthand array") {
                        expect(Literal([1, 2, 3]) == Literal([1, 2])) == false
                    }

                    it("returns false if the arrays have matching values with different order") {
                        expect(Literal([1, 2, 3]) == Literal([3, 2, 1])) == false
                    }

                    it("returns false if the other type is a nested array with different nesting levels") {
                        expect(Literal([1, 2]) == Literal([[1, 2]])) == false
                        expect(Literal([1, 2]) == Literal([[1], [2]])) == false
                        expect(Literal([1, 2, 3]) == Literal([[1, 2], 3])) == false
                    }

                    it("returns true if arrays with heterogenous literals have the same elements") {
                        let a: [Any] = [1, 3.0, "string"]
                        let b: [Any] = [1, 3.0, "string"]

                        expect(Literal(a) == Literal(b)) == true
                    }

                    it("returns true for arrays with different numeric types having the same values") {
                        let a: [Any] = [1.0, 2, 3.0]
                        let b: [Any] = [1, 2.0, 3]

                        expect(Literal(a) == Literal(b)) == true
                    }

                    it("should have transitive property") {
                        let a: [Any] = [1.0, 2, 3.0]
                        let b: [Any] = [1, 2.0, 3]

                        expect(Literal(a) == Literal(b)).to(equal(Literal(b) == Literal(a)))
                    }
                }
                context("when comparing dictionary literals") {
                    it("returns true if the dictionary elements match") {
                        let a: [String: Any] = ["foo": 1, "bar": 2]
                        let b: [String: Any] = ["foo": 1, "bar": 2]

                        expect(Literal(a) == Literal(b)) == true
                    }

                    it("returns true if the dictionary elements match with different order") {
                        let a: [String: Any] = ["foo": 1, "bar": 2]
                        let b: [String: Any] = ["bar": 2, "foo": 1]

                        expect(Literal(a) == Literal(b)) == true
                    }

                    it("returns false if the other dictionary has different key value pairs") {
                        let a: [String: Any] = ["foo": 1, "bar": 2]
                        let b: [String: Any] = ["Foo": 1, "baR": 2]

                        expect(Literal(a) == Literal(b)) == false
                    }

                    it("returns false if the other dictionary has different values") {
                        let a: [String: Any] = ["foo": 1, "bar": 2]
                        let b: [String: Any] = ["foo": 3, "bar": 4]

                        expect(Literal(a) == Literal(b)) == false
                    }

                    it("returns false if the other dictionary is only a subset") {
                        let a: [String: Any] = ["foo": 1, "bar": 2]
                        let b: [String: Any] = ["foo": 1]

                        expect(Literal(a) == Literal(b)) == false
                    }

                    it("returns true if dictionaries with heterogenous literals have the same values") {
                        let a: [String: Any] = ["foo": 1.0, "bar": 2, "baz": "30"]
                        let b: [String: Any] = ["foo": 1, "baz": "30", "bar": 2.0]

                        expect(Literal(a) == Literal(b)) == true
                    }

                    it("has transitive property") {
                        let a: [String: Any] = ["foo": 1, "bar": 2]
                        let b: [String: Any] = ["foo": 1]

                        expect(Literal(a) == Literal(b)).to(equal(Literal(b) == Literal(a)))
                    }
                }

                context("when comparing different literal types") {
                    it("compares the double value of boolean with numeric literals") {
                        expect(Literal(true) == Literal(1)) == true
                        expect(Literal(1.0) == Literal(true)) == true

                        expect(Literal(false) == Literal(0.0)) == true
                        expect(Literal(0) == Literal(false)) == true
                    }

                    it("compares boolean literal with bool value of other literals") {
                        expect(Literal(true) == Literal("string")) == true
                        expect(Literal("") == Literal(false)) == true

                        expect(Literal(true) == Literal([1, 2, 3])) == true
                        expect(Literal([]) == Literal(false)) == true

                        expect(Literal(true) == Literal(["foo": 1])) == true
                        expect(Literal([:]) == Literal(false)) == true
                    }

                    it("returns false when numeric literal is compared with its string equivalent") {
                        expect(Literal(5) == Literal("5")) == false
                    }

                    it("returns false for incomparable literal types other than boolean") {
                        let string = Literal("some string")
                        let array = Literal([])
                        let dict = Literal([:])
                        let num = Literal(5.3)

                        let literals = [string, array, dict, num]

                        for (index, element) in literals.enumerated() {
                            for index2 in index+1..<literals.count {
                                expect(element == literals[index2]) == false
                            }
                        }
                    }
                }
                context("when comparing non-literals") {
                    it("always evaluates to true regardless of actual contents") {
                        let a = Literal(Foo())
                        let b = Literal([1: 2])

                        expect(a == b) == true
                        expect(a == a) == true
                        expect(b == b) == true
                    }
                }
            }

            describe("Encodable conformance") {
                context("when encoding string literals") {
                    it("produces the same output as direct encoded the raw value") {
                        let value = ["data": "foo"]
                        let valueData = try! JSONEncoder().encode(value)
                        var jsonData: Data?

                        expect { jsonData = try JSONEncoder().encode(Literal(value)) }.toNot(throwError())
                        expect(jsonData!).to(equal(valueData))
                    }
                }

                context("when encoding numeric literals") {
                    it("produces the same output as the directly encoded raw value") {
                        let value = ["data": 1, "data-2": 3.0]
                        let valueData = try! JSONEncoder().encode(value)
                        var jsonData: Data?

                        expect { jsonData = try JSONEncoder().encode(Literal(value)) }.toNot(throwError())
                        expect(jsonData!.count) == valueData.count
                    }
                }
                context("when encoding boolean literals") {
                    it("produces the same output as the directly encoded raw value") {
                        let value = ["data": true]
                        let valueData = try! JSONEncoder().encode(value)
                        var jsonData: Data?

                        expect { jsonData = try JSONEncoder().encode(Literal(value)) }.toNot(throwError())
                        expect(jsonData!.count) == valueData.count
                    }
                }
                context("when encoding array literals") {
                    it("produces the same output as the directly encoded raw value") {
                        let value: [String: [String]] = ["data": ["asd", "123"]]
                        let valueData = try! JSONEncoder().encode(value)
                        var jsonData: Data?

                        expect { jsonData = try JSONEncoder().encode(Literal(value)) }.toNot(throwError())
                        expect(jsonData!.count) == valueData.count
                    }

                    it("should be able to handle nil entries") {
                        let value: [String: [Int?]] = ["data": [1, 2, nil, 4]]
                        let valueData = try! JSONEncoder().encode(value)
                        var jsonData: Data?

                        expect { jsonData = try JSONEncoder().encode(Literal(value)) }.toNot(throwError())
                        expect(jsonData!).to(equal(valueData))

                    }
                }
                context("when encoding dictionary literals") {
                    it("produces the same output as the directly encoded raw value") {
                        let value: [String: [String: Int]] = ["data": ["asd": 123]]
                        let valueData = try! JSONEncoder().encode(value)
                        var jsonData: Data?

                        expect { jsonData = try JSONEncoder().encode(Literal(value)) }.toNot(throwError())
                        expect(jsonData!).to(equal(valueData))
                    }

                    it("throws error when dictionary contains non-literal values") {
                        let value: [String: Any] = ["data": Foo()]

                        expect { try JSONEncoder().encode(Literal(value)) }.to(throwError(errorType: OperationError.self))
                    }

                    it("should be able to handle nil entries") {
                        let value: [String: [String: Int?]] = ["data": ["foo": 1, "bar": nil, "baz": 2]]
                        var jsonData: Data?

                        expect { jsonData = try JSONEncoder().encode(Literal(value)) }.toNot(throwError())

                        let data = try! JSONSerialization.jsonObject(with: jsonData!) as! [String: [String: Int?]]
                        expect(data) == value
                    }
                }

                context("when encoding non-literal types") {
                    it("throws error when non-literal types are encoded") {
                        let foo = Foo()

                        expect { try JSONEncoder().encode(Literal(foo)) }.to(throwError(errorType: OperationError.self))
                    }
                }
            }
        }
    }
}
