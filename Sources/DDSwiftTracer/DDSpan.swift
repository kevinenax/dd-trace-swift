//
//  DDSpan.swift
//  OpenTracing
//
//  Created by Kevin Enax on 12/09/2019.
//

import Foundation
import OpenTracing

public class DDTrace: Encodable {
    var spans: [DDSpan]
    let id: UInt
    
    init(traceId: UInt, spans: [DDSpan]) {
        self.id = traceId
        self.spans = spans
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for span in spans {
           try container.encode(span)
        }
    }
}

struct DDPayload: Encodable {
    var traces: [DDTrace]
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for trace in traces {
           try container.encode(trace)
        }
    }
}

public class DDSpan: Span, Encodable {
    
    public enum Tags: String {
        case resource
        case service
        case error
        case statusCode = "http.status_code"
        case httpMethod = "http.method"
        case url = "http.url"
    }

    public var context: SpanContext {
        return self.backingContext
    }

    let startTime: Date
    var operationName: String
    var endTime: Date?
    var references: [Reference]?

    var tags: [String: Codable] = [:]
    var logs: [Date: [String: Codable]] = [:]

    var duration: TimeInterval? {
        guard let end = self.endTime?.timeIntervalSince1970 else { return nil }
        let start = self.startTime.timeIntervalSince1970
        return end - start
    }

    var parent_id: UInt? {
        self.references?.parent_id()
    }
    
    var statusCode: String? {
        get {
            return self.tags[DDSpan.Tags.statusCode.rawValue] as? String
        }
        set {
            self.tags[DDSpan.Tags.statusCode.rawValue] = newValue
        }
    }
    
    var httpMethod: String? {
        get {
            return self.tags[DDSpan.Tags.httpMethod.rawValue] as? String
        }
        set {
            self.tags[DDSpan.Tags.httpMethod.rawValue] = newValue
        }
    }
    
    var url: String? {
        get {
            return self.tags[DDSpan.Tags.url.rawValue] as? String
        }
        set {
            self.tags[DDSpan.Tags.url.rawValue] = newValue
        }
    }
    
    var resource: String? {
        get {
            return self.tags[DDSpan.Tags.resource.rawValue] as? String
        }
        set {
            self.tags[DDSpan.Tags.resource.rawValue] = newValue
        }
    }
    
    var service: String? {
        get {
            return self.tags[DDSpan.Tags.service.rawValue] as? String
        }
        set {
            self.tags[DDSpan.Tags.service.rawValue] = newValue
        }
    }
    
    var error: String? {
        get {
            return self.tags[DDSpan.Tags.error.rawValue] as? String
        }
        set {
            self.tags[DDSpan.Tags.error.rawValue] = newValue
        }
    }
    
    /*

     trace_id - required The unique integer (64-bit unsigned) ID of the trace containing this span.
     span_id - required The span integer (64-bit unsigned) ID.
     name - required The span name. The span name must not be longer than 100 characters.
     resource - required The resource you are tracing. The resource name must not be longer than 5000 characters.
     service - required The service you are tracing. The service name must not be longer than 100 characters.
     type - optional, default=custom, case-sensitive The type of request. The options available are web, db, cache, and custom.
     start - required. The start time of the request in nanoseconds from the unix epoch.
     duration - required The duration of the request in nanoseconds.
     parent_id - optional The span integer ID of the parent span.
     error - optional Set this value to 1 to indicate if an error occured. If an error occurs, you should pass additional information, such as the error message, type and stack information in the meta property.
     meta - optional A set of key-value metadata. Keys and values must be strings.
     metrics - optional A set of key-value metadata. Keys must be strings and values must be 64-bit floating point numbers.

     */
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: JSONCodingKeys.self)
        var meta: [String: String] = [:]
        try container.encode(self.backingContext.traceID, forKey: JSONCodingKeys(stringValue: Constants.DDSpanEncodingKeys.TraceID))
        try container.encode(self.backingContext.spanID, forKey: JSONCodingKeys(stringValue: Constants.DDSpanEncodingKeys.SpanID))
        try container.encode(self.operationName, forKey: JSONCodingKeys(stringValue: Constants.DDSpanEncodingKeys.Name))
        try container.encodeIfPresent(self.resource, forKey: JSONCodingKeys(stringValue: Constants.DDSpanEncodingKeys.Resource))
        try container.encodeIfPresent(self.service, forKey: JSONCodingKeys(stringValue: Constants.DDSpanEncodingKeys.Service))
        try container.encode(self.startTime.timeIntervalSince1970.nanoseconds, 
                             forKey: JSONCodingKeys(stringValue: Constants.DDSpanEncodingKeys.Start))
        try container.encodeIfPresent(self.duration?.nanoseconds, forKey: JSONCodingKeys(stringValue: Constants.DDSpanEncodingKeys.Duration))
        try container.encodeIfPresent(self.parent_id, forKey: JSONCodingKeys(stringValue: Constants.DDSpanEncodingKeys.ParentID))
        if let errorMessage = self.error {
            try container.encode(1, forKey: JSONCodingKeys(stringValue: Constants.DDSpanEncodingKeys.Error))
            meta["errorMessage"] = errorMessage
        }
        meta[DDSpan.Tags.httpMethod.rawValue] = self.httpMethod
        meta[DDSpan.Tags.url.rawValue] = self.url
        meta[DDSpan.Tags.statusCode.rawValue] = self.statusCode
        try container.encode(meta, forKey: JSONCodingKeys(stringValue: Constants.DDSpanEncodingKeys.Meta))
    }

    private var backingContext: DDSpanContext
    
    init(operationName: String,
         traceID: UInt,
         startTime: Date = Date(),
         references: [Reference]? = nil) {
        self.operationName = operationName
        self.backingContext = DDSpanContext(traceID: traceID)
        self.startTime = startTime
        self.references = references
    }

    public func finish(at time: Date = Date()) {
        self.endTime = time
    }

    public func log(fields: [String : Codable],
             timestamp: Date = Date()) {
        self.logs[timestamp] = fields
    }

    public func tracer() -> Tracer {
        return Global.sharedTracer
    }

    public func setOperationName(_ operationName: String) {
        self.operationName = operationName
    }

    public func setTag(key: String, value: Codable) {
        self.tags[key] = value
    }

    public func setBaggageItem(key: String, value: String) {
        self.backingContext.baggage[key] = value
    }

    public func baggageItem(withKey key: String) -> String? {
        return self.backingContext.baggage[key]
    }

}

struct JSONCodingKeys: CodingKey {
    var stringValue: String
    var intValue: Int?

    init(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = Int(stringValue)
    }


    init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
}
