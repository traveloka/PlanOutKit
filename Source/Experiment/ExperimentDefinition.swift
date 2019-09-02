//
//  ExperimentDefinition.swift
//  PlanoutKit
//
//  Created by David Christiandy on 29/07/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

import Foundation

/// ExperimentDefinition represents the "blueprint" of an Experiment.
///
/// Multiple experiments with the same definition may exist within a single namespace; however, they should have different segment allocations.
struct ExperimentDefinition {
    /// The experiment definition identifier.
    ///
    /// Identifier should be unique across all other experiment definitions.
    let id: String

    /// The planout script in Dictionary mode.
    let script: [String: Any]

    /// Flags whether this experiment definition is a default experiment.
    ///
    /// Default experiments by default do not have their exposure logged.
    let isDefaultExperiment: Bool

    /// For analytical purposes, PlanOut scripts are hashed to keep track whether the experiments have potentially changed.
    ///
    /// Although the documentation mentions that checksum implementation uses MD5, their actual implementation in Python uses the first 8 characters from SHA1 representation from the PlanOut script.
    ///
    /// The decision to implement the checksum using SHA1 is because of the assumption that the actual PlanOut interpreter used in production is the Python version (which uses SHA1 instead of MD5).
    /// - seealso:
    /// https://facebook.github.io/planout/docs/logging.html
    let checksum: String

    init(_ id: String, _ script: String, isDefault: Bool = false) {
        self.id = id
        isDefaultExperiment = isDefault

        if let scriptData = script.data(using: .utf8),
            let data = try? JSONSerialization.jsonObject(with: scriptData) as? [String: Any] {
            self.script = data
        } else {
            // TODO: throw error?
            self.script = [:]
        }

        checksum = String(script.sha1().prefix(8))
    }
}
