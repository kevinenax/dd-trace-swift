//
//  DDTextCarrierTests.swift
//  DDSwiftTracerTests
//
//  Created by Kevin Enax on 12.12.2019.
//

import XCTest
@testable import DDSwiftTracer

class DDTextCarrierTests: XCTestCase {

    func testExtract() {
        let expectedTraceId = "189624897217"
        let expectedSpanId = "73221569782"
        let testDictionary = ["x-datadog-trace-id": expectedTraceId, "x-datadog-parent-id": expectedSpanId]
        let testObject = DDTextCarrier(testDictionary)
        let context = testObject.extract() as! DDSpanContext
        
        XCTAssertEqual(expectedSpanId, String(context.spanId))
        XCTAssertEqual(expectedTraceId, String(context.traceId))
    }
    
    func testInject() {
        let testObject = DDTextCarrier([:])
        let expectedTraceId = "189624897217"
        let expectedSpanId = "73221569782"
        let testDictionary = ["x-datadog-trace-id": expectedTraceId, "x-datadog-parent-id": expectedSpanId]
        let testSpanContext = DDSpanContext(traceID: UInt(expectedTraceId)!, spanID: UInt(expectedSpanId)!)
        testObject.inject(spanContext: testSpanContext)
        
        XCTAssertEqual(testObject.headers, testDictionary)
    }
    
    func testExtractWithMissingData() {
        let testDictionary1 = ["x-datadog-parent-id": "73221569782"]
        let testDictionary2 = ["x-datadog-trace-id": "189624897217"]
        
        var testObject = DDTextCarrier([:])
        XCTAssertNil(testObject.extract())
        
        testObject = DDTextCarrier(testDictionary1)
        XCTAssertNil(testObject.extract())
        
        testObject = DDTextCarrier(testDictionary2)
        XCTAssertNil(testObject.extract())
    }

}
