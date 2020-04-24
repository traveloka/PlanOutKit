//
//  ExposureLog.swift
//  PlanoutKit
//
//  Created by David Christiandy on 14/08/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

import Foundation

/// Represents log data of unit exposure to an experiment.
///
/// The exposure log follows the structure defined in the PlanOut's main documentation site, and is also in conjunction with PlanOut's Python implementation of exposure log schema.
///
/// - Note:
/// Timestamp will be calculated upon log instantiation.
/// - seealso:
/// https://facebook.github.io/planout/docs/logging.html
public struct ExposureLog: Encodable {
    public let event: String = "exposure"
    public let timestampInMs: Int64
    public let name: String
    public let salt: String
    public let checksum: String
    public let inputs: [String: Any]
    public let params: [String: Any]

    private let encodableInputs: Literal
    private let encodableParams: Literal

    init(experiment: Experiment, inputs: [String: Any], params: [String: Any]) {
        self.inputs = inputs
        self.params = params

        // convert to encodable types.
        self.encodableInputs = Literal(inputs)
        self.encodableParams = Literal(params)

        name = experiment.name
        salt = experiment.salt
        checksum = experiment.definition.checksum

        // Swift TimeInterval are in seconds. Multiply by 1000 to convert to milliseconds.
        timestampInMs = Int64(Date().timeIntervalSince1970 * 1000)
    }

    private enum CodingKeys: String, CodingKey {
        case timestampInMs = "time"
        case name
        case salt
        case checksum
        case encodableInputs = "inputs"
        case encodableParams = "params"
        case event
    }
}
