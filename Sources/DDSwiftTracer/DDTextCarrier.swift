//
//  DDTextCarrier.swift
//  DDSwiftTracer
//
//  Created by Kevin Enax on 4.12.2019.
//

import Foundation
import OpenTracing

public class DDTextCarrier: HTTPHeadersReader, HTTPHeadersWriter {
    public private(set) var headers: [String: String]
    
    public init(_ headers: [String: String]) {
        self.headers = headers
    }
    
    public func extract() -> SpanContext? {
        if let traceId = UInt(self.headers[Constants.TraceIDHeader] ?? ""), let spanId = UInt(self.headers[Constants.SpanIDHeader] ?? "") {
            return DDSpanContext(traceID: traceId, spanID: spanId)
        } else {
            return nil
        }
    }

    public func inject(spanContext: SpanContext) {
        guard let context = spanContext as? DDSpanContext else { return }
        self.headers[Constants.TraceIDHeader] = String(context.traceId)
        self.headers[Constants.SpanIDHeader] = String(context.spanId)
    }
}
