//
//  Styling.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/16.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import UIKit

private let DEFAULT_TINT = UIColor(red: 50.0/255.0, green: 118.0/255.0, blue: 177.0/255.0, alpha: 1)

enum Style {
    case listCellCrateName
    case listCellCrateVersion
    case listCellCrateDescription
}
private extension Style {
    private func getForegroundColor() -> UIColor {
        switch self {
        case .listCellCrateName:        return UIColor(hue: 0, saturation: 0, brightness: 0.3, alpha: 1)
        case .listCellCrateVersion:     return DEFAULT_TINT
        case .listCellCrateDescription: return UIColor(hue: 0, saturation: 0, brightness: 0.5, alpha: 1)
        }

    }
}
extension NSAttributedString {
    private func foregroundColored(style: Style) -> NSAttributedString {
        return foregroundColored(style.getForegroundColor())
    }
    private func fonted(style: Style) throws -> NSAttributedString {
        switch style {
        case .listCellCrateName:        return try fonted("DINCondensed-Bold", size: 22)
        case .listCellCrateVersion:     return try fonted("HelveticaNeue-Light", size: 12)
        case .listCellCrateDescription: return try fonted("HelveticaNeue", size: 12)
        }
    }
    func stylized(style: Style) throws -> NSAttributedString {
        return try fonted(style).foregroundColored(style)
    }
    func stylizedSilently(style: Style) -> NSAttributedString? {
        return try? stylized(style)
    }
}









