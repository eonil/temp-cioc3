//
//  Transmissive.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/18.
//  Copyright © 2016 Eonil. All rights reserved.
//

struct Transmissive<T> {
    private(set) var result: T?
    private(set) var launchTimepoint: NSDate?
    private(set) var readyTimepoint: NSDate?

    init() {
    }
    var isReady: Bool {
        return isTransferring == false && result != nil
    }
    var isTransferring: Bool {
        return launchTimepoint != nil && readyTimepoint == nil
    }
    mutating func reset() {
        result = nil
        launchTimepoint = nil
        readyTimepoint = nil
    }
    mutating func setTransferring() {
//        assert(launchTimepoint == nil)
        launchTimepoint = NSDate()
    }
    mutating func setDownloaded(newDownloaded: T) {
//        assert(launchTimepoint != nil)
        result = newDownloaded
        readyTimepoint = NSDate()
    }
}
extension Transmissive {
    func needsReloading(timeout: NSTimeInterval) -> Bool {
        guard isTransferring == false else { return false }
        guard let readyTimepoint = readyTimepoint else { return true }
        return NSDate().timeIntervalSinceDate(readyTimepoint) < timeout
    }
}

//enum Transmissive<T> {
//    case empty
//    case transferring
//    case ready(T)
//
//    var result: T? {
//        switch self {
//        case let .ready(value): return value
//        default:                return nil
//        }
//    }
//
//    var isReady: Bool {
//        return result != nil
//    }
//    var isTransferring: Bool {
//        switch self {
//        case .transferring:     return true
//        default:                return false
//        }
//    }
//    var needsTrnasferring: Bool {
//        return isReady == false && isTransferring == false
//    }
//}
