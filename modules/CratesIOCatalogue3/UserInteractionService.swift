//
//  UserInteractionService.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/15.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import UIKit
import BoltsSwift
import EonilToolbox

extension Renderable where Self: DriverAccessible {
    /// Gets current UI state (scene-graph)
    ///
    /// - Note: Must be called in main-thread.
    ///
    var state: UserInteractionState {
        assert(NSThread.isMainThread())
        return driver.userInteraction.state
    }
}

/// Manages user-interaction facility. (UI)
///
/// - Note: Should I support pause/resume of message processing here?
///
final class UserInteractionService: DriverAccessible {
    private let gcdq = dispatch_get_main_queue()!
    private var cmdq = [(UserInteractionCommand, TaskCompletionSource<()>)]()
    private var isPaused = false
    private var state = UserInteractionState()
    private let renderer = Renderer()

    init() {
        do {
            try DisplayLinkUtility.installMainScreenHandler(ObjectIdentifier(self)) { [weak self] in
                self?.run()
            }
        }
        catch let error {
            fatalErrorWithReporting("No way to recover here. The error is: \(error).")
        }
    }
    deinit {
        DisplayLinkUtility.deinstallMainScreenHandler(ObjectIdentifier(self))
    }

    /// Dispatches a transaction.
    ///
    /// The transaction will be executed in main thread.
    ///
    func dispatch<U>(transaction: (inout UserInteractionState) throws -> U) -> Task<U> {
        return Task(()).continueWithTask(Executor.Queue(gcdq)) { [weak self] task in
            guard let S = self else { return Task.cancelledTask() }
            return Task(try transaction(&S.state))
        }
    }
    func dispatch(command: UserInteractionCommand) -> Task<()> {
        let completion = TaskCompletionSource<()>()
        cmdq.append((command, completion))
        return completion.task
    }
    private func run() {
        guard isPaused == false else { return }
        while let (command, completion) = cmdq.popFirst() {
            do {
                try step(command)
                completion.trySetResult(())
                debugPrint(state.navigation.detailStack)
            }
            catch let error {
                completion.trySetError(error)
            }
        }
        renderer.render()
    }
    private func step(command: UserInteractionCommand) throws {
        debugPrint("Processing command: `\(command)`")
        switch command {
        default:
            MARK_unimplemented()
        }
    }

}






















