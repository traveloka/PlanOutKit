//
//  IndexSpec.swift
//  PlanOutKitTests
//
//  Created by David Christiandy on 19/08/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

import Quick
import Nimble
@testable import PlanOutKit

private func buildArg(_ base: Any, _ index: Any) -> [String: Any] {
    return [PlanOutOperation.Keys.base.rawValue: base, PlanOutOperation.Keys.index.rawValue: index]
}

private struct Foo {}

final class IndexSpec: QuickSpec {
    override func spec() {
        describe("Index simple operator") {
            let op = PlanOutOperation.Index()

            itBehavesLike(.simpleOperator) { [.op: op] }

            describe("Arguments validation") {
                it("throws if base key does not exist") {
                    let args = ["foo": "bar", "index": "baz"]
                    expect { try op.execute(args, Interpreter()) }.to(throwError(errorType: OperationError.self))
                }

                it("throws if index key does not exist") {
                    let args = ["foo": "bar", "base": "baz"]
                    expect { try op.execute(args, Interpreter()) }.to(throwError(errorType: OperationError.self))
                }
            }

            describe("Type validation") {
                context("when evaluating list types") {
                    context("given index value is numeric") {
                        it("returns the array element according to index query") {
                            let base = [1, 2, 3, 4, 5]
                            let index = 1
                            let args: [String: Any] = buildArg(base, index)
                            var result: Any?

                            expect { result = try op.execute(args, Interpreter()) }.toNot(throwError())
                            expect((result! as! Int)) == base[index]
                        }

                        it("returns nil if index is out of bound") {
                            let base = [1, 2, 3, 4, 5]
                            let index = 5
                            let args: [String: Any] = buildArg(base, index)
                            var result: Any?

                            expect { result = try op.execute(args, Interpreter()) }.toNot(throwError())
                            expect(result).to(beNil())
                        }

                        it("returns nil if index is floating point") {
                            let base = [1, 2, 3, 4, 5]
                            let index = 2.0
                            let args: [String: Any] = buildArg(base, index)
                            var result: Any?

                            expect { result = try op.execute(args, Interpreter()) }.toNot(throwError())
                            expect(result).to(beNil())
                        }
                    }

                    context("given index value is not numeric") {
                        it("returns nil if index is string") {
                            let base = [1, 2, 3, 4, 5]
                            let index = "1"
                            let args: [String: Any] = buildArg(base, index)
                            var result: Any?

                            expect { result = try op.execute(args, Interpreter()) }.toNot(throwError())
                            expect(result).to(beNil())
                        }

                        it("returns nil if index is array") {
                            let base = [1, 2, 3, 4, 5]
                            let index = [1, 2]
                            let args: [String: Any] = buildArg(base, index)
                            var result: Any?

                            expect { result = try op.execute(args, Interpreter()) }.toNot(throwError())
                            expect(result).to(beNil())
                        }

                        it("returns nil if index is dictionary") {
                            let base = [1, 2, 3, 4, 5]
                            let index = [1: 1]
                            let args: [String: Any] = buildArg(base, index)
                            var result: Any?

                            expect { result = try op.execute(args, Interpreter()) }.toNot(throwError())
                            expect(result).to(beNil())
                        }

                        it("returns nil if index is boolean") {
                            let base = [1, 2, 3, 4, 5]
                            let index = true
                            let args: [String: Any] = buildArg(base, index)
                            var result: Any?

                            expect { result = try op.execute(args, Interpreter()) }.toNot(throwError())
                            expect(result).to(beNil())
                        }

                        it("returns nil if index is non literals") {
                            let base = [1, 2, 3, 4, 5]
                            let index = Foo()
                            let args: [String: Any] = buildArg(base, index)
                            var result: Any?

                            expect { result = try op.execute(args, Interpreter()) }.toNot(throwError())
                            expect(result).to(beNil())
                        }
                    }
                }

                context("when evaluating dictionary types") {
                    context("given index value is string") {
                        it("returns the corresponding value") {
                            let base = ["a": 1, "b": 2, "c": 3, "d": 4]
                            let index = "a"
                            let args: [String: Any] = buildArg(base, index)
                            var result: Any?

                            expect { result = try op.execute(args, Interpreter()) }.toNot(throwError())
                            expect((result! as! Int)) == 1
                        }

                        it("returns nil if the index does not exist in the dictionary") {
                            let base = ["a": 1, "b": 2, "c": 3, "d": 4]
                            let index = "e"
                            let args: [String: Any] = buildArg(base, index)
                            var result: Any?

                            expect { result = try op.execute(args, Interpreter()) }.toNot(throwError())
                            expect(result).to(beNil())
                        }
                    }

                    context("given index value is not string") {
                        it("returns nil if index is numeric") {
                            let base = ["a": 1, "b": 2, "c": 3, "d": 4]
                            let index = 1
                            let args: [String: Any] = buildArg(base, index)
                            var result: Any?

                            expect { result = try op.execute(args, Interpreter()) }.toNot(throwError())
                            expect(result).to(beNil())
                        }
                        it("returns nil if index is array") {
                            let base = ["a": 1, "b": 2, "c": 3, "d": 4]
                            let index = [1]
                            let args: [String: Any] = buildArg(base, index)
                            var result: Any?

                            expect { result = try op.execute(args, Interpreter()) }.toNot(throwError())
                            expect(result).to(beNil())
                        }
                        it("returns nil if index is dictionary") {
                            let base = ["a": 1, "b": 2, "c": 3, "d": 4]
                            let index = [1: 1]
                            let args: [String: Any] = buildArg(base, index)
                            var result: Any?

                            expect { result = try op.execute(args, Interpreter()) }.toNot(throwError())
                            expect(result).to(beNil())
                        }
                        it("returns nil if index is boolean") {
                            let base = ["a": 1, "b": 2, "c": 3, "d": 4]
                            let index = false
                            let args: [String: Any] = buildArg(base, index)
                            var result: Any?

                            expect { result = try op.execute(args, Interpreter()) }.toNot(throwError())
                            expect(result).to(beNil())
                        }
                        it("returns nil if index is non literals") {
                            let base = ["a": 1, "b": 2, "c": 3, "d": 4]
                            let index = Foo()
                            let args: [String: Any] = buildArg(base, index)
                            var result: Any?

                            expect { result = try op.execute(args, Interpreter()) }.toNot(throwError())
                            expect(result).to(beNil())
                        }
                    }

                }
                context("when evaluating other types") {
                    it("throws if base value is string type") {
                        let base = "invalid string!"
                        let index = 1
                        let args: [String: Any] = buildArg(base, index)

                        expect { try op.execute(args, Interpreter()) }.to(throwError(errorType: OperationError.self))
                    }
                    it("throws if base value is numeric type") {
                        let base = 10
                        let index = 1
                        let args: [String: Any] = buildArg(base, index)

                        expect { try op.execute(args, Interpreter()) }.to(throwError(errorType: OperationError.self))
                    }
                    it("throws if base value is boolean type") {
                        let base = true
                        let index = 1
                        let args: [String: Any] = buildArg(base, index)

                        expect { try op.execute(args, Interpreter()) }.to(throwError(errorType: OperationError.self))
                    }
                    it("throws if base value is non literal type") {
                        let base = Foo()
                        let index = 1
                        let args: [String: Any] = buildArg(base, index)

                        expect { try op.execute(args, Interpreter()) }.to(throwError(errorType: OperationError.self))
                    }

                    it("returns nil if the value is nil") {
                        let base: [String: Int?] = ["a": 1, "b": 2, "c": nil, "d": 4]
                        let index = "c"
                        let args: [String: Any] = buildArg(base, index)
                        var result: Any?

                        expect { result = try op.execute(args, Interpreter()) }.toNot(throwError())
                        expect(result).to(beNil())
                    }
                }
            }

        }
    }
}
