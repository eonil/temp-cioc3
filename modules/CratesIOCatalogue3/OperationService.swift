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

//    func dispatch(message: OperationCommand) -> Task<()> {
//        return Task(()).continueWithTask(Executor.Queue(gcdq)) { [weak self] task in
//            guard let S = self else { return Task.cancelledTask() }
//            return S.run(message)
//        }
//    }
//
//    private func run(message: OperationCommand) -> Task<()> {
//        debugLog("OperationService.run(\(message))")
//        let driver = self.driver
//        switch message {
//        case .ReloadHome:
//            return API.Home.summary().dispatchTo(driver.userInteraction) { summary, state in
//                state.reloadHome(summary)
//            }
//        }
//    }

    private func dispatch<U>(f: () -> Task<U>) -> Task<U> {
        return Task(()).continueWithTask(Executor.Queue(gcdq)) { task in
            return f()
        }
    }
    func reloadHome() -> Task<()> {
        return dispatch { [driver] in
            return API.Home.summary().dispatchTo(driver.userInteraction) { summary, state in
                state.reloadHome(summary)
            }
        }.branch {
            driver.userInteraction.networkActivityRendering.renderFor($0)
        }
    }

    func search(query: String) -> Task<()> {
        enum Error: ErrorType {
            case resultUndefined
        }
        return Task(()).continueOnSuccessWith(Executor.Queue(gcdq)) { [driver] in
            return APIService.Search.index(query, page: 0, per_page: 50, sort: .Downloads).continueWithTask { [driver] (task: Task<[DTOCrate]>) -> Task<()> in
                debugLog(task.error)
                guard let result = task.result else { return Task(error: Error.resultUndefined) }
                debugLog(result)
                return driver.userInteraction.dispatchTransaction { state in
                    var ids = [CrateID]()
                    for dto in result {
                        let id = state.database.appendOrUpdateCrate(dto)
                        ids.append(id)
                    }
                    var s = SearchResultState()
                    s.transmission.setDownloaded(ids)
                    state.navigation.setSearchResult(s)
                }
            }
        }
    }

    func reloadCrateFor(crateID: CrateID) -> Task<()> {
        enum Error: ErrorType {
            case MissingCrateStateFor(CrateID)
        }
        return driver.userInteraction.dispatchQuery { state in
            guard let crateServersideID = state.database.crates[crateID]?.serversideID else { throw Error.MissingCrateStateFor(crateID) }
            return crateServersideID
        }.continueOnSuccessWithTask(Executor.Queue(gcdq)) { [driver] crateServersideID in
            return API.Crate.show(crateServersideID).continueOnSuccessWithTask { [driver] result in
                return driver.userInteraction.dispatchTransaction { state in
                    state.database.appendOrUpdateCrate(result.crate)
                    state.database.update(crateID: crateID, dto: result.versions)
                }
            }
        }
    }
    func reloadCrateExtrasFor(crateID: CrateID) -> Task<()> {
        enum Error: ErrorType {
            case MissingCrateStateFor(CrateID)
//            case AlreadyTransferringFor(CrateID)
            case NoNeedToReloadFor(CrateID)
            case MissingCrateBasicVersionFor(CrateID)
        }

        return driver.userInteraction.dispatchTransaction { state in
            // Get crate-state.
            guard let crateState = state.database.crates[crateID] else { throw Error.MissingCrateStateFor(crateID) }
            guard crateState.extras.needsReloadingAny() else { throw Error.NoNeedToReloadFor(crateID) }
//            guard crateState.extras.isTransferringAny() == false else { throw Error.AlreadyTransferringFor(crateID) }
            state.database.setCrateExtrasTransferring(crateID)
            return crateState

        }.continueOnSuccessWithTask(Executor.Queue(gcdq)) { [driver] (crateState: CrateState) -> Task<()> in
            guard let crateVersion = crateState.basics?.version else { return Task(error: Error.MissingCrateBasicVersionFor(crateID)) }
            let downloadAuthorsTask = API.Crate.authors(crateState.serversideID, version: crateVersion).continueOnSuccessWithTask { result in
                return driver.userInteraction.dispatchTransaction { state in
                    state.database.update(crateID: crateID, dto: result)
                }
            }
            let downloadDependenciesTask = API.Crate.dependencies(crateState.serversideID, version: crateVersion).continueOnSuccessWithTask { result in
                return driver.userInteraction.dispatchTransaction { state in
                    state.database.update(crateID: crateID, dto: result)
                }
            }
            let downloadVersionsTask = API.Crate.show(crateState.serversideID).continueOnSuccessWithTask { result in
                return driver.userInteraction.dispatchTransaction { state in
                    state.database.appendOrUpdateCrate(result.crate)
                    state.database.update(crateID: crateID, dto: result.versions)
                }
            }
            return Task.whenAll([downloadAuthorsTask, downloadDependenciesTask, downloadVersionsTask])

        }.branch {
            driver.userInteraction.networkActivityRendering.renderFor($0)
        }
    }
    func pushCrateInspectorFor(crateID: CrateID) -> Task<()> {
        let performUI = driver.userInteraction.dispatchTransaction { state in
            // Perform UI first to provide better UX.
            state.navigation.pushCrateInspector(crateID)
        }
        let loadData = driver.operation.reloadCrateFor(crateID).continueOnSuccessWithTask { [driver] in
            // Extra data requires basic data (crate ID and version) to work properly.
            return driver.operation.reloadCrateExtrasFor(crateID)
        }
        return Task.whenAll([performUI, loadData])
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
            return userInteraction.dispatchTransaction { [result] state in
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







