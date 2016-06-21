//
//  CrateInspectorInfoView2.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/21.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import UIKit
import EonilToolbox

private struct LocalState {
    var animated: Bool = false
    var crateState: CrateState?
}

final class CrateInspectorInfoView2: UIView {
    private let divisionContainerView = MaxSizeView()
    private let divisionView = DivisionView()
    private let authorConatinerView = MaxSizeView()
    private let transmissionAcitivityIndicatorView = UIActivityIndicatorView()
    private let authorLabel = UILabel()
    private let licenseDivisionView = DivisionView()
    private let licenseContainerView = MaxSizeView()
    private let licenseLabel = UILabel()
    private let descriptionTextView = UITextView()
    private let downloadCountLabel = UILabel()
    private let currentVersionLabel = UILabel()
    private var installer = ViewInstaller()
    private var localState = LocalState()

    func render(crateState: CrateState?, animated: Bool) {
        installer.installIfNeeded {
            addSubview(divisionContainerView)
            divisionContainerView.edgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            divisionContainerView.addSubview(divisionView)
            divisionView.alignment = .fill
            divisionView.addSubview(authorConatinerView)
            divisionView.addPlaceholderSubview(length: 10)
            divisionView.addSubview(licenseDivisionView)
            divisionView.addPlaceholderSubview(length: 40)
            divisionView.addSubview(descriptionTextView)
            divisionView.addPlaceholderSubview(length: 10)
            divisionView.addSubview(downloadCountLabel)
            divisionView.addPlaceholderSubview(length: 10)
            divisionView.addSubview(currentVersionLabel)
            divisionView.addPlaceholderSubview(length: 10)
            authorConatinerView.addSubview(transmissionAcitivityIndicatorView)
            authorConatinerView.addSubview(authorLabel)
            transmissionAcitivityIndicatorView.activityIndicatorViewStyle = .Gray
            transmissionAcitivityIndicatorView.startAnimating()
            authorLabel.numberOfLines = 0
            authorLabel.alpha = 0
            licenseDivisionView.addSubview(licenseContainerView)
            licenseContainerView.edgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
            licenseContainerView.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0.3, alpha: 1)
            licenseContainerView.layer.cornerRadius = 3
            licenseContainerView.addSubview(licenseLabel)
            descriptionTextView.scrollEnabled = false
            descriptionTextView.textContainer.heightTracksTextView = true
            descriptionTextView.editable = false
        }

        // Download.
        localState.animated = animated
        localState.crateState = crateState

//        func getS() -> String? {
//            if localState.crateState?.extras.authors.result == nil { return nil }
//            return "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaab\na\na\na"
//        }
//        authorLabel.attributedText = getS()?.attributed().stylizedSilently(.crateInspector(.infoAuthor))
        authorLabel.attributedText = crateState?.extras.authors.result?.joinWithSeparator(", ").attributed().stylizedSilently(.crateInspector(.infoAuthor))
        licenseLabel.attributedText = localState.crateState?.basics?.license?.attributed().stylizedSilently(.crateInspector(.infoLicense))
        descriptionTextView.attributedText = localState.crateState?.basics?.description?.attributed().stylizedSilently(.crateInspector(.infoDescription))
        downloadCountLabel.attributedText = (localState.crateState?.basics?.downloads).flatMap { "Downloaded \($0) time\($0 == 1 ? "" : "s")." }?.attributed().stylizedSilently(.crateInspector(.infoDownloadCount))
        currentVersionLabel.attributedText = (localState.crateState?.basics?.version)?.attributed().stylizedSilently(.crateInspector(.infoCurrentVersion))

        // Render.
        renderLocalState()
    }
    private func renderLocalState() {
        func a() {
            divisionContainerView.frame = bounds
            authorLabel.alpha = localState.crateState?.extras.authors.result == nil ? 0 : 1
            transmissionAcitivityIndicatorView.alpha = (localState.crateState?.extras.authors.isTransferring ?? false) ? 1 : 0
            licenseContainerView.alpha = (localState.crateState?.basics?.license == nil) ? 0 : 1
            descriptionTextView.alpha = (localState.crateState?.basics?.description == nil) ? 0 : 1
            currentVersionLabel.alpha = (localState.crateState?.basics?.version == nil) ? 0 : 1
        }
        if localState.animated {
            UIView.animateWithDuration(0.5) { a() }
        }
        else {
            a()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        renderLocalState()
    }
}

extension CrateInspectorInfoView2 {
    override func sizeThatFits(size: CGSize) -> CGSize {
        return divisionContainerView.sizeThatFits(size)
    }
}

























