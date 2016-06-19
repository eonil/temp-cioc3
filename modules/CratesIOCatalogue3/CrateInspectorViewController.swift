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
//    case dummyForModeSelectorHeader
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


private struct LocalState {
    var linkDatasheetState = [LinkItemState]()
    var dependencyDatasheetState = [DependencyItemState]()
    var versionDatasheetState = [VersionItemState]()
}
private typealias LinkItemState = (displayName: String, targetURL: NSURL)
private typealias DependencyItemState = (displayName: String, crateID: CrateID)
private typealias VersionItemState = (number: String, timepoint: String)


final class CrateInspectorViewController: UIViewController, Renderable, DriverAccessible {
    private let nameLabel = UILabel()
    private let tableView = UITableView()
    private var installer = ViewInstaller()
    private var renderedStateVersion: Version?
    private var localState = LocalState()

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
            navigationItem.titleView = {
                // This container is required to make title content (`nameLabel`) to be resized automatically using Auto Layout.
                let titleContainerView = UIView()
                titleContainerView.addSubview(nameLabel)
                nameLabel.pinCenter()
                return titleContainerView
            }()
            view.addSubview(tableView)
            tableView.pinCenterAndSize()
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 44
            tableView.sectionHeaderHeight = UITableViewAutomaticDimension
            tableView.estimatedSectionHeaderHeight = 44
            tableView.registerClass(InfoHeaderView.self, forHeaderFooterViewReuseIdentifier: HeaderFooterTypeID.info.rawValue)
            tableView.registerClass(ModeSelectorHeaderView.self, forHeaderFooterViewReuseIdentifier: HeaderFooterTypeID.modeSelector.rawValue)
            tableView.registerClass(ErrorCell.self, forCellReuseIdentifier: CellTypeID.error.rawValue)
//            tableView.registerClass(LinkCell.self, forCellReuseIdentifier: CellTypeID.link.rawValue)
//            tableView.registerClass(DependencyCell.self, forCellReuseIdentifier: CellTypeID.dependency.rawValue)
//            tableView.registerClass(VersionCell.self, forCellReuseIdentifier: CellTypeID.version.rawValue)
            tableView.tableFooterView = UIView()
            tableView.dataSource = self
            tableView.delegate = self
            tableView.reloadData()
        }
        nameLabel.attributedText = crateState?.basics?.name.attributed().stylizedSilently(.crateInspector(.titleName))
        renderDatasheetStates()
        renderedStateVersion = state.version
    }
    private func renderDatasheetStates() {
        if state.version != renderedStateVersion {
            localState.linkDatasheetState = [
                crateState?.basics?.homepage.flatMap({ NSURL(string: $0) }).flatMap({ ("Website", $0) }),
                crateState?.basics?.documentation.flatMap({ NSURL(string: $0) }).flatMap({ ("Documentation", $0) }),
                crateState?.basics?.repository.flatMap({ NSURL(string: $0) }).flatMap({ ("Repository", $0) }),
            ].flatMap({ $0 })
            localState.dependencyDatasheetState = (crateState?.extras.dependencies.result ?? []).map { DependencyItemState($0.name, $0.id) }
            localState.versionDatasheetState = (crateState?.extras.versions.result ?? []).map { VersionItemState($0.0, $0.1) }
            if let modeSelector = tableView.headerViewForSection(1) as? ModeSelectorHeaderView {
                modeSelector.render(mode: crateInspectionState?.datasheetMode ?? .links, localState: localState)
            }
            reloadDatasheetWithAnimation()
        }
    }

    private func reloadDatasheetWithAnimation() {
        tableView.beginUpdates()
        if let info = tableView.headerViewForSection(0) as? InfoHeaderView {
            info.render(crateState)
        }
        tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
        tableView.endUpdates()
//        if let mode = crateInspectionState?.datasheetMode {
//            switch mode {
//            case .links:
//                let rows = (0..<tableView.numberOfRowsInSection(1)).map { NSIndexPath(forRow: $0, inSection: 1) }
//                if rows.count > 0 {
//                    tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
//                }
//            case .dependencies, .versions:
////                let oldRow
//                let rowsToDelete = (0..<tableView.numberOfRowsInSection(1)).map { NSIndexPath(forRow: $0, inSection: 1) }
//                let rowsToInsert = (0..<tableView(tableView, numberOfRowsInSection: 1)).map { NSIndexPath(forRow: $0, inSection: 1) }
//                tableView.beginUpdates()
//                tableView.deleteRowsAtIndexPaths(rowsToDelete, withRowAnimation: .Fade)
//                tableView.insertRowsAtIndexPaths(rowsToInsert, withRowAnimation: .Fade)
//                //        tableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: .Fade)
//                tableView.endUpdates()
//            }
//        }
//        else {
//        }
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
            case .links:        return localState.linkDatasheetState.count
            case .dependencies: return localState.dependencyDatasheetState.count
            case .versions:     return localState.versionDatasheetState.count
            }
        }
    }
    @objc
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch TableSection.all[section] {
        case .dummyForInfoHeader:
            guard let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier(HeaderFooterTypeID.info.rawValue) as? InfoHeaderView else { return nil }
            view.render(crateState)
            return view
        case .datasheet:
            guard let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier(HeaderFooterTypeID.modeSelector.rawValue) as? ModeSelectorHeaderView else { return nil }
            view.render(mode: crateInspectionState?.datasheetMode, localState: localState)
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
                cell.render(localState.linkDatasheetState[indexPath.row])
                return cell

            case .dependencies:
                let cell = getCell(.dependency, style: .Value1) as DependencyCell
                cell.render(localState.dependencyDatasheetState[indexPath.row])
                return cell

            case .versions:
                let cell = getCell(.version, style: .Value1) as VersionCell
                cell.render(localState.versionDatasheetState[indexPath.row])
                return cell
            }
        }

    }
}








////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

private enum HeaderFooterTypeID: String {
    case info
    case modeSelector
}
private final class InfoHeaderView: UITableViewHeaderFooterView {
    private let stackView = UIStackView()
    private let authorLabel = UILabel()
    private let licenseContainerView = UIView()
    private let licenseLabel = UILabel()
//    private let descriptionLabel = UILabel()
    private let descriptionTextView = UITextView()
    private let downloadCountLabel = UILabel()
    private let currentVersionLabel = UILabel()
    private let transmissionAcitivityIndicatorView = UIActivityIndicatorView()
    private var installer = ViewInstaller()
    func render(crateState: CrateState?) {
        assert(NSThread.isMainThread())
        installer.installIfNeeded {
            func getPaddingView(height: CGFloat) -> UIView {
                let view = UIView()
                view.pinHeightTo(height)
                return view
            }
            backgroundView = UIView()
            backgroundView?.backgroundColor = UIColor.whiteColor()
//            contentView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(stackView)
            stackView.axis = .Vertical
            stackView.alignment = .Center
            stackView.layoutMarginsRelativeArrangement = true
            stackView.pinCenterX()
            stackView.pinWidthTo(contentView, constant: -20)
            stackView.pinTop()
            stackView.pinBottom()
            stackView.addArrangedSubview(getPaddingView(10))
            stackView.addArrangedSubview(authorLabel)

            stackView.addArrangedSubview(getPaddingView(10))
            stackView.addArrangedSubview(licenseContainerView)
            stackView.addArrangedSubview(getPaddingView(30))
            stackView.addArrangedSubview(getPaddingView(10))
//            stackView.addArrangedSubview(descriptionLabel)
            stackView.addArrangedSubview(descriptionTextView)
            stackView.addArrangedSubview(getPaddingView(10))
            stackView.addArrangedSubview(downloadCountLabel)
            stackView.addArrangedSubview(getPaddingView(10))
            stackView.addArrangedSubview(currentVersionLabel)
            stackView.addArrangedSubview(getPaddingView(20))
//            stackView.addArrangedSubview(transmissionAcitivityIndicatorView)
            stackView.addArrangedSubview(UIView())
            licenseContainerView.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0.3, alpha: 1)
            licenseContainerView.layer.cornerRadius = 3
            licenseContainerView.addSubview(licenseLabel)
            licenseLabel.pinCenter()
            licenseLabel.pinWidthTo(licenseContainerView, constant: -6)
            licenseLabel.pinHeightTo(licenseContainerView, constant: -6)
//            descriptionLabel.numberOfLines = 0
            descriptionTextView.scrollEnabled = false
            descriptionTextView.textContainer.heightTracksTextView = true
            descriptionTextView.editable = false

//            downloadCountLabel.pinWidthTo(contentView)
//            transmissionAcitivityIndicatorView.activityIndicatorViewStyle = .Gray
        }

//        let authorsText = crateState?.extras.authors.result?.joinWithSeparator(", ").attributed().stylizedSilently(.crateInspector(.infoAuthor))
//        authorLabel.attributedText = authorsText
//        authorLabel.hidden = (authorsText == nil)
//        if authorsText == nil {
//            authorLabel.alpha = 0
//        }
//        else {
//            authorLabel.alpha = 1
//        }
//


        func animate() {
            authorLabel.attributedText = crateState?.extras.authors.result?.joinWithSeparator(", ").attributed().stylizedSilently(.crateInspector(.infoAuthor))
            authorLabel.hidden = (authorLabel.attributedText == nil)

            licenseLabel.attributedText = crateState?.basics?.license?.attributed().stylizedSilently(.crateInspector(.infoLicense))
            licenseLabel.hidden = (licenseLabel.attributedText == nil)

//            descriptionLabel.attributedText = crateState?.basics?.description?.attributed().stylizedSilently(.crateInspector(.infoDescription))
//            descriptionLabel.hidden = (descriptionLabel.attributedText == nil)
            descriptionTextView.attributedText = crateState?.basics?.description?.attributed().stylizedSilently(.crateInspector(.infoDescription))
            descriptionTextView.hidden = (descriptionTextView.attributedText == nil)

            downloadCountLabel.attributedText = (crateState?.basics?.downloads).flatMap { "Downloaded \($0) time\($0 == 1 ? "" : "s")." }?.attributed().stylizedSilently(.crateInspector(.infoDownloadCount))
            downloadCountLabel.hidden = (downloadCountLabel.attributedText == nil)

            currentVersionLabel.attributedText = (crateState?.basics?.version)?.attributed().stylizedSilently(.crateInspector(.infoCurrentVersion))
            currentVersionLabel.hidden = (currentVersionLabel.attributedText == nil)

            stackView.layoutIfNeeded()
//            authorLabel.layer.removeAllAnimations()
//            authorLabel.alpha = 1
        }
        UIView.animateWithDuration(1) {
            animate()
        }


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
    func render(mode newMode: DatasheetModeID?, localState: LocalState) {
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
        func getSegmentEnabled() -> [Bool] {
            return [
                localState.linkDatasheetState.count > 0,
                localState.dependencyDatasheetState.count > 0,
                localState.versionDatasheetState.count > 0,
            ]
        }
        func getModeIndex() -> Int {
            guard let newMode = newMode else { return UISegmentedControlNoSegment }
            guard let newIndex = DatasheetModeID.all.indexOf(newMode) else { return UISegmentedControlNoSegment }
            return newIndex
        }
        modeSegmentedControl.selectedSegmentIndex = getModeIndex()
        for (index, enabled) in getSegmentEnabled().enumerate() {
            modeSegmentedControl.setEnabled(enabled, forSegmentAtIndex: index)
//            if modeSegmentedControl.selectedSegmentIndex == index {
//                modeSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
//            }
        }
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
    private var installer = ViewInstaller()
    func render(newState: (displayName: String, targetURL: NSURL)) {
        textLabel?.attributedText = newState.displayName.attributed().stylizedSilently(.crateInspector(.linkName))
        detailTextLabel?.attributedText = newState.targetURL.host?.attributed().stylizedSilently(.crateInspector(.linkValue))
    }
}
private final class DependencyCell: UITableViewCell {
    func render(newState: (displayName: String, crateID: CrateID)) {
        textLabel?.attributedText = newState.displayName.attributed().stylizedSilently(.crateInspector(.dependencyName))
        accessoryType = .DisclosureIndicator
    }
}
private final class VersionCell: UITableViewCell {
    /// - Parameter number: A version number expression.
    /// - Parameter timepoint: A IEEE1394 formatted date-time expression.
    func render(newState: (number: String, timepoint: String)) {
        textLabel?.attributedText = newState.number.attributed().stylizedSilently(.crateInspector(.versionName))
        detailTextLabel?.attributedText = newState.timepoint.attributed().stylizedSilently(.crateInspector(.versionValue))
    }
}
















