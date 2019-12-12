//
//  TestMocks.swift
//  DDSwiftTracerTests
//
//  Created by Kevin Enax on 11.12.2019.
//

import Foundation
@testable import DDSwiftTracer

class MockAgentService: DDAgentServiceProtocol {
    var shouldSucceed = true
    var lastPayload: DDPayload? = nil
    
    var callback: () -> Void = {}
    
    func sendPayload(_ payload: DDPayload, completion: @escaping (Bool) -> Void) {
        self.lastPayload = payload
        completion(shouldSucceed)
        callback()
    }
}

extension UInt {
    static var random: UInt {
        return random(in: UInt.min...UInt.max)
    }
}
