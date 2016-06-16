//
//  Driver.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/04.
//  Copyright © 2016 Eonil. All rights reserved.
//

import BoltsSwift
import EonilToolbox

/// Application master control.
///
/// Driver just dispatches messages to appropriate services and does nothing else.
///
/// - Note: I still am not sure on this.
///         1. Collect all messages and dispatch them globally serially.
///         2. Expose services directly and let subsystems to dispatch to them directly.
///             So messages can be dispatched paralelly.
///
///
final class Driver {
    private static let theDriver = Driver()
    private var cmdq = [(DriverCommand,TaskCompletionSource<()>)]()
    private var isPaused = false


    let userInteraction = UserInteractionService()
    let operation = OperationService()

    init() {
        do {
            try DisplayLinkUtility.installMainScreenHandler(ObjectIdentifier(self)) { [weak self] in
                self?.run()
            }
        }
        catch let error {
            MARK_unimplemented()
        }
    }
    deinit {
        DisplayLinkUtility.deinstallMainScreenHandler(ObjectIdentifier(self))
    }
    func dispatch(command: DriverCommand) -> Task<()> {
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
            }
            catch let error {
                completion.trySetError(error)
            }
        }
    }
    private func step(command: DriverCommand) throws {
        debugLog(command)
        switch command {
        case .Reset:
            // No-op for now.
            break

        case .Pause:
            isPaused = true

        case.Resume:
            isPaused = false

        case .WaitForDuration(let duration):
            MARK_unimplemented()

        case .Operation(let message):
            operation.dispatch(message)

        case .UserInteraction(let message):
            userInteraction.dispatch(message)
        }
    }
}

extension Driver {
    func dispatch(message: OperationCommand) -> Task<()> {
        return dispatch(DriverCommand.Operation(message))
    }
}

protocol DriverAccessible {
}
extension DriverAccessible {
    var driver: Driver {
        return Driver.theDriver
    }
}










