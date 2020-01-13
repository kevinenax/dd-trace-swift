//
//  DDSpanTests.swift
//  DDSwiftTracerTests
//
//  Created by Kevin Enax on 17.12.2019.
//

import XCTest
@testable import DDSwiftTracer
import OpenTracing

class DDSpanTests: XCTestCase {
    
    func testNamedTags() {
        
        let testObject = DDSpan(operationName: "op", traceId: 198376676892)
        
        testObject.tags[DDSpan.Tags.statusCode] = "500"
        XCTAssertEqual("500", testObject.statusCode)
        testObject.statusCode = "404"
        XCTAssertEqual("404", testObject.tags[DDSpan.Tags.statusCode] as! String)
        
        testObject.tags[DDSpan.Tags.httpMethod] = "GET"
        XCTAssertEqual("GET", testObject.httpMethod)
        testObject.httpMethod = "PUT"
        XCTAssertEqual("PUT", testObject.tags[DDSpan.Tags.httpMethod] as! String)
        
        testObject.tags[DDSpan.Tags.url] = "http://www.google.com/"
        XCTAssertEqual("http://www.google.com/", testObject.url)
        testObject.url = "http://www.bing.com/"
        XCTAssertEqual("http://www.bing.com/", testObject.tags[DDSpan.Tags.url] as! String)
        
        testObject.tags[DDSpan.Tags.resource] = "/stuff"
        XCTAssertEqual("/stuff", testObject.resource)
        testObject.resource = "/things"
        XCTAssertEqual("/things", testObject.tags[DDSpan.Tags.resource] as! String)
        
        testObject.tags[DDSpan.Tags.service] = "SomeService"
        XCTAssertEqual("SomeService", testObject.service)
        testObject.service = "SomeOtherService"
        XCTAssertEqual("SomeOtherService", testObject.tags[DDSpan.Tags.service] as! String)
        
        testObject.tags[DDSpan.Tags.error] = "It broke"
        XCTAssertEqual("It broke", testObject.error)
        testObject.error = "It broke in a different way"
        XCTAssertEqual("It broke in a different way", testObject.tags[DDSpan.Tags.error] as! String)
    }
    
    func testOperationNameCanBeChanged() {
        let testObject = DDSpan(operationName: "op", traceId: 198376676892)
        XCTAssertEqual("op", testObject.operationName)
        testObject.operationName = "differentOperation"
        XCTAssertEqual("differentOperation", testObject.operationName)
        testObject.setOperationName("thirdOperation")
        XCTAssertEqual("thirdOperation", testObject.operationName)
    }
    
    func testBaggageItems() {
        let testObject = DDSpan(operationName: "op", traceId: 198376676892)
        testObject.setBaggageItem(key: "baggage1", value: "value1")
        testObject.setBaggageItem(key: "baggage2", value: "value2")
        XCTAssertEqual(testObject.baggageItem(withKey: "baggage1"), "value1")
        XCTAssertEqual(testObject.baggageItem(withKey: "baggage2"), "value2")
        
        let baggageExpectation = expectation(description: "callback should be called twice")
        baggageExpectation.expectedFulfillmentCount = 2
        testObject.context.forEachBaggageItem { (key, value) -> Bool in
            baggageExpectation.fulfill()
            return false
        }
        
        waitForExpectations(timeout: 0.1, handler: nil)
    }

}
