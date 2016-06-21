////
////  CrateInspectorInfoHeaderView.swift
////  CratesIOCatalogue3
////
////  Created by Hoon H. on 2016/06/19.
////  Copyright © 2016 Eonil. All rights reserved.
////
//
//import Foundation
//import UIKit
//import EonilToolbox
//
//final class CrateInspectorInfoView: UIView, DriverAccessible {
//    private let stackView = UIStackView()
//    private let authorConatinerView = UIView()
//    private let transmissionAcitivityIndicatorView = UIActivityIndicatorView()
//    private let authorLabel = UILabel()
//    private let licenseContainerView = UIView()
//    private let licenseLabel = UILabel()
//    private let descriptionTextView = UITextView()
//    private let downloadCountLabel = UILabel()
//    private let currentVersionLabel = UILabel()
//    private var installer = ViewInstaller()
//
//    func render(crateState: CrateState?) {
//        assertMainThread()
//        installer.installIfNeeded {
//            func getPaddingView(height: CGFloat) -> UIView {
//                let view = UIView()
//                view.pinHeightTo(height, weakly: false)
//                return view
//            }
//            addSubview(stackView)
//            stackView.axis = .Vertical
//            stackView.alignment = .Center
//            stackView.distribution = .Fill
//            stackView.layoutMarginsRelativeArrangement = true
//            stackView.pinCenterX()
//            stackView.pinWidthTo(self, constant: -20)
//            stackView.pinTop()
//            stackView.pinBottom()
//            stackView.addArrangedSubview(getPaddingView(10))
//            stackView.addArrangedSubview(authorConatinerView)
//
//            // This container is required to separate alpha blendings of
//            // label and activity-indicator.
//            authorConatinerView.addSubview(authorLabel)
//            authorConatinerView.addSubview(transmissionAcitivityIndicatorView)
////            authorConatinerView.pinWidthTo(self, constant: -20)
//            authorConatinerView.pinHeightAtLeast(lineHeightOf: Style.crateInspector(.infoAuthor).getFontSilently())
////            authorLabel.pinCenterAndSize()
//            authorLabel.pinWidthTo(stackView)
//            authorLabel.pinCenterX()
//            authorLabel.numberOfLines = 0
//            transmissionAcitivityIndicatorView.pinCenter()
//            transmissionAcitivityIndicatorView.activityIndicatorViewStyle = .Gray
//            transmissionAcitivityIndicatorView.startAnimating()
//
//            stackView.addArrangedSubview(getPaddingView(10))
//            stackView.addArrangedSubview(licenseContainerView)
//            stackView.addArrangedSubview(getPaddingView(30))
//            stackView.addArrangedSubview(getPaddingView(10))
//            stackView.addArrangedSubview(descriptionTextView)
//            stackView.addArrangedSubview(getPaddingView(10))
//            stackView.addArrangedSubview(downloadCountLabel)
//            stackView.addArrangedSubview(getPaddingView(10))
//            stackView.addArrangedSubview(currentVersionLabel)
//            stackView.addArrangedSubview(getPaddingView(20))
//            licenseContainerView.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0.3, alpha: 1)
//            licenseContainerView.layer.cornerRadius = 3
//            licenseContainerView.addSubview(licenseLabel)
//            licenseLabel.pinCenter()
//            licenseLabel.pinWidthTo(licenseContainerView, constant: -6)
//            licenseLabel.pinHeightTo(licenseContainerView, constant: -6)
////            descriptionTextView.pinWidthTo(self, constant: -20)
//            descriptionTextView.scrollEnabled = false
//            descriptionTextView.textContainer.heightTracksTextView = true
//            descriptionTextView.editable = false
//        }
//
//        renderValuesOnly(crateState)
//        renderLayoutOnly(crateState)
//    }
//    private func renderValuesOnly(crateState: CrateState?) {
//        authorLabel.attributedText = (crateState?.extras.authors.result != nil ? "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaab\na\na\na" : "aa").attributed().stylizedSilently(.crateInspector(.infoAuthor))
////        authorLabel.attributedText = crateState?.extras.authors.result?.joinWithSeparator(", ").attributed().stylizedSilently(.crateInspector(.infoAuthor))
//        licenseLabel.attributedText = crateState?.basics?.license?.attributed().stylizedSilently(.crateInspector(.infoLicense))
//        descriptionTextView.attributedText = crateState?.basics?.description?.attributed().stylizedSilently(.crateInspector(.infoDescription))
//        downloadCountLabel.attributedText = (crateState?.basics?.downloads).flatMap { "Downloaded \($0) time\($0 == 1 ? "" : "s")." }?.attributed().stylizedSilently(.crateInspector(.infoDownloadCount))
//        currentVersionLabel.attributedText = (crateState?.basics?.version)?.attributed().stylizedSilently(.crateInspector(.infoCurrentVersion))
//    }
//    private func renderLayoutOnly(crateState: CrateState?) {
//        let isTransferring = (crateState?.extras.authors.isTransferring ?? false)
//        if crateState?.extras.authors.isReady ?? false {
//            transmissionAcitivityIndicatorView.alpha = (isTransferring ? 1 : 0)
//        }
//        authorLabel.alpha = (authorLabel.attributedText == nil) ? 0 : 1
//        licenseContainerView.hidden = (licenseLabel.attributedText == nil)
//        descriptionTextView.hidden = (descriptionTextView.attributedText == nil)
//        downloadCountLabel.hidden = (downloadCountLabel.attributedText == nil)
//        currentVersionLabel.hidden = (currentVersionLabel.attributedText == nil)
//    }
//    override class func requiresConstraintBasedLayout() -> Bool {
//        return true
//    }
//}
//
//
//
//
//
