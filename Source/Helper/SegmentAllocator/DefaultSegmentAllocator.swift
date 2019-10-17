//
//  DefaultSegmentAllocator.swift
//  PlanoutKit
//
//  Created by David Christiandy on 14/08/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

/// Default segment allocator uses Set-based operation for addition and subtraction.
struct DefaultSegmentAllocator {
    typealias SamplerFunction = (_ choices: [Any], _ draws: Int, _ unit: String) throws -> [Any]?
    typealias RandomizerFunction = (_ minValue: Int, _ maxValue: Int, _ unit: String) throws -> Int?

    /// The number of total segments for this allocator.
    let totalSegments: Int

    /// Tracks the allocation of each identifiers.
    private var allocationMap: [String: Set<Int>] = [:]

    /// Tracks how many segments are still available for allocation.
    private lazy var availableSegmentPool: Set<Int> = {
        // create an array of containing index of elements 0 to <totalSegments, and convert it to Set structure.
        return Set((0..<totalSegments).map { $0 })
    }()

    /// Injectable closure method to draw random sample from provided choices, based on provided unit.
    ///
    /// If no closure is provided, PlanOutOperation.Sample will be used.
    private let sampler: SamplerFunction

    /// Injectable closure method to get a random integer between min and max value based on provided unit.
    ///
    /// If no closure is provided, PlanOutOperation.RandomInteger will be used.
    private let randomizer: RandomizerFunction
}

extension DefaultSegmentAllocator: SegmentAllocator {
    init(totalSegments: Int) {
        self.init(totalSegments: totalSegments,
                  sampler: PlanOutOperation.Sample.quickEval,
                  randomizer: PlanOutOperation.RandomInteger.quickEval)
    }

    init(totalSegments: Int,
         sampler: @escaping SamplerFunction = PlanOutOperation.Sample.quickEval,
         randomizer: @escaping RandomizerFunction = PlanOutOperation.RandomInteger.quickEval) {
        self.totalSegments = totalSegments
        self.sampler = sampler
        self.randomizer = randomizer
    }

    @discardableResult
    mutating func allocate(_ name: String, _ segmentCount: Int) throws -> [Int] {
        // get randomized segment values based on name parameter.
        guard let segments = try sampler(Array(availableSegmentPool).sorted(), segmentCount, name) as? [Int] else {
            throw SegmentAllocationError.samplingError
        }

        return try allocate(name, segments: segments)
    }

    @discardableResult
    mutating func allocate(_ name: String, segments: [Int]) throws -> [Int] {
        if segments.count < 1 {
            throw SegmentAllocationError.invalid(segments.count)
        } else if segments.count > availableSegmentPool.count {
            throw SegmentAllocationError.outOfSegments(requested: segments.count, available: availableSegmentPool.count)
        } else if allocationMap[name] != nil {
            throw SegmentAllocationError.duplicateIdentifier(name)
        } else if !availableSegmentPool.isSuperset(of: segments) {
            throw SegmentAllocationError.requestedSegmentsNotAvailable
        }

        // register identifier to the segment allocation map.
        allocationMap[name] = Set(segments)

        // remove allocated segments from available segment pool.
        availableSegmentPool.subtract(segments)

        return segments
    }

    mutating func deallocate(_ name: String) throws {
        guard let allocatedSegments: Set<Int> = allocationMap[name] else {
            return
        }

        // restore freed segments to the availableSegments.
        availableSegmentPool.formUnion(allocatedSegments)

        // remove deallocated identifier from the segmentMap.
        allocationMap.removeValue(forKey: name)
    }

    func identifier(forUnit unit: String) throws -> String? {
        // generate a random number between 0..<totalSegments
        guard let segment = try randomizer(0, totalSegments-1, unit) else {
            return nil
        }

        return identifier(forSegment: segment)
    }

    // MARK: Private Methods

    private func identifier(forSegment segment: Int) -> String? {
        return allocationMap.first { $1.contains(segment) }?.key
    }
}
