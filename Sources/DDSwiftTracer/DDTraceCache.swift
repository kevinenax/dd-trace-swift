//
//  DDSpanCache.swift
//  DDSwiftTracer
//
//  Created by Kevin Enax on 11.12.2019.
//

import Foundation
import Threading

public class DDTraceCache {
    
    fileprivate var traceIDs: ThreadedArray<UInt> = ThreadedArray()
    fileprivate let cache: NSCache<NSString, DDTrace> = NSCache()
    
    public init() {}
    
    public subscript(traceID: UInt) -> DDTrace? {
        get {
            return self.cache.object(forKey: String(traceID) as NSString)
        }
        set {
            if let index = self.traceIDs.firstIndex(where: {$0 == traceID}) {
                if newValue == nil {
                    self.traceIDs.remove(at: index)
                    self.cache.removeObject(forKey: String(traceID) as NSString)
                } else {
                    self.cache.setObject(newValue!, forKey: String(traceID) as NSString)
                }
            } else {
                if newValue == nil {
                    self.cache.removeObject(forKey: String(traceID) as NSString)
                } else {
                    self.traceIDs.append(traceID)
                    self.cache.setObject(newValue!, forKey: String(traceID) as NSString)
                }
            }
        }
    }
}

extension DDTraceCache: Collection, Sequence {
    
    public func index(after i: UInt) -> UInt {
        if let index = self.traceIDs.firstIndex(where: {$0 == i}) {
            let nextIndex = self.traceIDs.index(after: index)
            if nextIndex == self.traceIDs.endIndex {
                return UInt.max
            } else {
                return self.traceIDs[nextIndex]
            }
        } else {
            return UInt.max
        }
    }
    
    public var startIndex: UInt {
        return self.traceIDs.first ?? 0
    }
    
    public var endIndex: UInt {
        if self.traceIDs.isEmpty {
            return 0
        } else {
            return UInt.max
        }
    }
}
