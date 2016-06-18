//
//  NetworkActivityRenderingService.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/18.
//  Copyright © 2016 Eonil. All rights reserved.
//

import UIKit
import BoltsSwift

final class NetworkActivityRenderingService {
    private let gcdq = dispatch_get_main_queue()!
    private let process = Task(())
    private var clientCount = 0

    private func push() {
        clientCount += 1
        if clientCount > 0 {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        }
    }
    private func pop() {
        clientCount -= 1
        if clientCount == 0 {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }

    func renderFor<T>(task: Task<T>) -> Task<()> {
        return Task(()).continueWithTask(Executor.Queue(gcdq)) { [weak self] (_: Task<()>) -> Task<()> in
            guard let S = self else { return Task.cancelledTask() }
            S.push()
            return Task<T>.whenAll([task]).continueWithTask(Executor.Queue(S.gcdq)) { [weak self] (_: Task<()>) -> Task<()> in
                guard let S = self else { return Task.cancelledTask() }
                S.pop()
                return Task(())
            }
        }
    }
}