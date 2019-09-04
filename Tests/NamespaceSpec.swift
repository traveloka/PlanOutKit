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
                let namespace = try! Namespace("namespaceA",
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
                let namespace = try! Namespace("namespaceA",
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
                let namespace = try! Namespace("namespaceA",
                                          unitKeys: ["userid"],
                                          inputs: ["userid": 1234],
                                          overrides: [:],
                                          totalSegments: 100,
                                          customSalt: nil,
                                          logger: nil)
            
                let expDef = ExperimentDefinition("expDefA", "{\"op\": \"seq\",\"seq\": [{\"op\": \"set\",\"var\": \"group_size\",\"value\": {\"choices\": {\"op\": \"array\",\"values\": [1,10]},\"unit\": {\"op\": \"get\",\"var\": \"userid\"},\"op\": \"uniformChoice\"}},{\"op\": \"set\",\"var\": \"specific_goal\",\"value\": {\"p\": 0.8,\"unit\": {\"op\": \"get\",\"var\": \"userid\"},\"op\": \"bernoulliTrial\"}},{\"op\": \"cond\",\"cond\": [{\"if\": {\"op\": \"get\",\"var\": \"specific_goal\"},\"then\": {\"op\": \"seq\",\"seq\": [{\"op\": \"set\",\"var\": \"ratings_per_user_goal\",\"value\": {\"choices\": {\"op\": \"array\",\"values\": [8,16,32,64]},\"unit\": {\"op\": \"get\",\"var\": \"userid\"},\"op\": \"uniformChoice\"}},{\"op\": \"set\",\"var\": \"ratings_goal\",\"value\": {\"op\": \"product\",\"values\": [{\"op\": \"get\",\"var\": \"group_size\"},{\"op\": \"get\",\"var\": \"ratings_per_user_goal\"}]}}]}}]}]}")
                
                expect {try namespace.defineExperiment(identifier: "expDefA", serializedScript: "{\"op\": \"seq\",\"seq\": [{\"op\": \"set\",\"var\": \"group_size\",\"value\": {\"choices\": {\"op\": \"array\",\"values\": [1,10]},\"unit\": {\"op\": \"get\",\"var\": \"userid\"},\"op\": \"uniformChoice\"}},{\"op\": \"set\",\"var\": \"specific_goal\",\"value\": {\"p\": 0.8,\"unit\": {\"op\": \"get\",\"var\": \"userid\"},\"op\": \"bernoulliTrial\"}},{\"op\": \"cond\",\"cond\": [{\"if\": {\"op\": \"get\",\"var\": \"specific_goal\"},\"then\": {\"op\": \"seq\",\"seq\": [{\"op\": \"set\",\"var\": \"ratings_per_user_goal\",\"value\": {\"choices\": {\"op\": \"array\",\"values\": [8,16,32,64]},\"unit\": {\"op\": \"get\",\"var\": \"userid\"},\"op\": \"uniformChoice\"}},{\"op\": \"set\",\"var\": \"ratings_goal\",\"value\": {\"op\": \"product\",\"values\": [{\"op\": \"get\",\"var\": \"group_size\"},{\"op\": \"get\",\"var\": \"ratings_per_user_goal\"}]}}]}}]}]}")}.notTo(throwError())
                expect { try namespace.addExperiment(name: "experimentA", definitionId: "expDefA", segmentCount: 10) }.notTo(throwError())
                expect { try namespace.assignIfNeeded() }.notTo(throwError())
            }
            
            it("has to be able to throw error when duplicate experiment is found.") {
                let keys = ["foo"]
                let inputs = ["foo": "123"]
                let namespace = try! Namespace("ns", unitKeys: keys, inputs: inputs, totalSegments: 10)

                try! namespace.defineExperiment(identifier: "expA", serializedScript: StubReader.get("simple-0"), isDefaultExperiment: true)

                expect {
                    try namespace.defineExperiment(identifier: "expA",
                                                   serializedScript: StubReader.get("simple-0"),
                                                   isDefaultExperiment: true)
                    }.to(throwError(errorType: NamespaceError.self))
            }

            describe("Default Experiment") {
                let keys = ["foo"]
                let inputs = ["foo": "123"]

                context("when given multiple default experiment definitions") {
                    it("should only register the first default experiment definition") {
                        let namespace = try! Namespace("ns", unitKeys: keys, inputs: inputs, totalSegments: 10)

                        try! namespace.defineExperiment(identifier: "defA", serializedScript: StubReader.get("simple-0"), isDefaultExperiment: true)
                        try! namespace.defineExperiment(identifier: "defB", serializedScript: StubReader.get("simple-1"), isDefaultExperiment: true)

                        let result: String = try! namespace.get("foo", defaultValue: "default string")
                        expect(result) == "some string"
                    }
                }

                context("when adding experiments using default experiment definitions") {
                    it("throws error") {
                        let namespace = try! Namespace("ns", unitKeys: keys, inputs: inputs, totalSegments: 10)
                        try! namespace.defineExperiment(identifier: "defA", serializedScript: StubReader.get("simple-0"), isDefaultExperiment: true)

                        expect { try namespace.addExperiment(name: "expA", definitionId: "defA", segmentCount: 1) }.to(throwError(errorType: NamespaceError.self))
                        expect { try namespace.addExperiment(name: "expA", definitionId: "defA", segments: [0]) }.to(throwError(errorType: NamespaceError.self))
                    }
                }

                context("when unit is not assigned to any experiments") {
                    context("when default experiment is defined") {
                        let logger = MockLogger()
                        let namespace = try! Namespace("ns", unitKeys: keys, inputs: inputs, totalSegments: 10, logger: logger)
                        try! namespace.defineExperiment(identifier: "defA", serializedScript: StubReader.get("simple-0"), isDefaultExperiment: false)
                        try! namespace.defineExperiment(identifier: "defB", serializedScript: StubReader.get("simple-1"), isDefaultExperiment: true)

                        // add experiment
                        try! namespace.addExperiment(name: "expA", definitionId: "defA", segments: [0])

                        context("given param name matches with assignment from default experiment") {
                            it("returns assignment from default experiment") {
                                let result = try! namespace.get("bar") as! Int
                                expect(result) == 2
                            }

                            it("should not log any exposure") {
                                let _ = try! namespace.get("bar") as! Int
                                expect(logger.logs.count) == 0
                            }
                        }

                        context("given param name does not match with any of the assignments from default experiment") {
                            it("returns provided default value") {
                                let result = try! namespace.get("fooz", defaultValue: "barz")
                                expect(result) == "barz"
                            }

                            it("should not log any exposure") {
                                let _ = try! namespace.get("fooz", defaultValue: "barz")
                                expect(logger.logs.count) == 0
                            }
                        }
                    }

                    context("when default experiment is not defined") {
                        let logger = MockLogger()
                        let namespace = try! Namespace("ns", unitKeys: keys, inputs: inputs, totalSegments: 10, logger: logger)
                        try! namespace.defineExperiment(identifier: "expA", serializedScript: StubReader.get("simple-0"), isDefaultExperiment: false)

                        it("always returns provided default value") {}
                        it("should not log any exposure") {}
                    }
                }
            }
        }
    }
}

private final class MockLogger: PlanOutLogger {
    var logs: [ExposureLog] = []

    func logExposure(_ log: ExposureLog) {
        logs.append(log)
    }
}

