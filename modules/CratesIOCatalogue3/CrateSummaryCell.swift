//
//  CrateSummaryCell.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/20.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import UIKit
import EonilToolbox

final class CrateSummaryCell: UITableViewCell {
    private let nameLabel = UILabel()
    private let versionLabel = UILabel()
    private let descriptionLabel = UILabel()
    private var installer = ViewInstaller()
    var state: CrateStateBasics? {
        didSet {
            render()
        }
    }
    func render() {
        installer.installIfNeeded {
            contentView.addSubview(nameLabel)
            contentView.addSubview(versionLabel)
            contentView.addSubview(descriptionLabel)
            descriptionLabel.numberOfLines = 0
        }
        nameLabel.attributedText = state?.name.attributed().stylizedSilently(.crateList(.itemName))
        versionLabel.attributedText = state?.version.attributed().stylizedSilently(.crateList(.itemVersion))
        descriptionLabel.attributedText = state?.description?.attributed().stylizedSilently(.crateList(.itemDescription))
        renderLayoutOnly()
    }
    private func renderLayoutOnly() {
        let	LARGE_GAP = CGFloat(20)
        let	SMALL_GAP = CGFloat(10)

        let nameSize = nameLabel.sizeThatFits(CGSize.zero)
        let versionSize = versionLabel.sizeThatFits(CGSize.zero)
        let box = contentView.bounds.toBox().toSilentBox()
        let (_, contentBox, _) = box.splitInX(LARGE_GAP, 100%, LARGE_GAP).center.splitInY(SMALL_GAP, 100%, SMALL_GAP)
        let (topBox, _, bottomBox) = contentBox.splitInY(max(nameSize.height, versionSize.height), SMALL_GAP, 100%)
        let (nameBox, _, versionBox) = topBox.splitInX(100%, SMALL_GAP, versionSize.width)

        let descriptionSize = descriptionLabel.sizeThatFits(bottomBox.toCGRect().size)
        let (descriptionBox, _, _) = bottomBox.splitInY(descriptionSize.height, 0%, 0%)

        nameLabel.frame = nameBox.toCGRect()
        versionLabel.frame = versionBox.toCGRect()
        descriptionLabel.frame = descriptionBox.toCGRect()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        render()
    }
}










