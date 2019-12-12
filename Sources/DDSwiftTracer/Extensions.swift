//
//  Extensions.swift
//  DDSwiftTracer
//
//  Created by Kevin Enax on 4.12.2019.
//

import Foundation
import OpenTracing

extension Array where Element == Reference {
    func parent_id() -> UInt? {
        let firstChildRef = self.first(where: { (ref) -> Bool in
            switch ref.type {
            case .childOf:
                guard ref.context is DDSpanContext else { return false }
                return true
            default:
                return false
            }
        })
        if let ddSpan = firstChildRef?.context as? DDSpanContext {
            return ddSpan.spanId
        } else {
            return nil
        }
    }
    
    func trace_id() -> UInt? {
        if let ddSpan = self.first?.context as? DDSpanContext {
            return ddSpan.traceId
        } else {
            return nil
        }
    }
}

extension TimeInterval {
    var nanoseconds: UInt {
        return UInt(self * 1_000_000_000)
    }
}
