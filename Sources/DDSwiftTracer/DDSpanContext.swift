//
//  DDSpanContext.swift
//  DDSwiftTracer
//
//  Created by Kevin Enax on 4.12.2019.
//

import Foundation
import OpenTracing

public struct DDSpanContext: SpanContext, CustomStringConvertible {

    public var description: String {
        return "[dd.trace_id=\(self.traceId) dd.span_id=\(self.spanId)]"
    }
    
    public let spanId: UInt
    public let traceId: UInt
    var baggage: [String: String] = [:]

    public init(traceId: UInt,
                spanId: UInt = UInt(abs(UUID().hashValue))) {
        self.traceId = traceId
        self.spanId = spanId
    }
    
    
    public func forEachBaggageItem(callback: (String, String) -> Bool) {
        for (key, value) in self.baggage {
            if callback(key, value) {
                break
            }
        }
    }
}
