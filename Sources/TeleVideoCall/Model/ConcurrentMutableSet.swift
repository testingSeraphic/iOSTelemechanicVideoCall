//
//  ConcurrentMutableSet.swift
//  AmazonChimeSDKDemo
//
//  Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

@objcMembers class ConcurrentMutableSet {
    private let lock = NSRecursiveLock()
    private let set = NSMutableSet()
    var count: Int {
        return set.count
    }

    func add(_ object: Any) {
        lock.lock()
        defer { lock.unlock() }
        set.add(object)
    }

    func remove(_ object: Any) {
        lock.lock()
        defer { lock.unlock() }
        set.remove(object)
    }
    
    func removeAll() {
        lock.lock()
        defer { lock.unlock() }
        set.removeAllObjects()
    }

    func contains(_ object: Any) -> Bool {
        return set.contains(object)
    }

    func forEach(_ body: (Any) throws -> Void) rethrows {
        lock.lock()
        defer { lock.unlock() }
        try set.forEach(body)
    }
}

extension TimeInterval {
    var seconds: Int {
        return Int(self.rounded())
    }
    
    var milliseconds: Int {
        return Int(self * 1_000)
    }
    
    var microseconds: Int {
        return Int(self * 1_000_000)
    }
    
    var nanoseconds: Int64 {
        return Int64(self * 1_000_000_000)
    }
}


@objcMembers class ObserverUtils: NSObject {
    public static func forEach<T>(
        observers: ConcurrentMutableSet,
        observerFunction: @escaping (_ observer: T) -> Void
    ) {
        DispatchQueue.main.async {
            observers.forEach { observer in
                if let observer = observer as? T {
                    observerFunction(observer)
                }
            }
        }
    }
    public static func forEach<T>(
        observers: NSMutableSet,
        observerFunction: @escaping (_ observer: T) -> Void
    ) {
        DispatchQueue.main.async {
            observers.forEach { observer in
                if let observer = observer as? T {
                    observerFunction(observer)
                }
            }
        }
    }
}


@objcMembers class Constants: NSObject {
    static let videoClientStatusCallAtCapacityViewOnly = 206
    static let nanosecondsPerSecond = 1_000_000_000
    static let millisecondsPerSecond = 1000
    static let dataMessageMaxDataSizeInByte = 2048
    static let dataMessageTopicRegex = "^[a-zA-Z0-9_-]{1,36}$"
    static let maxSupportedVideoFrameRate = 30
    static let maxSupportedVideoHeight = 1080
    static let maxSupportedVideoWidth = maxSupportedVideoHeight / 9 * 16
}

