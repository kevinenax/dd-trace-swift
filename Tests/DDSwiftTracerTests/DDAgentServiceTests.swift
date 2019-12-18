//
//  DDAgentServiceTests.swift
//  DDSwiftTracerTests
//
//  Created by Kevin Enax on 17.12.2019.
//

import XCTest
@testable import DDSwiftTracer

class DDAgentServiceTests: XCTestCase {
    
    let mockSession = MockSession()
    var testObject: DDAgentService!
    
    override func setUp() {
        super.setUp()
        self.testObject = DDAgentService(agentHost: "localhost", session: mockSession)
    }

    func testSendPayload() {
        let span1 = DDSpan(operationName: "op", 
                           traceId: 10293843295, 
                           startTime: Date(timeIntervalSince1970: 102938368), 
                           spanId: 120398365)
        span1.resource = "/resource"
        span1.service = "service"
        span1.httpMethod = "GET"
        span1.error = "Error message from a thing that happened"
        span1.finish(at: Date(timeIntervalSince1970: 102938368.0001))
        
        let trace = DDTrace(traceId: span1.traceId, spans: [span1])
        let payload = DDPayload(traces: [trace])
        
        let completionExpectation = expectation(description: "completion block should be called")
        
        testObject.sendPayload(payload) { (result) in
            switch result {
            case .success(let success):
                XCTAssertTrue(success)
            case .failure(_):
                XCTFail("There was no error, there should be no failure.")
            }
            XCTAssertEqual("http://localhost:8126/v0.3/traces", self.mockSession.request.url?.absoluteString)
            completionExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testSendPayloadReportsError() {
        let span1 = DDSpan(operationName: "op", 
                           traceId: 10293843295, 
                           startTime: Date(timeIntervalSince1970: 102938368), 
                           spanId: 120398365)
        span1.finish(at: Date(timeIntervalSince1970: 102938368.0001))
        
        let trace = DDTrace(traceId: span1.traceId, spans: [span1])
        let payload = DDPayload(traces: [trace])
        
        let expectedError = NSError(domain: "urlDomain", code: 102087, userInfo: nil)
        self.mockSession.errorOptional = expectedError
        
        
        let completionExpectation = expectation(description: "completion block should be called")
        testObject.sendPayload(payload) { (result) in
            switch result {
            case .success(_):
                XCTFail("There was an error, there should be failure.")
            case .failure(let error):
                XCTAssertTrue((error as NSError) === expectedError)
            }
            XCTAssertEqual("http://localhost:8126/v0.3/traces", self.mockSession.request.url?.absoluteString)
            completionExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 0.2, handler: nil)
    }
}


class MockSession: URLSession {
    var mockDataTaskReturned: MockDataTask!
    var request: URLRequest!
    
    var dataOptional: Data?
    var responseOptional: URLResponse?
    var errorOptional: Error?
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        self.request = request
        mockDataTaskReturned = MockDataTask()
        mockDataTaskReturned.callback = completionHandler
        
        mockDataTaskReturned.dataOptional = dataOptional
        mockDataTaskReturned.responseOptional = responseOptional
        mockDataTaskReturned.errorOptional = errorOptional
        
        return mockDataTaskReturned
    }
}

class MockDataTask: URLSessionDataTask {
    
    var dataOptional: Data?
    var responseOptional: URLResponse?
    var errorOptional: Error?
    
    var callback: ((Data?, URLResponse?, Error?) -> Void)!
    var resumedCalled = false
    
    override func resume() {
        resumedCalled = true
        callback(dataOptional, responseOptional, errorOptional)
    }
}
