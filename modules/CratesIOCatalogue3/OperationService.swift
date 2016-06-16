//
//  OperationService.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/15.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Dispatch
import BoltsSwift

/// Operation service usually performs long-running multiple step executions.
/// Each steps can be executed in any thread including main thread if necessary.
final class OperationService: DriverAccessible {
//    private typealias Schedule = (message: OperationCommand, completion: TaskCompletionSource<()>)
    private let gcdq = dispatch_queue_create("OperationService/GCDQ", DISPATCH_QUEUE_SERIAL)

    func dispatch(message: OperationCommand) -> Task<()> {
        return Task(()).continueWithTask(Executor.Queue(gcdq)) { [weak self] task in
            guard let S = self else { return Task.cancelledTask() }
            return S.run(message)
        }
    }

    private func run(message: OperationCommand) -> Task<()> {
        debugLog("OperationService.run(\(message))")
        let driver = self.driver
        switch message {
        case .ReloadHome:
            return API.Home.summary().dispatchTo(driver.userInteraction) { summary, state in
                state.reloadHome(summary)
            }
        }
    }
}

private typealias API = APIService

private extension Task {
    /// Dispatches a transaction to `UserInteractionService`.
    ///
    /// The transaction itself will be executed in main thread.
    ///
    /// - Note: It's recommended to preprocess any required data before passing them into transaction
    ///         to avoid stopping main thread.
    ///
    func dispatchTo<U>(userInteraction: UserInteractionService, transaction: (parameter: TResult, inout state: UserInteractionState) throws -> U) -> Task<U> {
        return continueWithTask { (task: Task<TResult>) -> Task<U> in
            guard let result = task.result else {
                if task.completed == false { fatalErrorWithReporting("Incomplete task should not continue.") }
                guard let error = task.error else { fatalErrorWithReporting("Missing `error` in faulted task.") }
                return Task<U>(error: error)
            }
            return userInteraction.dispatch { [result] state in
                return try transaction(parameter: result, state: &state)
            }
        }
    }
}

//private enum UserInteractionTransactionContinuationError: ErrorType {
//    case BadPriorContinuationState
//    case StateUndetectable
//}
//private extension UserInteractionService {
//    func continueTask<U,V>(task: Task<U>, with transaction: (parameter: U, inout state: UserInteractionState) throws -> V) -> Task<V> {
//        return task.continueWithTask() { [weak self] (task: Task<U>) -> Task<V> in
//            guard let S = self else { return Task.cancelledTask() }
//            guard task.completed else { throw UserInteractionTransactionContinuationError.BadPriorContinuationState }
//            if let error = task.error { throw error }
//            guard let result = task.result else { throw UserInteractionTransactionContinuationError.StateUndetectable }
//            return S.dispatch { state in
//                return transaction(parameter: result, state: &state)
//            }
//        }
//    }
//}







