//
//  Driver.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/04.
//  Copyright © 2016 Eonil. All rights reserved.
//

import BoltsSwift
import EonilToolbox

final class Driver {
    private static let theDriver = Driver()
    private var cmdq = [(DriverCommand,TaskCompletionSource<()>)]()
    private var isPaused = false
    private(set) var state = State()
    private let renderer = Renderer()

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
                debugPrint(state.navigation.detailStack)
            }
            catch let error {
                completion.trySetError(error)
            }
        }
        renderer.render()
    }
    private func step(command: DriverCommand) throws {
        debugPrint("Processing command: `\(command)`")
        switch command {
        case .Reset:
            state = State()

        case .Pause:
            isPaused = true

        case.Resume:
            isPaused = false

        case .WaitForDuration(let duration):
            MARK_unimplemented()

        case .UserInterface(let action):
            switch action {
            case .ReconfigureNavigation(let n):
                state.navigation = n
            case .PushCrateDetail(let crateID):
                state.navigation.detailStack.append(crateID)
            }
        }
    }
}

protocol DriverAccessible {
}
extension DriverAccessible {
    var driver: Driver {
        return Driver.theDriver
    }
}










