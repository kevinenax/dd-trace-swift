import XCTest
@testable import DDSwiftTracer
import OpenTracing

final class DDSwiftTracerTests: XCTestCase {
    
    let mockAgent = MockAgentService()
    var testObject: DDTracer!
    
    override func setUp() {
        super.setUp()
        testObject = DDTracer(serviceName: "service", agentService: mockAgent)
    }
    
    func testStartSpanUsesParentSpan() {
        let parent = Reference.child(of: DDSpanContext(traceID: .random, spanID: .random))
        let parentContext = parent.context as! DDSpanContext
        let span = testObject.startSpan(operationName: "operation", 
                                        references: [parent], 
                                        tags: nil, 
                                        startTime: nil) as! DDSpan
        
        XCTAssertEqual(span.parent_id!, parentContext.spanId)
        XCTAssertEqual(span.traceId, parentContext.traceId)
    }
    
    func testStartSpanUsesDatePassedIn() {
        let expected = Date(timeIntervalSince1970: 10487182.917)
        let span = testObject.startSpan(operationName: "operation", 
                                        references: nil, 
                                        tags: nil, 
                                        startTime: expected) as! DDSpan
        
        XCTAssertEqual(span.startTime, expected)
    }
    
    func testStartSpanUsesCurrentDateWhenNonePassedIn() {
        let span = testObject.startSpan(operationName: "operation", 
                                        references: nil, 
                                        tags: nil, 
                                        startTime: nil) as! DDSpan
        XCTAssertTrue(Date().timeIntervalSince(span.startTime) < 1)
    }
    
    func testStartSpanAddsTags() {
        let span = testObject.startSpan(operationName: "operation", 
                                        references: nil, 
                                        tags: ["testTag": "testValue"], 
                                        startTime: nil) as! DDSpan
        XCTAssertTrue(span.tags["testTag"] as! String? == "testValue")
    }
    
    func testStartSpanCachesTrace() {
        XCTAssertTrue(testObject.cache.isEmpty) //starts empty
        let expectedKey = UInt.random
        let parent = Reference.child(of: DDSpanContext(traceID: expectedKey, spanID: .random))
        let span = testObject.startSpan(operationName: "operation", 
                                        references: [parent], 
                                        tags: nil, 
                                        startTime: nil) as! DDSpan
        XCTAssertTrue(testObject.cache[expectedKey]!.spans.first === span)
    }
    
    func testStartSpanDoesntDuplicatedTracesInCache() {
        XCTAssertTrue(testObject.cache.isEmpty) //starts empty
        let expectedKey = UInt.random
        for _ in 0..<3 {
            let parent = Reference.child(of: DDSpanContext(traceID: expectedKey, spanID: .random))
            _ = testObject.startSpan(operationName: "operation", 
                                     references: [parent], 
                                     tags: nil, 
                                     startTime: nil) as! DDSpan
        }
        
        XCTAssertTrue(testObject.cache.count == 1)
        XCTAssertTrue(testObject.cache[expectedKey]!.spans.count == 3)
    }
    
    func testSendsTracesToAgentService() {
        testObject = DDTracer(serviceName: "service", 
                              agentService: mockAgent, 
                              agentDelay: 2)
        let expectedTraceID = UInt.random
        let callbackExpectation = expectation(description: "Payload should be sent to service")
        mockAgent.callback = {
            if self.mockAgent.lastPayload != nil {
                XCTAssertTrue(self.mockAgent.lastPayload!.traces.count == 1)
                XCTAssertTrue(self.mockAgent.lastPayload!.traces.first!.id == expectedTraceID)
                XCTAssertTrue(self.mockAgent.lastPayload!.traces.first!.spans.count == 3)
                callbackExpectation.fulfill()
            }
        }
        
        for _ in 0..<3 {
            let parent = Reference.child(of: DDSpanContext(traceID: expectedTraceID, spanID: .random))
            let span = testObject.startSpan(operationName: "operation", 
                                            references: [parent], 
                                            tags: nil, 
                                            startTime: nil) as! DDSpan
            span.finish()
        }
        waitForExpectations(timeout: 20.0, handler: nil)
        
    }
    
    func testDoesntSendUnfinishedSpansToAgent() {
        testObject = DDTracer(serviceName: "service", 
                              agentService: mockAgent, 
                              agentDelay: 2)
        let expectedTraceID = UInt.random
        let callbackExpectation = expectation(description: "Payload should be sent to service")
        
        let parent = Reference.child(of: DDSpanContext(traceID: expectedTraceID, spanID: .random))
        let span = testObject.startSpan(operationName: "operation", 
                                        references: [parent], 
                                        tags: nil, 
                                        startTime: nil) as! DDSpan
        span.finish()
        
        mockAgent.callback = {
            if self.mockAgent.lastPayload != nil {
                XCTAssertTrue(self.mockAgent.lastPayload!.traces.count == 1)
                XCTAssertTrue(self.mockAgent.lastPayload!.traces.first!.id == expectedTraceID)
                XCTAssertTrue(self.mockAgent.lastPayload!.traces.first!.spans.count == 1)
                XCTAssertTrue(self.mockAgent.lastPayload!.traces.first!.spans.first!.spanId == span.spanId)
                callbackExpectation.fulfill()
            }
        }
        
        
        
        let _ = testObject.startSpan(operationName: "operation", 
                                     references: [parent], 
                                     tags: nil, 
                                     startTime: nil) as! DDSpan
        
        waitForExpectations(timeout: 20.0, handler: nil)
        
    }
}
