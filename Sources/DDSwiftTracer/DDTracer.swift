//
//  SwiftTracer.swift
//  OpenTracing
//
//  Created by Kevin Enax on 12/09/2019.
//

import Foundation
import OpenTracing

public class DDTracer: Tracer {

    public let service: String
    private let agentService: DDAgentServiceProtocol
    let cache: DDTraceCache
    let delay: TimeInterval
    
    public init(serviceName: String, 
                agentService: DDAgentServiceProtocol,
                agentDelay: TimeInterval = 30,
                cache: DDTraceCache = DDTraceCache()) {
        self.service = serviceName
        self.agentService = agentService
        self.cache = cache
        self.delay = agentDelay
        self.sendToAgent()
    }
    
    public func startSpan(operationName: String,
                          references: [Reference]?,
                          tags: [String : Codable]?,
                          startTime: Date?) -> Span {
        let defaultId = UUID().hashValue
        let traceID = references?.trace_id() ?? UInt(abs(defaultId))
        
        let span = DDSpan(operationName: operationName,
                          traceID: traceID,
                          startTime: startTime ?? Date(),
                          references: references)
        for (tag, value) in tags ?? [:] {
            span.setTag(key: tag, value: value)
        }
        span.setTag(key: DDSpan.Tags.service.rawValue, value: self.service)
        
        if let trace = self.cache[traceID] {
            trace.spans.append(span)
        } else {
            cache[traceID] = DDTrace(traceId: traceID, spans: [span])
        }
        return span
    }
    
    public func inject(spanContext: SpanContext, writer: FormatWriter) {
        writer.inject(spanContext: spanContext)
    }
    
    public func extract(reader: FormatReader) -> SpanContext? {
        return reader.extract()
    }
    
    private func sendToAgent() {
        var traces: [DDTrace] = []
        var spansToRemove: [DDSpan] = []
        for traceOpt in self.cache {
            guard let trace = traceOpt else { continue }
            let finishedSpans = (trace.spans.filter { $0.duration != nil })
            spansToRemove.append(contentsOf: finishedSpans)
            if !finishedSpans.isEmpty {
                traces.append(DDTrace(traceId: trace.id, spans: finishedSpans))
            }
        }
        if !traces.isEmpty {
            let payload = DDPayload(traces:traces)
            self.agentService.sendPayload(payload) { (successful) in
                if successful {
                    for span in spansToRemove {
                        guard let trace = self.cache[span.traceId] else { continue }
                        trace.spans.removeAll { $0.spanId == span.spanId }
                        if trace.spans.isEmpty {
                            self.cache[trace.id] = nil
                        }
                    }
                }
            }
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + self.delay) { 
            self.sendToAgent()
        }
    }
}

