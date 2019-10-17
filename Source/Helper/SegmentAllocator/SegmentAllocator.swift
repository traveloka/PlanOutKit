//
//  SegmentAllocator.swift
//  PlanoutKit
//
//  Created by David Christiandy on 30/07/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

import Foundation

protocol SegmentAllocator {
    /// The maximum segment size for this instance. Immutable.
    var totalSegments: Int { get }

    init(totalSegments: Int)

    /// Allocate segments for an identifier.
    ///
    /// The identifier must be unique within a single allocator.
    ///
    /// - Parameters:
    ///   - name: The name/identifier to allocate for.
    ///   - segmentCount: The number of segment requested for the identifier.
    /// - Returns: Array containing segments that have been allocated for the identifier.
    /// - Throws: `SegmentAllocationError`
    @discardableResult
    mutating func allocate(_ name: String, _ segmentCount: Int) throws -> [Int]

    /// Allocate predefined segments for an identifier.
    ///
    /// - Parameters:
    ///   - name: The name/identifier to allocate for.
    ///   - segments: An array of integers representing actual segments for the identifier to be allocated to.
    /// - Returns: Array containing segments that have been allocated for the identifier.
    /// - Throws: `SegmentAllocationError`
    @discardableResult
    mutating func allocate(_ name: String, segments: [Int]) throws -> [Int]

    /// Deallocates an identifier from segments.
    ///
    /// Deallocating an identifier will return its used segments back to the available segment pool. If the identifier is not found, the method will do nothing.
    ///
    /// - Parameter name: The identifier name string.
    /// - Throws: SegmentAllocationError
    mutating func deallocate(_ name: String) throws

    /// Assigns a given unit into a segment, which maps to a specific identifier.
    ///
    /// The unit will be hashed to a single segment which maps from 0...<totalSegments, and matched to the allocation table. If the segment is not contained within the allocation table, it simply means that the unit is not assigned an experiment; and the returned value will be nil.
    ///
    /// - Parameter unit: The string representing unique unit identifier.
    /// - Returns: The experiment identifier assigned for the experiment.
    func identifier(forUnit unit: String) throws -> String?
}
