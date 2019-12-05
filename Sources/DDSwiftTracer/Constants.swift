//
//  Constants.swift
//  OpenTracing
//
//  Created by Kevin Enax on 13/09/2019.
//

import Foundation


enum Constants {
    static let TraceIDHeader = "x-datadog-trace-id"
    static let SpanIDHeader = "x-datadog-parent-id"
    
    enum DDSpanEncodingKeys {
        static let TraceID = "trace_id"
        static let SpanID = "span_id"
        static let Name = "name"
        static let Resource = "resource"
        static let Service = "service"
        static let Start = "start"
        static let Duration = "duration"
        static let ParentID = "parent_id"
        static let Meta = "meta"
        static let Metrics = "metrics"
        static let Error = "Error"
    }
}
