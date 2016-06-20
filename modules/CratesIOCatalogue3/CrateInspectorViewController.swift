//
//  CrateInspectorViewController.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/04.
//  Copyright © 2016 Eonil. All rights reserved.
//

import UIKit
import EonilToolbox
import BoltsSwift

private enum TableSection {
    case placeholder
    case datasheet
    static let all: [TableSection] = [.placeholder, .datasheet]
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
    var crateInspectionState: CrateInspectionState?
    var crateState: CrateState?
    var linkDatasheetState = [LinkItemState]()
    var dependencyDatasheetState = VersioningContainer<[DependencyItemState]>(version: Version(), content: [])
    var versionDatasheetState = VersioningContainer<[VersionItemState]>(version: Version(), content: [])
}
private struct LinkItemState: Equatable {
    var displayName: String
    var targetURL: NSURL
}
private func == (a: LinkItemState, b: LinkItemState) -> Bool {
    return a.displayName == b.displayName && a.targetURL == b.targetURL
}
private typealias DependencyItemState = (displayName: String, crateID: CrateID)
private typealias VersionItemState = (number: String, timepoint: String)


/// CAUTION!!!
/// ----------
/// - DO NOT try to make table header, section headers to be dyanamically resizable.
///     I tried it for 8 hours in a summer of 2016, but all failed. `UITableView` has
///     shows numerous bugs if I try to resize them, and prevent that in every possible ways.
///
/// - There's no way to remove separator lines from table-view.
///
/// So I finally settled on just plain-old view that places on table-view.
///
final class CrateInspectorViewController: UIViewController, Renderable, DriverAccessible {
    private let titleLabel = UILabel()
    private let tableView = UITableView()
    private let infoView = CrateInspectorInfoView()
    private let modeSelectorContainerView = UIView()
    private let modeSelectorSegmentedControl = UISegmentedControl()
    private var installer = ViewInstaller()
    private var localState = LocalState()

    /// Address to state.
    var indexInCrateInspectionStateStack: Int? {
        didSet {
            guard indexInCrateInspectionStateStack != oldValue else { return }
            render()
        }
    }
    func render() {
        assertMainThread()
        installer.installIfNeeded {
            navigationItem.titleView = {
                // This container is required to make title content (`nameLabel`) to be resized automatically using Auto Layout.
                let titleContainerView = UIView()
                titleContainerView.addSubview(titleLabel)
                titleLabel.pinCenter()
                return titleContainerView
            }()
            view.addSubview(tableView)
            tableView.pinCenterAndSize()
            // DO NOT use Self-Sizing Cells. That makes table-view cells jumps,
            // and that jump causes unwanted animation.
//            tableView.rowHeight = UITableViewAutomaticDimension
//            tableView.estimatedRowHeight = 44
//            tableView.sectionHeaderHeight = UITableViewAutomaticDimension
//            tableView.estimatedSectionHeaderHeight = 44
            tableView.registerClass(ErrorCell.self, forCellReuseIdentifier: CellTypeID.error.rawValue)
            // We need to instantiate table-cell ourselfves to make a proper style.
//            tableView.registerClass(LinkCell.self, forCellReuseIdentifier: CellTypeID.link.rawValue)
//            tableView.registerClass(DependencyCell.self, forCellReuseIdentifier: CellTypeID.dependency.rawValue)
//            tableView.registerClass(VersionCell.self, forCellReuseIdentifier: CellTypeID.version.rawValue)
            tableView.tableFooterView = UIView()
            tableView.dataSource = self
            tableView.delegate = self
            tableView.reloadData()
            tableView.addSubview(infoView)
            tableView.addSubview(modeSelectorContainerView)
            infoView.pinTop()
            infoView.pinCenterX()
            infoView.pinWidthTo(view)
            // `modeSelectorContainerView` will be laid out manually. Because it has to consider
// scrolling offset and info-area length.
            modeSelectorContainerView.backgroundColor = UIColor.whiteColor()
            modeSelectorContainerView.addSubview(modeSelectorSegmentedControl)
            modeSelectorSegmentedControl.pinCenter()
            modeSelectorSegmentedControl.pinWidthTo(modeSelectorContainerView, constant: -20)
            modeSelectorSegmentedControl.pinHeightTo(modeSelectorContainerView, constant: -10)
            for i in DatasheetModeID.all.entireRange {
                let mode = DatasheetModeID.all[i]
                let label = mode.getLabel()
                modeSelectorSegmentedControl.insertSegmentWithTitle(label, atIndex: i, animated: false)
            }
            modeSelectorSegmentedControl.addTarget(self, action: #selector(EONIL_modeDidChangeValue(_:)), forControlEvents: .ValueChanged)
//            if let crateState = crateState {
//                infoView.render(crateState)
//                infoView.layoutIfNeeded()
//            }
        }
        downloadData()
        renderData()
        renderLayout()
    }
    private func downloadData() {
        var needsReloadingDatasheetMode = false
        localState.crateInspectionState = {
            guard let index = indexInCrateInspectionStateStack else { return nil }
            let newCrateInspectionState = state.navigation.crateInspectorStack[index]
            if newCrateInspectionState.datasheetMode != localState.crateInspectionState?.datasheetMode {
                needsReloadingDatasheetMode = true
            }
            return newCrateInspectionState
        }()
        if needsReloadingDatasheetMode {
            reloadDatasheetOf(localState.crateInspectionState?.datasheetMode)
        }
        localState.crateState = (localState.crateInspectionState?.crateID).flatMap({ state.database.crates[$0] })

        func toLinkItemState(name: String, _ address: String?) -> LinkItemState? {
            guard let a = address else { return nil }
            guard let u = NSURL(string: a) else { return nil }
            return LinkItemState(displayName: name, targetURL: u)
        }
        let newLinkDatasheetState = [
            toLinkItemState("Website", localState.crateState?.basics?.homepage),
            toLinkItemState("Documentation", localState.crateState?.basics?.documentation),
            toLinkItemState("Repository", localState.crateState?.basics?.repository),
            ].flatMap({ $0 }) as [LinkItemState]
        if !(localState.linkDatasheetState == newLinkDatasheetState) {
            localState.linkDatasheetState = newLinkDatasheetState
            reloadDatasheetOf(.links)
        }
        if localState.dependencyDatasheetState.version != localState.crateState?.extras.dependencies.version {
            localState.dependencyDatasheetState.version = localState.crateState?.extras.dependencies.version ?? Version()
            localState.dependencyDatasheetState.content = (localState.crateState?.extras.dependencies.result ?? []).map { DependencyItemState($0.name, $0.id) }
            reloadDatasheetOf(.dependencies)
        }
        if localState.versionDatasheetState.version != localState.crateState?.extras.versions.version {
            localState.versionDatasheetState.version = localState.crateState?.extras.versions.version ?? Version()
            localState.versionDatasheetState.content = (localState.crateState?.extras.versions.result ?? []).map { VersionItemState($0.0, $0.1) }
            reloadDatasheetOf(.versions)
        }
    }
    private func renderData() {
        titleLabel.attributedText = localState.crateState?.basics?.name.attributed().stylizedSilently(.crateInspector(.titleName))
        infoView.render(localState.crateState)
        infoView.layoutIfNeeded()
        renderDatasheetModeSelector()
    }
    private func renderDatasheetModeSelector() {
        func getSegmentEnabled() -> [Bool] {
            return [
                localState.linkDatasheetState.count > 0,
                localState.dependencyDatasheetState.content.count > 0,
                localState.versionDatasheetState.content.count > 0,
            ]
        }
        func getModeIndex() -> Int {
            guard let newMode = localState.crateInspectionState?.datasheetMode else { return UISegmentedControlNoSegment }
            guard let newIndex = DatasheetModeID.all.indexOf(newMode) else { return UISegmentedControlNoSegment }
            return newIndex
        }
        modeSelectorSegmentedControl.selectedSegmentIndex = getModeIndex()
        for (index, enabled) in getSegmentEnabled().enumerate() {
            // This operation is non-animatable. (I tried with `UIView.animate...`, but this doesn't work)
            modeSelectorSegmentedControl.setEnabled(enabled, forSegmentAtIndex: index)
        }
    }

    private func reloadDatasheetOf(datasheetMode: DatasheetModeID?) {
        guard localState.crateInspectionState?.datasheetMode == datasheetMode else { return }
        let crateStateToRender = localState.crateState
        UIView.animateWithDuration(0.3) {
            self.infoView.render(crateStateToRender)
            self.infoView.setNeedsLayout()
            self.infoView.layoutIfNeeded()
        }
        if let datasheetSectionIndex = TableSection.all.indexOf(.datasheet) {
            CATransaction.begin()
            CATransaction.setAnimationDuration(1)
            tableView.beginUpdates()
//            CATransaction.setCompletionBlock { [weak self] in
//                guard let S = self else { return }
//                S.infoView.render(crateStateToRender, animated: true)
//                S.reloadDatasheetWithAnimation()
//            }

            let oldRowCount = tableView.numberOfRowsInSection(datasheetSectionIndex)
            let newRowCount = tableView(tableView, numberOfRowsInSection: datasheetSectionIndex)
            let sharedRowCount = min(oldRowCount, newRowCount)
            let rowsToDelete = (sharedRowCount..<max(sharedRowCount, oldRowCount)).map { NSIndexPath(forRow: $0, inSection: datasheetSectionIndex) }
            let rowsToReload = (0..<sharedRowCount).map { NSIndexPath(forRow: $0, inSection: datasheetSectionIndex) }
            let rowsToInsert = (sharedRowCount..<max(sharedRowCount, newRowCount)).map { NSIndexPath(forRow: $0, inSection: datasheetSectionIndex) }
            if rowsToDelete.count > 0 {
                tableView.deleteRowsAtIndexPaths(rowsToDelete, withRowAnimation: .Fade)
            }
            tableView.reloadRowsAtIndexPaths(rowsToReload, withRowAnimation: .Fade)
            if rowsToInsert.count > 0 {
                tableView.insertRowsAtIndexPaths(rowsToInsert, withRowAnimation: .Fade)
            }
            tableView.endUpdates()
        }
        CATransaction.commit()
    }




    private func renderLayout() {
        renderModeSelectorLayoutOnly()
    }
    private func renderModeSelectorLayoutOnly() {
        let contentOffsetY = tableView.contentOffset.y
        let topInset = tableView.contentInset.top
        let displacementInY = topInset + -contentOffsetY + -topInset + getInfoHeight()
        let filteredDisplacementInY = max(topInset, displacementInY)
        let modeBox = tableView.bounds.toBox().toSilentBox().splitInY(44, 0%, 100%).min.translatedBy((0, filteredDisplacementInY))
        modeSelectorContainerView.frame = modeBox.toCGRect()
    }
    private func getInfoHeight() -> CGFloat {
        let fit = CGSize(width: tableView.bounds.width, height: 0)
        return infoView.systemLayoutSizeFittingSize(fit, withHorizontalFittingPriority: UILayoutPriorityRequired, verticalFittingPriority: UILayoutPriorityFittingSizeLevel).height
    }
    private func getPlaceholderHeight() -> CGFloat {
        return getInfoHeight() + 44
    }
    // TODO: How can I get this value properly...?
    private func getTopInsetWithoutInfoArea() -> CGFloat {
        return 64
    }



    private func scanDatasheetMode() -> DatasheetModeID? {
        guard DatasheetModeID.all.entireRange.contains(modeSelectorSegmentedControl.selectedSegmentIndex) else { return nil }
        return DatasheetModeID.all[modeSelectorSegmentedControl.selectedSegmentIndex]
    }
    @objc
    private func EONIL_modeDidChangeValue(_: AnyObject?) {
        guard let index = indexInCrateInspectionStateStack else { return }
        let newMode = scanDatasheetMode()
        driver.userInteraction.dispatchTransaction { state in
            state.navigation.setMode((newMode ?? .links), ofCrateInspectorAtIndex: index)
        }
    }

}

extension CrateInspectorViewController {
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        (localState.crateInspectionState?.crateID).applyOptionally { driver.operation.reloadCrateExtrasFor($0) }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        render()
    }
}

extension CrateInspectorViewController: UITableViewDataSource, UITableViewDelegate {
    @objc
    func scrollViewDidScroll(scrollView: UIScrollView) {
        renderModeSelectorLayoutOnly()
    }
    @objc
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return TableSection.all.count
    }
    @objc
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch TableSection.all[section] {
        case .placeholder:
            return 1
        case .datasheet:
            guard let mode = localState.crateInspectionState?.datasheetMode else { return 0 }
            switch mode {
            case .links:        return localState.linkDatasheetState.count
            case .dependencies: return localState.dependencyDatasheetState.content.count
            case .versions:     return localState.versionDatasheetState.content.count
            }
        }
    }
    @objc
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch TableSection.all[indexPath.section] {
        case .placeholder:
            return getPlaceholderHeight()
        case .datasheet:
            return 44
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
        case .placeholder:
            let cell = UITableViewCell()
            cell.selectionStyle = .None
            return cell
        case .datasheet:
            func getCell<T: UITableViewCell>(cellTypeID: CellTypeID, style: UITableViewCellStyle) -> T {
                return (tableView.dequeueReusableCellWithIdentifier(cellTypeID.rawValue) as? T) ?? T(style: style, reuseIdentifier: cellTypeID.rawValue)
            }
            guard let mode = localState.crateInspectionState?.datasheetMode else { return getErrorCell() }
            switch mode {
            case .links:
                let cell = getCell(.link, style: .Value1) as LinkCell
                cell.render(localState.linkDatasheetState[indexPath.row])
                return cell

            case .dependencies:
                let cell = getCell(.dependency, style: .Value1) as DependencyCell
                cell.render(localState.dependencyDatasheetState.content[indexPath.row])
                return cell

            case .versions:
                let cell = getCell(.version, style: .Value1) as VersionCell
                cell.render(localState.versionDatasheetState.content[indexPath.row])
                return cell
            }
        }
    }
    @objc
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch TableSection.all[indexPath.section] {
        case .placeholder:
            // No-op.
            return
        case .datasheet:
            guard let mode = localState.crateInspectionState?.datasheetMode else { return  }
            switch mode {
            case .links:
                UIApplication.sharedApplication().openURL(localState.linkDatasheetState[indexPath.row].targetURL)
            case .dependencies:
                let crateID = localState.dependencyDatasheetState.content[indexPath.row].crateID
                driver.operation.pushCrateInspectorFor(crateID)
                
            case .versions:
                // No-op.
                return
            }
        }
    }
}









////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

private enum CellTypeID: String {
    case error
    case link
    case dependency
    case version
}
private final class ErrorCell: UITableViewCell {
}
private final class LinkCell: UITableViewCell {
    private var installer = ViewInstaller()
    func render(newState: LinkItemState) {
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
















