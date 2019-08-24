//
//  Interpreter.swift
//  PlanoutKit
//
//  Created by David Christiandy on 29/07/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

import Foundation

final class Interpreter {

    var experimentSalt: String

    /// Unit input data with injected unit identifier.
    var inputs: [String: Any]

    var overrides: [String: Any]

    /// The experiment script,
    let serialization: [String: Any]

    // MARK: Private properties

    /// Stores assignment parameters from experiment evaluation.
    ///
    /// This value is accessible through getParams() method, which will force the interpreter to evaluate experiment script in case if it is not yet evaluated.
    private var data: [String: Any]

    /// Indicates the interpreter's evaluation state.
    private var state: EvaluationState = .unevaluated

    /// Flag to indicate whether or not the exposure should be logged.
    private(set) var shouldLogExposure: Bool = true

    // MARK: Initialization

    init(serialization: [String: Any] = [:], salt: String = "", unit: Unit = Unit()) {
        self.serialization = serialization
        experimentSalt = salt

        // merge inputs variable with unit's identifier for later use by random operators.
        self.inputs = unit.inputs.merging([PlanOutOperation.Keys.unit.rawValue: unit.identifier]) { current, _ in current }
        self.overrides = unit.overrides

        // by default store overridden values as parameters, if any.
        data = overrides
    }

    // MARK: Evaluation

    /// Evaluates the experiment script.
    ///
    /// This operation mutates the `data` variable for every assignment operators made through PlanOutOperation.Set.
    ///
    /// - Note:
    /// - The interpreter will only evaluate the script once (per interpreter instance). This is checked through the `evaluated` boolean flag.
    /// - The script can arbitrarily throw OperationError.stop which is intentional and should be passed through. The stop signal contains a boolean value that defines whether the current experiment evaluation should be logged or not.
    ///
    /// This logging decision will later be processed by the Experiment class when the exposure is logged.
    /// - Throws: OperationError
    func evaluateExperiment() throws {
        guard state == .unevaluated else { return }

        // update the current state to evaluating, to prevent infinite loop.
        // during evaluation, operators can access the interpreter (i.e. PlanOutOpContext)'s params through get and set method.
        // without the .evaluating state, this access would cause the interpreter to perform another evaluation for the operator.
        state = .evaluating

        do {
            try evaluate(serialization)
        } catch OperationError.stop(let shouldLogExposure) {
            // Stop operators contain boolean values that control whether the unit's exposure result should be logged.
            // Generally, OperationError.stop is expected as it's a mechanism for PlanOut script to do "premature exit" – i.e. preventing the interpreter from evaluating further.
            self.shouldLogExposure = shouldLogExposure
        } catch let error {
            // For errors other than OperationError.stop, mark the interpreter state as error.
            // This provides clarity if (for example future methods), want to do certain operations depending on whether the interpreter has evaluated the operation successfully, or whether it encountered an error.
            state = .error
            throw error
        }

        // if the evaluation process completed without error, then mark the interpreter state as evaluated.
        state = .evaluated
    }
}

extension Interpreter {
    /// List of reserved names that are separate from the data variable.
    ///
    /// The raw value definitions follow PlanOut interpreter's implementation in Python, as these are probably used (and hardcoded) in the PlanOut compiler as standardized names to get/set these reserved values.
    private enum ReservedNames: String {
        /// Identifer for the data / assignment result variable.
        case data

        /// Identifier for the overrides variable.
        case overrides = "_overrides"

        /// Identifier for the experiment salt.
        case experimentSalt = "experiment_salt"
    }


    /// Indicates the evaluation state of the Interpreter.
    private enum EvaluationState {
        /// The interpreter has not evaluated the experiment yet.
        case unevaluated

        /// The interpreter is evaluating the experiment.
        case evaluating

        /// The interpreter has finished evaluating the experiment.
        case evaluated

        /// The interpreter encountered error while evaluating the experiment
        case error
    }
}

extension Interpreter: PlanOutOpContext {
    @discardableResult
    func evaluate(_ value: Any) throws -> Any? {
        switch PlanOutExpression(value: value) {
        case .operation(let operation, let args):
            // execute operation using self as context.
            return try operation.executeOp(args: args, context: self)
        case .list(let values):
            // evaluate each element contained within the array.
            return try values.compactMap { try self.evaluate($0) }
        case .literal(let value):
            // literal types (other than the above) are directly returned as is.
            return value
        }
    }

    func get(_ name: String) throws -> Any? {
        // Experiment script must be evaluated first before any get queries are performed.
        // All available get methods will end up delegating to this method, so it's safe to put the evaluateExperiment() call here.
        try evaluateExperiment()

        // handle reserved variable queries.
        if let reservedName = ReservedNames(rawValue: name) {
            switch reservedName {
            case .data:
                return data
            case .overrides:
                return overrides
            case .experimentSalt:
                return experimentSalt
            }
        }

        // try to return values from the evaluated params first, and then coalesce to input if the value doesn't exist.
        return data[name] ?? inputs[name]
    }

    func get<T>(_ name: String, defaultValue: T) throws -> T {
        let value = try get(name)

        // loosen the type restriction for numeric types via type-hopping through NSNumber.
        // this applies for all sorts of numeric values: Int, Double, Bool, Float, etc.
        if let numericValue = value as? NSNumber {
            return numericValue as? T ?? defaultValue
        }

        return (value as? T) ?? defaultValue
    }

    func getParams() throws -> [String: Any] {
        // Although it looks much simpler to directly return `data` variable here, we don't do that in order to keep the logic for checking whether the experiment has been evaluated or not in one place.
        return try self.get(ReservedNames.data.rawValue, defaultValue: [:])
    }

    func set(_ name: String, value: Any) throws {
        // allow changing reserved values
        if let reserved = ReservedNames(rawValue: name) {
            switch reserved {
            case .data:
                guard let dictionaryValue = value as? [String: Any] else {
                    return
                }
                self.data = dictionaryValue

            case .overrides:
                guard let dictionaryValue = value as? [String: Any] else {
                    return
                }
                self.overrides = dictionaryValue

            case .experimentSalt:
                guard let stringValue = value as? String else {
                    return
                }
                self.experimentSalt = stringValue
            }
        }

        // prevent overwriting values defined in the overrides.
        guard overrides[name] == nil else {
            return
        }

        // special handling if value is potentially PlanOutRandom operator instance with args, for testing purposes.
        if let tuple = value as? (op: PlanOutExecutable, args: [String: Any]), tuple.op.isRandomOperator {
            // modify arguments with added salt parameter.
            // add salt value if it does not exist yet, with variable name as salt.
            let saltedArgs = tuple.args.merging([PlanOutOperation.Keys.salt.rawValue: name]) { current, _ in current }
            data[name] = try tuple.op.executeOp(args: saltedArgs, context: self)
        } else {
            data[name] = value
        }
    }
}
