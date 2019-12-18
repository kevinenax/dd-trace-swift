//
//  DDSpanContextTests.swift
//  DDSwiftTracerTests
//
//  Created by Kevin Enax on 17.12.2019.
//

import XCTest
@testable import DDSwiftTracer

class DDSpanContextTests: XCTestCase {

    func testDescription() {
        let traceId: UInt = 179326739334
        let spanId: UInt = 192837462738
        let testObject = DDSpanContext(traceId: traceId, spanId: spanId)
        
        XCTAssertEqual(testObject.description, "[dd.trace_id=\(traceId) dd.span_id=\(spanId)]")
    }

}
