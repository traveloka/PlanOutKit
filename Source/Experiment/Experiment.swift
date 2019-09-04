//
//  Experiment.swift
//  PlanoutKit
//
//  Created by David Christiandy on 29/07/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

import Foundation

/// Represents an instance of an experiment.
///
/// An experiment has unique (within its namespace) name and reference to experiment definition.
class Experiment {
    /// The Experiment "blueprint" used for this instance.
    let definition: ExperimentDefinition

    /// Represents the experiment instance name.
    let name: String

    /// Experiment salt.
    let salt: String

    // Flag whether a unit has been assigned to this experiment.
    private var exposureLogged: Bool = false

    // Private interpreter instance to forward ReadableAssignments method calls.
    private var _interpreter: Interpreter?

    required init(_ definition: ExperimentDefinition, name: String, salt: String) {
        self.definition = definition
        self.name = name
        self.salt = salt
    }

    /// Assigns unit to an experiment.
    ///
    /// - Parameters:
    ///   - unit: The unit model to be assigned to.
    ///   - logger: Exposure logger instance.
    /// - Throws: OperationError
    func assign(_ unit: Unit, logger: PlanOutLogger) throws {
        // return immediately if interpreter already exists.
        if let _ = _interpreter {
            return
        }

        let interpreter = Interpreter(serialization: self.definition.script, salt: salt, unit: unit)

        // evaluate the experiment.
        try interpreter.evaluateExperiment()

        // store the interpreter for later, (i.e. forwarding ReadableAssignment methods to the interpreter).
        self._interpreter = interpreter

        // do not log if the unit is exposed to a default experiment.
        guard !definition.isDefaultExperiment else { return }

        logExposureIfNeeded(with: logger, interpreter: interpreter)
    }

    /// Logs exposure data.
    ///
    /// The exposure will only be logged once per experiment assignment. It is also overridable depending on interpreter's assignment results; for example, if the evaluation throws an `OperationError.stop` with boolean flag set to `false`, this means that the exposure will never be logged for this unit.
    ///
    /// - Parameters:
    ///   - logger: Object responsible for logging.
    ///   - interpreter: The evaluated interpreter, which contains assigned parameters and inputs.
    func logExposureIfNeeded(with logger: PlanOutLogger, interpreter: Interpreter) {
        guard interpreter.shouldLogExposure, !exposureLogged, let params = try? interpreter.getParams() else {
            return
        }

        let log = ExposureLog(experiment: self, inputs: interpreter.inputs, params: params)
        logger.logExposure(log)

        exposureLogged = true
    }
}

extension Experiment: ReadableAssignment {
    public func get(_ name: String) throws -> Any? {
        return try self._interpreter?.get(name)
    }

    public func get<T>(_ name: String, defaultValue: T) throws -> T {
        return try self._interpreter?.get(name, defaultValue: defaultValue) ?? defaultValue
    }

    public func getParams() throws -> [String: Any] {
        return try self._interpreter?.getParams() ?? [:]
    }
}
