//
//  DDAgentService.swift
//  DDSwiftTracer
//
//  Created by Kevin Enax on 10.12.2019.
//

import Foundation

public protocol DDAgentServiceProtocol {
    func sendPayload(_ payload: DDPayload, completion: @escaping (Bool) -> Void)
}

public final class DDAgentService: DDAgentServiceProtocol {
    
    private let jsonEncoder = JSONEncoder()
    private let agentHost: String
    
    public init(agentHost: String) {
        self.agentHost = agentHost
    }
    
    public func sendPayload(_ payload: DDPayload, completion: @escaping (Bool) -> Void) {
        let port = 8126
        let path = "/v0.3/traces"
        let url = URL(string: "http://\(self.agentHost):\(port)\(path)")!
        var request = URLRequest(url: url)
        request.httpBody = try! jsonEncoder.encode(payload)
        request.httpMethod = "PUT"
        let task = URLSession.shared.dataTask(with: request) { (dataOpt, responsOpt, errorOpt) in
            if errorOpt == nil {
                completion(true)
            } else {
                completion(false)
            }
        }
        task.resume()
    }
}
