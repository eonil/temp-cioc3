//
//  Transmissive.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/18.
//  Copyright © 2016 Eonil. All rights reserved.
//

protocol TransmissiveType: VersioningState {
    associatedtype Result
    var result: Result? { get }
}
struct Transmissive<T>: TransmissiveType {
    private(set) var version = Version()
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
}
extension Transmissive {
    func needsReloading(timeout: NSTimeInterval) -> Bool {
        guard isTransferring == false else { return false }
        guard let readyTimepoint = readyTimepoint else { return true }
        return NSDate().timeIntervalSinceDate(readyTimepoint) < timeout
    }
}
extension Transmissive {
    mutating func reset() {
        result = nil
        launchTimepoint = nil
        readyTimepoint = nil
        version.revise()
    }
    mutating func setTransferring() {
//        assert(launchTimepoint == nil)
        launchTimepoint = NSDate()
        version.revise()
    }
    mutating func setDownloaded(newDownloaded: T) {
//        assert(launchTimepoint != nil)
        result = newDownloaded
        readyTimepoint = NSDate()
        version.revise()
    }
}
extension Transmissive where T: Equatable {
    mutating func setDownloaded(newDownloaded: T) {
        guard result != newDownloaded else { return }
        result = newDownloaded
        readyTimepoint = NSDate()
        version.revise()
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
