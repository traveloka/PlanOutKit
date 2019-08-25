//
//  Sample.swift
//  PlanoutKit
//
//  Created by David Christiandy on 14/08/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

extension PlanOutOperation {
    /// Pick random samples from given choices.
    ///
    /// By default, the choices will be randomized and returned; but if numDraws is specified, then it will pick the first N elements instead.
    final class Sample: PlanOutOpRandom<[Any]> {

        override func randomExecute() throws -> [Any]? {
            guard let choices = args[Keys.choices.rawValue] as? [Any], !choices.isEmpty else {
                return []
            }

            // Ensure that the number of draws must not exceed the total number of choices. If there are no number of draws specified, then it will always sample the whole choices by default.
            let numDraws: Int
            if let drawsValue = args[Keys.draws.rawValue], case let Literal.number(draws) = Literal(drawsValue) {
                // follows the implementation where
                guard case (0...choices.count) = Int(draws) else {
                    throw OperationError.invalidArgs(expected: "draws between \(0)...\(choices.count)", got: "\(Int(draws))")
                }
                numDraws = Int(draws)
            } else {
                numDraws = choices.count
            }

            // Perform Fischer-Yates shuffle.
            // loop through the array in reversed fashion (index starting from count-1 and goes downwards).
            // in each loop, generate a random number using the current index as appended unit, and apply modulo operator to constrain the random number to be between 0 - index. Then, swap the element located in index and random number.
            // see also: https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
            var mutableChoices: [Any] = choices
            for (index, _) in mutableChoices.enumerated().reversed() {
                let randomNumber = try hash(appendedUnit: index) % (index + 1)
                mutableChoices.swapAt(index, randomNumber)
            }

            // from the shuffled array, return only the first `numDraws` element.
            return Swift.Array(mutableChoices[0..<numDraws])
        }

        /// Convenience method that runs the operation with only the minimum required arguments.
        ///
        /// - Parameters:
        ///   - choices: An array of choices to draw from
        ///   - draws: The number of times a choice should be made
        ///   - unit: The primary unit used for hashing
        /// - Returns: Returns an array of randomly selected choices based on hashed unit
        static func quickEval(choices: [Any], draws: Int, unit: String) -> [Any]? {
            let args: [String: Any] = [
                Keys.choices.rawValue: choices,
                Keys.draws.rawValue: draws,
                Keys.unit.rawValue: unit,
                Keys.salt.rawValue: "x" // use arbitrary string as salt.
            ]

            return try? self.init().execute(args, Interpreter())
        }
    }

}
