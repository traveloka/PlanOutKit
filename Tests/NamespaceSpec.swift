//
//  NamespaceSpec.swift
//  PlanOutKitTests
//
//  Created by David Christiandy on 17/08/19.
//  Copyright © 2019 Traveloka. All rights reserved.
//

import Quick
import Nimble
@testable import PlanOutKit

final class NamespaceSpec: QuickSpec {
    override func spec() {
        describe("Namespace") {
            it("is able to add a new namespace without custom salt") {
                let namespace = Namespace("namespaceA",
                unitKeys: ["userid"],
                inputs: ["userid": 1234],
                overrides: [:],
                totalSegments: 100,
                customSalt: nil,
                logger: nil)
                expect(namespace.name) == "namespaceA"
                
                expect(namespace.salt) == "namespaceA"
                expect { try namespace.getParams() }.notTo(throwError())
                expect { try namespace.getParams().count } == 0
            }
            
            it("is able to add a new namespace with custom salt") {
                let namespace = Namespace("namespaceA",
                                          unitKeys: ["userid"],
                                          inputs: ["userid": 1234],
                                          overrides: [:],
                                          totalSegments: 100,
                                          customSalt: "foo",
                                          logger: nil)
                expect(namespace.name) == "namespaceA"
                
                expect(namespace.salt) == "foo"
                expect { try namespace.getParams() }.notTo(throwError())
                expect { try namespace.getParams().count } == 0
            }
            
            it("is able to add a new experiment") {
                let namespace = Namespace("namespaceA",
                                          unitKeys: ["userid"],
                                          inputs: ["userid": 1234],
                                          overrides: [:],
                                          totalSegments: 100,
                                          customSalt: nil,
                                          logger: nil)
            
                let expDef = ExperimentDefinition("expDefA", "{\"op\": \"seq\",\"seq\": [{\"op\": \"set\",\"var\": \"group_size\",\"value\": {\"choices\": {\"op\": \"array\",\"values\": [1,10]},\"unit\": {\"op\": \"get\",\"var\": \"userid\"},\"op\": \"uniformChoice\"}},{\"op\": \"set\",\"var\": \"specific_goal\",\"value\": {\"p\": 0.8,\"unit\": {\"op\": \"get\",\"var\": \"userid\"},\"op\": \"bernoulliTrial\"}},{\"op\": \"cond\",\"cond\": [{\"if\": {\"op\": \"get\",\"var\": \"specific_goal\"},\"then\": {\"op\": \"seq\",\"seq\": [{\"op\": \"set\",\"var\": \"ratings_per_user_goal\",\"value\": {\"choices\": {\"op\": \"array\",\"values\": [8,16,32,64]},\"unit\": {\"op\": \"get\",\"var\": \"userid\"},\"op\": \"uniformChoice\"}},{\"op\": \"set\",\"var\": \"ratings_goal\",\"value\": {\"op\": \"product\",\"values\": [{\"op\": \"get\",\"var\": \"group_size\"},{\"op\": \"get\",\"var\": \"ratings_per_user_goal\"}]}}]}}]}]}")
                
                expect {try namespace.defineExperiment(identifier: "experimentA", serializedScript: "{\"op\": \"seq\",\"seq\": [{\"op\": \"set\",\"var\": \"group_size\",\"value\": {\"choices\": {\"op\": \"array\",\"values\": [1,10]},\"unit\": {\"op\": \"get\",\"var\": \"userid\"},\"op\": \"uniformChoice\"}},{\"op\": \"set\",\"var\": \"specific_goal\",\"value\": {\"p\": 0.8,\"unit\": {\"op\": \"get\",\"var\": \"userid\"},\"op\": \"bernoulliTrial\"}},{\"op\": \"cond\",\"cond\": [{\"if\": {\"op\": \"get\",\"var\": \"specific_goal\"},\"then\": {\"op\": \"seq\",\"seq\": [{\"op\": \"set\",\"var\": \"ratings_per_user_goal\",\"value\": {\"choices\": {\"op\": \"array\",\"values\": [8,16,32,64]},\"unit\": {\"op\": \"get\",\"var\": \"userid\"},\"op\": \"uniformChoice\"}},{\"op\": \"set\",\"var\": \"ratings_goal\",\"value\": {\"op\": \"product\",\"values\": [{\"op\": \"get\",\"var\": \"group_size\"},{\"op\": \"get\",\"var\": \"ratings_per_user_goal\"}]}}]}}]}]}")}.notTo(throwError())
                expect { try namespace.addExperiment(name: "experimentA", definition: expDef, segmentCount: 10) }.notTo(throwError())
            
                expect { try namespace.assignIfNeeded() }.notTo(throwError())
            }
            
            it("has to be able to throw error when duplicate experiment is found.") {
                
            }
        }
    }
}


