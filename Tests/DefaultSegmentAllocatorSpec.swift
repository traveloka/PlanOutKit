//
//  DefaultSegmentAllocatorSpec.swift
//  PlanOutKitTests
//
//  Created by David Christiandy on 16/08/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

import Quick
import Nimble
@testable import PlanOutKit

// always return the first `draws` element
private func mockSampler(_ choices: [Any], _ draws: Int, _ unit: String) -> [Any]? {
    return Array(choices.prefix(draws))
}

// always return the min value
private func mockRandomizer(_ minValue: Int, _ maxValue: Int, _ unit: String) -> Int? {
    return minValue
}

final class DefaultSegmentAllocatorSpec: QuickSpec {
    override func spec() {
        describe("DefaultSegmentAllocator") {
            describe("Initialization") {
                it("should store information of total segments") {
                    let allocator = DefaultSegmentAllocator(totalSegments: 10)
                    expect(allocator.totalSegments).to(equal(10))
                }
            }

            describe("Segment allocation") {
                context("for invalid allocation requests") {
                    it("throws if requested segment count is larger than available segments") {
                        var allocator = DefaultSegmentAllocator(totalSegments: 10)

                        expect { try allocator.allocate("foo", 15) }.to(throwError(SegmentAllocationError.samplingError))

                        expect { try allocator.allocate("foo", segments: Array(0...15)) }.to(throwError(errorType: SegmentAllocationError.self))
                    }

                    it("throws if requested segment count is less than one") {
                        var allocator = DefaultSegmentAllocator(totalSegments: 10)

                        expect { try allocator.allocate("foo", 0) }.to(throwError(errorType: SegmentAllocationError.self))
                    }
                    it("throws if the identifier already exists") {
                        var allocator = DefaultSegmentAllocator(totalSegments: 10)

                        try! allocator.allocate("foo", 5)

                        expect { try allocator.allocate("foo", 5) }.to(throwError(errorType: SegmentAllocationError.self))
                    }

                    it("throws if the preallocated segments does not exist in the available pool") {
                        var allocator = DefaultSegmentAllocator(totalSegments: 10)
                        let preallocated = [1, 2, 3, 4, 5]
                        try! allocator.allocate("foo", segments: preallocated)

                        expect { try allocator.allocate("bar", segments: [5, 6, 7]) }.to(throwError(errorType: SegmentAllocationError.self))
                    }

                    it("throws if segments sampling calculation produces invalid or nil results") {
                        func mockSampler(_ choices: [Any], _ draws: Int, _ unit: String) -> [Any]? {
                            return nil
                        }

                        var allocator = DefaultSegmentAllocator(totalSegments: 10, sampler: mockSampler)

                        expect { try allocator.allocate("foo", 5) }.to(throwError(errorType: SegmentAllocationError.self))
                    }
                }

                context("for valid allocation requests") {
                    it("returns the segments allocated for the identifier") {
                        var allocator = DefaultSegmentAllocator(totalSegments: 10)
                        var segments: [Int]?

                        expect { segments = try allocator.allocate("foo", 5) }.toNot(throwError())
                        expect(segments!.count) == 5
                    }
                }
            }

            describe("Segment deallocation") {
                context("given invalid deallocation requests") {
                    it("does nothing if the identifier is not in allocation map") {
                        var allocator = DefaultSegmentAllocator(totalSegments: 10)

                        expect { try allocator.deallocate("foo") }.toNot(throwError())
                    }
                }
                context("given valid deallocation requests") {
                    it("frees up segments used for the deallocated identifier") {
                        var allocator = DefaultSegmentAllocator(totalSegments: 10)
                        try! allocator.allocate("x", segments: [1, 2, 3])
                        try! allocator.deallocate("x")

                        expect { try allocator.allocate("x", segments: [1, 2, 3]) }.toNot(throwError())
                        expect { try allocator.allocate("x", 5) }.to(throwError(errorType: SegmentAllocationError.self))
                    }
                }

                context("when given the same inputs") {
                    it("always allocates to the same segments") {
                        var segments: [[Int]] = []

                        for _ in (0..<3) {
                            var allocator = DefaultSegmentAllocator(totalSegments: 10)
                            segments.append(try! allocator.allocate("foo", 3))
                        }

                        // all segments should have the same elements.
                        expect(segments[0]) == segments[1]
                        expect(segments[1]) == segments[2]
                    }
                }
            }

            describe("Identifier mapping") {
                context("given the allocation capacity is full") {
                    it("maps unit to an identifier") {
                        var allocator = DefaultSegmentAllocator(totalSegments: 10)

                        (0...9).forEach { try! allocator.allocate(String($0), 1) }

                        let result1 = allocator.identifier(forUnit: "foo")
                        let result2 = allocator.identifier(forUnit: "foo")

                        expect(result1).toNot(beNil())
                        expect(result2).toNot(beNil())
                        expect(result1!) == result2!
                    }
                }

                it("returns nil if there are no identifiers allocated") {
                    let allocator = DefaultSegmentAllocator(totalSegments: 10)
                    let result1 = allocator.identifier(forUnit: "foo")

                    expect(result1).to(beNil())
                }

                it("returns nil if the unit is allocated to a segment that has no identifiers") {
                    var allocator = DefaultSegmentAllocator(totalSegments: 100)
                    try! allocator.allocate("foo", 1)

                    let result1 = allocator.identifier(forUnit: "foo")
                    expect(result1).to(beNil())
                }

                it("deterministically maps unit to the same segment") {
                    var allocator = DefaultSegmentAllocator(totalSegments: 10)

                    (0...9).forEach { try! allocator.allocate(String($0), 1) }

                    let result1 = allocator.identifier(forUnit: "foo")
                    let result2 = allocator.identifier(forUnit: "foo")

                    expect(result1).toNot(beNil())
                    expect(result2).toNot(beNil())
                    expect(result1!) == result2!
                }

                it("returns nil if the unit to segment mapping functionality is faulty") {
                    func mockRandomizer(_ minValue: Int, _ maxValue: Int, _ unit: String) -> Int? {
                        return nil
                    }

                    let allocator = DefaultSegmentAllocator(totalSegments: 10, randomizer: mockRandomizer)

                    let result1 = allocator.identifier(forUnit: "foo")
                    expect(result1).to(beNil())
                }
            }
        }
    }
}
