//
//  NamespaceError.swift
//  PlanOutKit
//
//  Created by David Christiandy on 02/09/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

enum NamespaceError: Error {
    case missingUnitKeys
    case duplicateDefinition(String)
    case duplicateExperiment(String)
}

extension NamespaceError: CustomStringConvertible {
    var description: String {
        switch self {
        case .missingUnitKeys:
            return "Unit keys must have at least one element."
        case .duplicateDefinition(let id):
            return "Duplicate definition found with id: \(id)"
        case .duplicateExperiment(let id):
            return "Duplicate experiment found with id: \(id)"
        }
    }
}
