//
//  CrateInspectorViewController.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/04.
//  Copyright © 2016 Eonil. All rights reserved.
//

import UIKit
import EonilToolbox

private enum TableSection {
    case dummyForInfoHeader
    case datasheet

    static let all: [TableSection] = [.dummyForInfoHeader, .datasheet]
}

private extension DatasheetModeID {
    func getLabel() -> String {
        switch self {
        case .links:            return "Links"
        case .dependencies:     return "Dependencies"
        case .versions:         return "Versions"
        }
    }
    func getCellTypeID() -> CellTypeID {
        switch self {
        case .links:            return .link
        case .dependencies:     return .dependency
        case .versions:         return .version
        }
    }
}

final class CrateInspectorViewController: UIViewController, Renderable, DriverAccessible {
    private let tableView = UITableView()
    private var installer = ViewInstaller()
    private var renderedCrateState: CrateState?
    private var linkDatasheetState = [(displayName: String, targetURL: NSURL)]()
    private var dependencyDatasheetState = [(displayName: String, crateID: CrateID)]()
    private var versionDatasheetState = [(number: String, timepoint: String)]()

    /// Address to state.
    var indexInCrateInspectionStateStack: Int? {
        didSet {
            guard indexInCrateInspectionStateStack != oldValue else { return }
            render()
        }
    }
    /// Convenient getter to state.
    private var crateInspectionState: CrateInspectionState? {
        guard let index = indexInCrateInspectionStateStack else { return nil }
        return state.navigation.crateInspectorStack[index]
    }
    private var crateState: CrateState? {
        return (crateInspectionState?.crateID).flatMap({ state.database.crates[$0] })
    }
    func render() {
        installer.installIfNeeded {
            view.addSubview(tableView)
            tableView.pinCenterAndSize()
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 44
            tableView.sectionHeaderHeight = UITableViewAutomaticDimension
            tableView.estimatedSectionHeaderHeight = 44
            tableView.registerClass(InfoHeaderView.self, forHeaderFooterViewReuseIdentifier: HeaderTypeID.info.rawValue)
            tableView.registerClass(ModeSelectorHeaderView.self, forHeaderFooterViewReuseIdentifier: HeaderTypeID.modeSelector.rawValue)
            tableView.registerClass(ErrorCell.self, forCellReuseIdentifier: CellTypeID.error.rawValue)
//            tableView.registerClass(LinkCell.self, forCellReuseIdentifier: CellTypeID.link.rawValue)
//            tableView.registerClass(DependencyCell.self, forCellReuseIdentifier: CellTypeID.dependency.rawValue)
//            tableView.registerClass(VersionCell.self, forCellReuseIdentifier: CellTypeID.version.rawValue)
            tableView.tableFooterView = UIView()
            tableView.dataSource = self
            tableView.delegate = self
        }
        renderDatasheetStates()
    }
    private func renderDatasheetStates() {
        if crateState?.version != renderedCrateState?.version {
            renderedCrateState = crateState
            linkDatasheetState = [
                crateState?.basics.homepage.flatMap({ NSURL(string: $0) }).flatMap({ ("Website", $0) }),
                crateState?.basics.documentation.flatMap({ NSURL(string: $0) }).flatMap({ ("Documentation", $0) }),
                crateState?.basics.repository.flatMap({ NSURL(string: $0) }).flatMap({ ("Repository", $0) }),
            ].flatMap({ $0 })
        }
        tableView.reloadData()
    }
}

extension CrateInspectorViewController {
    override func viewWillAppear(animated: Bool) {
         super.viewWillAppear(animated)
        (crateInspectionState?.crateID).applyOptionally { driver.operation.reloadCrateExtrasFor($0) }
    }
}

extension CrateInspectorViewController: UITableViewDataSource, UITableViewDelegate {
    @objc
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return TableSection.all.count
    }
    @objc
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch TableSection.all[section] {
        case .dummyForInfoHeader:
            return 0
        case .datasheet:
            guard let mode = crateInspectionState?.datasheetMode else { return 0 }
            switch mode {
            case .links:        return linkDatasheetState.count
            case .dependencies: return dependencyDatasheetState.count
            case .versions:     return versionDatasheetState.count
            }
        }
    }
    @objc
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch TableSection.all[section] {
        case .dummyForInfoHeader:
            guard let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier(HeaderTypeID.info.rawValue) as? InfoHeaderView else { return nil }
            view.render(crateState)
            return view
        case .datasheet:
            guard let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier(HeaderTypeID.modeSelector.rawValue) as? ModeSelectorHeaderView else { return nil }
            view.render(crateInspectionState?.datasheetMode)
            view.onEvent = { [weak self] in
                guard let S = self else { return }
                switch $0 {
                case let .didSelectMode(newMode):
                    guard let index = S.indexInCrateInspectionStateStack else { return }
                    S.driver.userInteraction.dispatchTransaction { state in
                        state.navigation.setMode((newMode ?? .links), ofCrateInspectorAtIndex: index)
                    }
                }
            }
            return view
        }
    }
    @objc
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        func getErrorCell() -> UITableViewCell {
            return tableView.dequeueReusableCellWithIdentifier(CellTypeID.error.rawValue, forIndexPath: indexPath)
        }
        func getAndReconfigureCell<T: UITableViewCell>(cellTypeID: CellTypeID, @noescape _ f: (cell: T) -> ()) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCellWithIdentifier(cellTypeID.rawValue, forIndexPath: indexPath) as? T else {
                assert(false)
                precondition(cellTypeID != .error)
                return getErrorCell()
            }
            f(cell: cell)
            return cell
        }

        switch TableSection.all[indexPath.section] {
        case .dummyForInfoHeader:
            fatalError()

        case .datasheet:
            func getCell<T: UITableViewCell>(cellTypeID: CellTypeID, style: UITableViewCellStyle) -> T {
                return (tableView.dequeueReusableCellWithIdentifier(cellTypeID.rawValue) as? T) ?? T(style: style, reuseIdentifier: cellTypeID.rawValue)
            }
            guard let mode = crateInspectionState?.datasheetMode else { return getErrorCell() }
            switch mode {
            case .links:
                let cell = getCell(.link, style: .Value1) as LinkCell
                cell.render(linkDatasheetState[indexPath.row])
                return cell

            case .dependencies:
                let cell = getCell(.dependency, style: .Value1) as DependencyCell
                cell.render(dependencyDatasheetState[indexPath.row])
                return cell

            case .versions:
                let cell = getCell(.version, style: .Value1) as VersionCell
                cell.render(versionDatasheetState[indexPath.row])
                return cell
            }
        }

    }
}








////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

private enum HeaderTypeID: String {
    case info
    case modeSelector
}
private final class InfoHeaderView: UITableViewHeaderFooterView {
    private let stackView = UIStackView()
    private let authorLabel = UILabel()
    private let licenseLabel = UILabel()
    private let nameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let transmissionAcitivityIndicatorView = UIActivityIndicatorView()
    private let downloadCountLabel = UILabel()
    private var installer = ViewInstaller()
    func render(crateState: CrateState?) {
        installer.installIfNeeded {
            backgroundView = UIView()
            backgroundView?.backgroundColor = UIColor.whiteColor()
//            contentView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(stackView)
            stackView.axis = .Vertical
            stackView.alignment = .Center
            stackView.layoutMarginsRelativeArrangement = true
            stackView.pinCenterX()
            stackView.pinWidthTo(contentView)
            stackView.pinTop()
            stackView.pinBottom()
            stackView.addArrangedSubview(authorLabel)
            stackView.addArrangedSubview(licenseLabel)
            stackView.addArrangedSubview(nameLabel)
            stackView.addArrangedSubview(descriptionLabel)
            stackView.addArrangedSubview(downloadCountLabel)
            stackView.addArrangedSubview(transmissionAcitivityIndicatorView)
            nameLabel.numberOfLines = 0
//            nameLabel.backgroundColor = UIColor.blueColor()
            descriptionLabel.numberOfLines = 0
//            descriptionLabel.backgroundColor = UIColor.redColor()
            transmissionAcitivityIndicatorView.activityIndicatorViewStyle = .Gray
        }
        authorLabel.text = (crateState?.extras.authors.result ?? []).joinWithSeparator(", ")
        licenseLabel.text = crateState?.basics.license
        nameLabel.text = crateState?.basics.name
        descriptionLabel.text = crateState?.basics.description
        downloadCountLabel.text = (crateState?.basics.downloads).flatMap { "Downloaded \($0) time\($0 == 1 ? "" : "s")." }
//        let isTrasferringDatasheet = (crateState?.extras.isTransferringAny() ?? false)
//        let canRenderDatasheet = (crateState?.extras.isReady)
//        datasheetModeSegmentedControl.hidden = (canRenderDatasheet == false)
//        datasheetTableView.hidden = (canRenderDatasheet == false)
//        isTrasferringDatasheet ? transmissionAcitivityIndicatorView.startAnimating() : transmissionAcitivityIndicatorView.stopAnimating()
    }
    override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }
}
private final class ModeSelectorHeaderView: UITableViewHeaderFooterView {
    private let modeSegmentedControl = UISegmentedControl()
    private var installer = ViewInstaller()
    var onEvent: (ModeSelectorHeaderViewEvent->())?
    func render(newMode: DatasheetModeID?) {
        installer.installIfNeeded {
            backgroundView = UIView()
            backgroundView?.backgroundColor = UIColor.whiteColor()
            contentView.addSubview(modeSegmentedControl)
            modeSegmentedControl.pinCenter()
            modeSegmentedControl.pinWidthTo(contentView, constant: -20)
            modeSegmentedControl.pinHeightTo(contentView, constant: -10)
            for i in DatasheetModeID.all.entireRange {
                let mode = DatasheetModeID.all[i]
                let label = mode.getLabel()
                modeSegmentedControl.insertSegmentWithTitle(label, atIndex: i, animated: false)
            }
            modeSegmentedControl.addTarget(self, action: #selector(EONIL_modeDidChangeValue(_:)), forControlEvents: .ValueChanged)
        }
        func getModeIndex() -> Int {
            guard let newMode = newMode else { return UISegmentedControlNoSegment }
            guard let newIndex = DatasheetModeID.all.indexOf(newMode) else { return UISegmentedControlNoSegment }
            return newIndex
        }
        modeSegmentedControl.selectedSegmentIndex = getModeIndex()
    }
    private func scanDatasheetMode() -> DatasheetModeID? {
        guard DatasheetModeID.all.entireRange.contains(modeSegmentedControl.selectedSegmentIndex) else { return nil }
        return DatasheetModeID.all[modeSegmentedControl.selectedSegmentIndex]
    }
    @objc
    private func EONIL_modeDidChangeValue(_: AnyObject?) {
        let newMode = scanDatasheetMode()
        onEvent?(.didSelectMode(newMode))
    }
}
private enum ModeSelectorHeaderViewEvent {
    case didSelectMode(DatasheetModeID?)
}





////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

private enum CellTypeID: String {
    case error
    case info
    case modeSelector
    case link
    case dependency
    case version
}
private final class ErrorCell: UITableViewCell {
}


private final class LinkCell: UITableViewCell {
    func render(newState: (displayName: String, targetURL: NSURL)) {
        textLabel?.text = newState.displayName
        detailTextLabel?.text = newState.targetURL.host
    }
}
private final class DependencyCell: UITableViewCell {
    func render(newState: (displayName: String, crateID: CrateID)) {
    }
}
private final class VersionCell: UITableViewCell {
    /// - Parameter number: A version number expression.
    /// - Parameter timepoint: A IEEE1394 formatted date-time expression.
    func render(newState: (number: String, timepoint: String)) {
        textLabel?.text = newState.number
        detailTextLabel?.text = newState.timepoint
    }
}
















