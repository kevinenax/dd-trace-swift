//
//  DDTraceCacheTests.swift
//  DDSwiftTracerTests
//
//  Created by Kevin Enax on 11.12.2019.
//

import XCTest
@testable import DDSwiftTracer

class DDTraceCacheTests: XCTestCase {
    
    func testCacheWorksEmpty() {
        let testObject = DDTraceCache()
        XCTAssertNil(testObject[UInt.random(in: UInt.min...UInt.max)])
        XCTAssertNil(testObject[UInt.random(in: UInt.min...UInt.max)])
        XCTAssertNil(testObject[UInt.random(in: UInt.min...UInt.max)])
        XCTAssertEqual(testObject.startIndex, testObject.endIndex) //should be equal per Sequence protocol
    }

    func testCacheAsSequence() {
        let testObject = DDTraceCache()
        let trace1 = DDTrace(traceId: UInt.random(in: UInt.min...UInt.max), spans: [])
        let trace2 = DDTrace(traceId: UInt.random(in: UInt.min...UInt.max), spans: [])
        let trace3 = DDTrace(traceId: UInt.random(in: UInt.min...UInt.max), spans: [])
        let trace4 = DDTrace(traceId: UInt.random(in: UInt.min...UInt.max), spans: [])
        let trace5 = DDTrace(traceId: UInt.random(in: UInt.min...UInt.max), spans: [])
        
        testObject[trace1.id] = trace1
        testObject[trace2.id] = trace2
        testObject[trace3.id] = trace3
        testObject[trace4.id] = trace4
        testObject[trace5.id] = trace5
        
        XCTAssertTrue(testObject[trace1.id] === trace1)
        XCTAssertTrue(testObject[trace2.id] === trace2)
        XCTAssertTrue(testObject[trace3.id] === trace3)
        XCTAssertTrue(testObject[trace4.id] === trace4)
        XCTAssertTrue(testObject[trace5.id] === trace5)
        
        var localArray = [trace1, trace2, trace3, trace4, trace5]
        
        let multiFulfillExpectation = expectation(description: "Should be called five times")
        multiFulfillExpectation.expectedFulfillmentCount = 5
        for trace in testObject {
            localArray.remove(at: localArray.firstIndex { (localTrace) -> Bool in
                multiFulfillExpectation.fulfill()
                return localTrace.id == trace?.id
            }!)
        }
        
        wait(for: [multiFulfillExpectation], timeout: 0.1)
        XCTAssertTrue(localArray.isEmpty)
    }
    
    func testCacheHandlesRemoval() {
        let testObject = DDTraceCache()
        let trace1 = DDTrace(traceId: UInt.random(in: UInt.min...UInt.max), spans: [])
        let trace2 = DDTrace(traceId: UInt.random(in: UInt.min...UInt.max), spans: [])
        let trace3 = DDTrace(traceId: UInt.random(in: UInt.min...UInt.max), spans: [])
        
        testObject[trace1.id] = trace1
        testObject[trace2.id] = trace2
        testObject[trace3.id] = trace3
        
        testObject[trace3.id] = nil
        
        
        let thriceFulfillExpectation = expectation(description: "Should be called three times")
        thriceFulfillExpectation.expectedFulfillmentCount = 2
        for _ in testObject {
            thriceFulfillExpectation.fulfill()
        }
        
        wait(for: [thriceFulfillExpectation], timeout: 0.1)
    }
}
