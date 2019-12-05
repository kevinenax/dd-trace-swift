//
//  SwiftTracer.swift
//  OpenTracing
//
//  Created by Kevin Enax on 12/09/2019.
//

import Foundation
import OpenTracing
import Threading

public class DDTracer: Tracer {

    public let service: String
    private let agentHost: String
    private let jsonEncoder = JSONEncoder()
    private var traceIDs: ThreadedArray<String> = ThreadedArray()
    private let cache: NSCache<NSString, DDTrace> = NSCache()

    public init(serviceName: String, agentHost: String) {
        self.service = serviceName
        self.agentHost = agentHost
        self.sendToAgent()
    }
    
    public func startSpan(operationName: String,
                          references: [Reference]?,
                          tags: [String : Codable]?,
                          startTime: Date?) -> Span {
        let defaultId = UUID().hashValue
        let traceID = references?.parent_id() ?? UInt(abs(defaultId))
        
        let span = DDSpan(operationName: operationName,
                          traceID: traceID,
                          startTime: startTime ?? Date())
        for (tag, value) in tags ?? [:] {
            span.setTag(key: tag, value: value)
        }
        span.setTag(key: DDSpan.Tags.service.rawValue, value: self.service)
        
        let nsStringTrace = String(traceID) as NSString
        traceIDs.append(String(traceID))
        
        if let trace = self.cache.object(forKey: nsStringTrace) {
            trace.spans.append(span)
        } else {
            cache.setObject(DDTrace(traceId: traceID, spans: [span]), forKey: nsStringTrace)
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
        let port = 8126
        let path = "/v0.3/traces"
        let url = URL(string: "http://\(self.agentHost):\(port)\(path)")!
        var request = URLRequest(url: url)
        var traces: [DDTrace] = []
        var spansToRemove: [DDSpan] = []
        for traceID in self.traceIDs {
            if let trace = self.cache.object(forKey: traceID as NSString) {
                let finishedSpans = trace.spans.filter { $0.duration != nil }
                spansToRemove.append(contentsOf: finishedSpans)
                if !finishedSpans.isEmpty {
                    traces.append(DDTrace(traceId: trace.id, spans: finishedSpans))
                }
            }
        }
        let payload = DDPayload(traces:traces)
        
        request.httpBody = try! jsonEncoder.encode(payload)
        request.httpMethod = "PUT"
        let task = URLSession.shared.dataTask(with: request) { (dataOpt, responsOpt, errorOpt) in
            if errorOpt == nil {
                for span in spansToRemove {
                    guard let traceID = (span.context as? DDSpanContext)?.traceID else { continue }
                    guard let trace = self.cache.object(forKey: String(traceID) as NSString) else { continue }
                    trace.spans.removeAll { ($0.context as? DDSpanContext)?.spanID == (span.context as? DDSpanContext)?.spanID }
                    if trace.spans.isEmpty {
                        let stringID = String(traceID)
                        self.cache.removeObject(forKey: stringID as NSString)
                        if let index = self.traceIDs.firstIndex(where: {$0 == stringID}) {
                            self.traceIDs.remove(at: index)
                        }
                    }
                }
            }
            DispatchQueue.global().asyncAfter(deadline: .now() + 30) { 
                self.sendToAgent()
            }
        }
        task.resume()
    }
}
