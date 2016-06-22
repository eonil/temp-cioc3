//
//  CreditAttributionView.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/23.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import UIKit
import EonilToolbox

final class CreditAttributionView: UIView {
    private let textContainerView = MaxSizeView()
    private let textView = UITextView()
    private var installer = ViewInstaller()

    func render() {
        installer.installIfNeeded {
            addSubview(textContainerView)
            textContainerView.edgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
            textContainerView.addSubview(textView)
            textView.backgroundColor = UIColor.clearColor()
            textView.scrollEnabled = false
            textView.editable = false
            textView.attributedText = attributionText.attributed().stylizedSilently(.attribution(.text))
        }   
        textContainerView.frame = bounds
    }
    override func sizeThatFits(size: CGSize) -> CGSize {
        return textContainerView.sizeThatFits(size)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        render()
    }
}

private let attributionText = "This app is written by \"Eonil\".\nApp icon image is derived from original work by \"Freepik\".\nIcon image used under CC-BY-3.0 license."