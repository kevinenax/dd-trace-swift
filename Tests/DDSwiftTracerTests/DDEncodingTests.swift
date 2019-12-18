//
//  DDEncodingTests.swift
//  DDSwiftTracerTests
//
//  Created by Kevin Enax on 17.12.2019.
//

import XCTest
@testable import DDSwiftTracer
import OpenTracing

@available(OSX 10.13, *)
class DDEncodingTests: XCTestCase {

    func testSimpleEncoding() {
        let span1 = DDSpan(operationName: "op", 
                           traceId: 10293843295, 
                           startTime: Date(timeIntervalSince1970: 102938368), 
                           spanId: 120398365)
        span1.resource = "/resource"
        span1.service = "service"
        span1.httpMethod = "GET"
        span1.url = "http://www.google.com/"
        span1.statusCode = "200"
        span1.error = "Error message from a thing that happened"
        span1.finish(at: Date(timeIntervalSince1970: 102938368.0001))
        
        let trace = DDTrace(traceId: span1.traceId, spans: [span1])
        let payload = DDPayload(traces: [trace])
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .sortedKeys
        let data = try? jsonEncoder.encode(payload)
        XCTAssertEqual(encodingTest1, String(data: data!, encoding: .utf8)!)
    }
    
    
    func testComplexEncoding() {
        let span1 = DDSpan(operationName: "op", 
                           traceId: 10293843295, 
                           startTime: Date(timeIntervalSince1970: 102938368), 
                           spanId: 120398365)
        span1.resource = "/resource"
        span1.service = "service"
        span1.finish(at: Date(timeIntervalSince1970: 102938368.0001))
        
        let span2 = DDSpan(operationName: "op", 
                           traceId: 10293843295, 
                           startTime: Date(timeIntervalSince1970: 1028368), 
                           spanId: 120398325)
        let parentRef = Reference.child(of: DDSpanContext(traceId: 1298765, spanId: 19876541))
        span2.references.append(parentRef)
        span2.resource = "/resource2"
        span2.service = "service"
        span2.finish(at: Date(timeIntervalSince1970: 1028368.0001))
        
        let span3 = DDSpan(operationName: "op", 
                           traceId: 10293843195, 
                           startTime: Date(timeIntervalSince1970: 102838368), 
                           spanId: 120398345)
        span3.resource = "/resource"
        span3.service = "service"
        span3.finish(at: Date(timeIntervalSince1970: 102838368.0001))
        
        let trace1 = DDTrace(traceId: span1.traceId, spans: [span1, span2])
        let trace2 = DDTrace(traceId: span3.traceId, spans: [span1])
        let payload = DDPayload(traces: [trace1, trace2])
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .sortedKeys
        let data = try? jsonEncoder.encode(payload)
        XCTAssertEqual(encodingTest2, String(data: data!, encoding: .utf8)!)
    }
    
    
    
    let encodingTest1 = """
    [[{"duration":100016,"Error":1,"meta":{"errorMessage":"Error message from a thing that happened","http.method":"GET","http.status_code":"200","http.url":"http:\\/\\/www.google.com\\/"},"name":"op","resource":"\\/resource","service":"service","span_id":120398365,"start":102938368000000000,"trace_id":10293843295}]]
    """

    let encodingTest2 = """
[[{"duration":100016,"meta":{},"name":"op","resource":"\\/resource","service":"service","span_id":120398365,"start":102938368000000000,"trace_id":10293843295},{"duration":100016,"meta":{},"name":"op","parent_id":19876541,"resource":"\\/resource2","service":"service","span_id":120398325,"start":1028368000000000,"trace_id":10293843295}],[{"duration":100016,"meta":{},"name":"op","resource":"\\/resource","service":"service","span_id":120398365,"start":102938368000000000,"trace_id":10293843295}]]
"""
}
