//
//  PlanOutOperation.swift
//  PlanoutKit
//
//  Created by David Christiandy on 11/08/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

enum PlanOutOperation: String {
    case literal
    case get
    case set
    case sequence = "seq"
    case returnOperation = "return"
    case array
    case map
    case coalesce
    case index
    case condition = "cond"
    case and
    case or
    case product
    case sum
    case equals
    case greaterThan = ">"
    case greaterThanOrEqualTo = ">="
    case lessThan = "<"
    case lessThanOrEqualTo = "<="
    case mod = "%"
    case divide = "/"
    case round
    case not = "!"
    case negative
    case min
    case max
    case length
    case randomInteger
    case randomFloat
    case bernoulliTrial
    case bernoulliFilter
    case uniformChoice
    case weightedChoice
    case sample

    static func resolve(_ data: [String: Any]) -> PlanOutExecutable? {
        guard let operationType = data[Keys.op.rawValue] as? String else {
            return nil
        }

        return PlanOutOperation(rawValue: operationType)?.executableInstance()
    }

    /// Returns the executable PlanOutOperator
    func executableInstance() -> PlanOutExecutable {
        switch self {
        case .literal:
            return LiteralOperation()
        case .get:
            return Get()
        case .set:
            return Set()
        case .sequence:
            return Sequence()
        case .returnOperation:
            return Return()
        case .array:
            return Array()
        case .map:
            return Map()
        case .coalesce:
            return Coalesce()
        case .index:
            return Index()
        case .condition:
            return Condition()
        case .and:
            return And()
        case .or:
            return Or()
        case .product:
            return Product()
        case .sum:
            return Sum()
        case .equals:
            return Equals()
        case .greaterThan:
            return GreaterThan()
        case .greaterThanOrEqualTo:
            return GreaterThanOrEqualTo()
        case .lessThan:
            return LessThan()
        case .lessThanOrEqualTo:
            return LessThanOrEqualTo()
        case .mod:
            return Mod()
        case .divide:
            return Divide()
        case .round:
            return Round()
        case .not:
            return Not()
        case .negative:
            return Negative()
        case .min:
            return Min()
        case .max:
            return Max()
        case .length:
            return Length()
        case .randomInteger:
            return RandomInteger()
        case .randomFloat:
            return RandomFloatingPoint()
        case .bernoulliTrial:
            return BernoulliTrial()
        case .bernoulliFilter:
            return BernoulliFilter()
        case .uniformChoice:
            return UniformChoice()
        case .weightedChoice:
            return WeightedChoice()
        case .sample:
            return Sample()
        }
    }
}

extension PlanOutOperation {
    /// Defines the keys used for querying the arguments dictionary.
    internal enum Keys: String {
        case op
        case salt
        case unit
        case fullSalt = "full_salt"
        case variable = "var"
        case value
        case values
        case left
        case right
        case conditions = "cond"
        case ifCondition = "if"
        case thenCondition = "then"
        case sequence = "seq"
        case base
        case index
        case choices
        case weights
        case min
        case max
        case probability = "p"
        case draws
    }
}
