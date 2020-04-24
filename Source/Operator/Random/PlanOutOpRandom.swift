//
//  PlanOutOpRandom.swift
//  PlanoutKit
//
//  Created by David Christiandy on 12/08/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

import CommonCrypto
import Foundation

class PlanOutOpRandom<T>: PlanOutOpSimple {
    typealias ResultType = T

    /// Used to calculate the random
    private let longScale: Double = 0xFFFFFFFFFFFFFFF

    var context: PlanOutOpContext?
    var args: [String: Any] = [:]

    private(set) var isRandomOperator: Bool = true

    private var unit: String?

    private var fullSalt: String? {
        return args[PlanOutOperation.Keys.fullSalt.rawValue] as? String
    }

    private var argSalt: String? {
        return args[PlanOutOperation.Keys.salt.rawValue] as? String
    }

    private var salt: String? {
        guard let context = self.context else {
            return nil
        }

        let argSalt = self.argSalt ?? ""
        return self.fullSalt ?? SaltProvider.generate(values: [context.experimentSalt, argSalt])
    }

    init() {}

    func simpleExecute(_ args: [String : Any?], _ context: PlanOutOpContext) throws -> T? {
        guard let unitValue = args[PlanOutOperation.Keys.unit.rawValue] else {
            throw OperationError.missingArgs(args: PlanOutOperation.Keys.unit.rawValue, type: self)
        }

        // set unit value for randomization.
        if let arrayUnitValue = unitValue as? [String] {
            self.unit = SaltProvider.generate(values: arrayUnitValue)
        } else if let stringUnitValue = unitValue as? String {
            self.unit = stringUnitValue
        } else {
            throw OperationError.typeMismatch(expected: "String", got: String(describing: unitValue))
        }

        self.context = context
        self.args = args.compactMapValues { $0 } // don't allow nil values.

        return try randomExecute()
    }

    func hash(appendedUnit: Any? = nil) throws -> Int64 {
        // obtain salt
        guard let salt = self.salt else {
            throw OperationError.missingArgs(args: PlanOutOperation.Keys.salt.rawValue, type: self)
        }

        // obtain unit
        guard var unitValue = self.unit else {
            throw OperationError.missingArgs(args: PlanOutOperation.Keys.unit.rawValue, type: self)
        }

        // TODO: Improve how this is handled.
        if let appendedValue = appendedUnit {
            unitValue = SaltProvider.generate(values: [unitValue, String(describing: appendedValue)])
        }

        // compute hash value:
        // - convert "<salt>.<unit>" to SHA1, and get the first 16 characters.
        // - convert hashed hexadecimal string to integer value.
        let baseValue = SaltProvider.generate(values: [salt, unitValue])
        let hashValue = String(baseValue.sha1().prefix(15)) // take the first 15 characters of SHA1.
        guard let numericHash = Int64(hashValue, radix: 16) else {
            throw OperationError.invalidArgs(expected: "hashable value", got: String(hashValue))
        }

        return numericHash
    }

    func getUniform(minValue: Double = 0.0, maxValue: Double = 1.0, appendedUnit: Any? = nil) throws -> Double {
        let zeroToOne = try Double(hash(appendedUnit: appendedUnit)) / longScale

        return minValue + (maxValue - minValue) * zeroToOne
    }

    func randomExecute() throws -> T? {
        fatalError("Subclasses of PlanOutRandom must override this method")
    }
}

// MARK: String SHA1 Extension

extension String {
    /// Converts string value to to sha1.
    ///
    /// - seealso:
    /// https://stackoverflow.com/a/52120827
    func sha1() -> String {
        let data = Data(self.utf8)
        var digest = Data(count: Int(CC_SHA1_DIGEST_LENGTH))

        _ = digest.withUnsafeMutableBytes { digestBytes -> UInt8 in
            data.withUnsafeBytes { messageBytes -> UInt8 in
                if let mb = messageBytes.baseAddress, let db = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    CC_SHA1(mb, CC_LONG(data.count), db)
                }
                return 0
            }
        }

        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}
