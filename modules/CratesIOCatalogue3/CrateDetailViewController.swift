//
//  CrateDetailViewController.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/04.
//  Copyright © 2016 Eonil. All rights reserved.
//

import UIKit
import EonilToolbox

private enum DatasheetMode {
    case links
    case dependencies
    case versions
}
extension DatasheetMode {
    static let all = [.links, .dependencies, .versions] as [DatasheetMode]
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

final class CrateDetailViewController: UIViewController, Renderable, DriverAccessible {
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let authorLabel = UILabel()
    private let licenseLabel = UILabel()
    private let nameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let transmissionAcitivityIndicatorView = UIActivityIndicatorView()
    private let downloadCountLabel = UILabel()
    private let datasheetModeSegmentedControl = UISegmentedControl()
    private let datasheetTableView = UITableView()
    private let footerCommentLabel = UILabel()
    private var installer = ViewInstaller()
    private var currentCrateStateVersion: Version?
    private var currentDatasheetMode = DatasheetMode.links
    private var linkDatasheetState = [(displayName: String, targetURL: NSURL)]()
    private var dependencyDatasheetState = [(displayName: String, crateID: CrateID)]()
    private var versionDatasheetState = [(number: String, timepoint: String)]()

    var crateID: CrateID? {
        didSet {
            crateID.applyOptionally { driver.operation.reloadCrateExtrasFor($0) }
            render()
        }
    }

    func render() {
        installer.installIfNeeded {
            stackView.axis = .Vertical
            stackView.alignment = .Center
            stackView.layoutMarginsRelativeArrangement = true
            datasheetModeSegmentedControl.insertSegmentWithTitle("Links", atIndex: 0, animated: false)
            datasheetModeSegmentedControl.insertSegmentWithTitle("Dependencies", atIndex: 1, animated: false)
            datasheetModeSegmentedControl.insertSegmentWithTitle("Versions", atIndex: 2, animated: false)
            datasheetTableView.registerClass(ErrorCell.self, forCellReuseIdentifier: CellTypeID.error.rawValue)
            datasheetTableView.registerClass(LinkCell.self, forCellReuseIdentifier: CellTypeID.link.rawValue)
            datasheetTableView.registerClass(DependencyCell.self, forCellReuseIdentifier: CellTypeID.dependency.rawValue)
            datasheetTableView.registerClass(VersionCell.self, forCellReuseIdentifier: CellTypeID.version.rawValue)
            view.addSubview(scrollView)
            scrollView.backgroundColor = UIColor.whiteColor()
            scrollView.pinCenterAndSize()
            scrollView.addSubview(stackView)
            stackView.pinCenterX()
            stackView.pinWidthTo(view)
            stackView.pinTop()
            stackView.pinBottom()
            stackView.addArrangedSubview(authorLabel)
            stackView.addArrangedSubview(licenseLabel)
            stackView.addArrangedSubview(nameLabel)
            stackView.addArrangedSubview(descriptionLabel)
            stackView.addArrangedSubview(downloadCountLabel)
            stackView.addArrangedSubview(datasheetModeSegmentedControl)
            stackView.addArrangedSubview(datasheetTableView)
            stackView.addArrangedSubview(transmissionAcitivityIndicatorView)
            stackView.addArrangedSubview(footerCommentLabel)
            nameLabel.numberOfLines = 0
//            nameLabel.backgroundColor = UIColor.blueColor()
            descriptionLabel.numberOfLines = 0
//            descriptionLabel.backgroundColor = UIColor.redColor()
            transmissionAcitivityIndicatorView.activityIndicatorViewStyle = .Gray
            datasheetModeSegmentedControl.pinWidthTo(view, constant: -20)
            datasheetModeSegmentedControl.addTarget(self, action: #selector(EONIL_modeDidChangeValue(_:)), forControlEvents: .ValueChanged)
            datasheetTableView.pinWidthTo(300)
            datasheetTableView.pinHeightTo(400)
            datasheetTableView.scrollEnabled = false
            datasheetTableView.dataSource = self
            datasheetTableView.delegate = self
        }

        let crateState = crateID.flatMap({ state.database.crates[$0] })

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
        datasheetModeSegmentedControl.selectedSegmentIndex = DatasheetMode.all.indexOf(currentDatasheetMode) ?? UISegmentedControlNoSegment
        footerCommentLabel.text = "links = \(linkDatasheetState))"
        renderDatasheetStates()
    }
    func renderDatasheetStates() {
        let crateState = crateID.flatMap({ state.database.crates[$0] })
        if crateState?.version != currentCrateStateVersion {
            currentCrateStateVersion = crateState?.version
            linkDatasheetState = [
                crateState?.basics.homepage.flatMap({ NSURL(string: $0) }).flatMap({ ("Website", $0) }),
                crateState?.basics.documentation.flatMap({ NSURL(string: $0) }).flatMap({ ("Documentation", $0) }),
                crateState?.basics.repository.flatMap({ NSURL(string: $0) }).flatMap({ ("Repository", $0) }),
            ].flatMap({ $0 })
        }
        datasheetTableView.reloadData()
    }

    private func scanDatasheetMode() {
        currentDatasheetMode = DatasheetMode.all[datasheetModeSegmentedControl.selectedSegmentIndex]
        render()
    }
}

extension CrateDetailViewController {
    @objc
    private func EONIL_modeDidChangeValue(_: AnyObject?) {
        scanDatasheetMode()
    }
}
//extension CrateDetailViewController {
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//    }
//}
extension CrateDetailViewController: UITableViewDataSource, UITableViewDelegate {
    @objc
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Only one section will be displayed at once.
        return 1
    }
    @objc
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentDatasheetMode {
        case .links:        return linkDatasheetState.count
        case .dependencies: return dependencyDatasheetState.count
        case .versions:     return versionDatasheetState.count
        }
    }
    @objc
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch currentDatasheetMode {
        case .links:
            guard let cell = tableView.dequeueReusableCellWithIdentifier(CellTypeID.link.rawValue) as? LinkCell else {
                return tableView.dequeueReusableCellWithIdentifier(CellTypeID.error.rawValue, forIndexPath: indexPath)
            }
            cell.state = linkDatasheetState[indexPath.row]
            return cell

        case .dependencies:
            guard let cell = tableView.dequeueReusableCellWithIdentifier(CellTypeID.dependency.rawValue) as? DependencyCell else {
                return tableView.dequeueReusableCellWithIdentifier(CellTypeID.error.rawValue, forIndexPath: indexPath)
            }
            cell.state = dependencyDatasheetState[indexPath.row]
            return cell

        case .versions:
            guard let cell = tableView.dequeueReusableCellWithIdentifier(CellTypeID.version.rawValue) as? VersionCell else {
                return tableView.dequeueReusableCellWithIdentifier(CellTypeID.error.rawValue, forIndexPath: indexPath)
            }
            cell.state = versionDatasheetState[indexPath.row]
            return cell
        }
    }
}






private enum CellTypeID: String {
    case error
    case link
    case dependency
    case version
}
private final class ErrorCell: UITableViewCell {
}
private final class InfoCell: UITableViewCell {

}
private final class ModeSelectorCell: UITableViewCell {

}
private final class LinkCell: UITableViewCell {
    var state: (displayName: String, targetURL: NSURL)? {
        didSet {
            render()
        }
    }
    convenience init() {
        self.init(style: UITableViewCellStyle.Value1, reuseIdentifier: CellTypeID.link.rawValue)
    }
    private override func layoutSubviews() {
        super.layoutSubviews()
        render()
    }
    func render() {
        textLabel?.text = state?.displayName
        detailTextLabel?.text = state?.targetURL.host
    }
}
private final class DependencyCell: UITableViewCell {
    var state: (displayName: String, crateID: CrateID)? {
        didSet {
            render()
        }
    }
    convenience init() {
        self.init(style: UITableViewCellStyle.Default, reuseIdentifier: CellTypeID.dependency.rawValue)
    }
    private override func layoutSubviews() {
        super.layoutSubviews()
        render()
    }
    func render() {
    }
}
private final class VersionCell: UITableViewCell {
    /// - Parameter number: A version number expression.
    /// - Parameter timepoint: A IEEE1394 formatted date-time expression.
    var state: (number: String, timepoint: String)? {
        didSet {
            render()
        }
    }
    convenience init() {
        self.init(style: UITableViewCellStyle.Value2, reuseIdentifier: CellTypeID.version.rawValue)
    }
    private override func layoutSubviews() {
        super.layoutSubviews()
        render()
    }
    func render() {
        textLabel?.text = state?.number
        detailTextLabel?.text = state?.timepoint
    }
}
















