//
//  Styling.swift
//  CratesIOCatalogue3
//
//  Created by Hoon H. on 2016/06/16.
//  Copyright © 2016 Eonil. All rights reserved.
//

import Foundation
import UIKit

enum Style {
    static let defaultTintColor = UIColor(red: 50.0/255.0, green: 118.0/255.0, blue: 177.0/255.0, alpha: 1)
    static let weakTintColor = UIColor(hue: 0, saturation: 0, brightness: 0.5, alpha: 1)
    case crateList(CrateListStyle)
    case crateInspector(CrateInspectorStyle)
}
enum CrateListStyle {
    case itemName
    case itemVersion
    case itemDescription
}
enum CrateInspectorStyle {
    case titleName
    case infoAuthor
    /// This is bright color because license text should be enclosed by a very dark rounded corner.
    case infoLicense
    case infoDescription
    case infoCurrentVersion
    case infoDownloadCount
    case linkName
    case linkValue
    case dependencyName
    case versionName
    case versionValue
}
private extension Style {
    private func getForegroundColor() -> UIColor {
        switch self {
        case let .crateList(substyle):
            switch substyle {
            case .itemName:             return UIColor(hue: 0, saturation: 0, brightness: 0.3, alpha: 1)
            case .itemVersion:          return Style.defaultTintColor
            case .itemDescription:      return UIColor(hue: 0, saturation: 0, brightness: 0.5, alpha: 1)
            }
        case let .crateInspector(substyle):
            switch substyle {
            case .titleName:            return UIColor(hue: 0, saturation: 0, brightness: 0.3, alpha: 1)
            case .infoAuthor:           return UIColor(hue: 0, saturation: 0, brightness: 0.4, alpha: 1)
            case .infoLicense:          return UIColor(hue: 0, saturation: 0, brightness: 0.9, alpha: 1)
            case .infoDescription:      return UIColor(hue: 0, saturation: 0, brightness: 0.4, alpha: 1)
            case .infoCurrentVersion:   return UIColor(hue: 0, saturation: 0, brightness: 0.4, alpha: 1)
            case .infoDownloadCount:    return UIColor(hue: 0, saturation: 0, brightness: 0.4, alpha: 1)
            case .linkName:             return UIColor(hue: 0, saturation: 0, brightness: 0.3, alpha: 1)
            case .linkValue:            return Style.defaultTintColor
            case .dependencyName:       return UIColor(hue: 0, saturation: 0, brightness: 0.3, alpha: 1)
            case .versionName:          return UIColor(hue: 0, saturation: 0, brightness: 0.3, alpha: 1)
            case .versionValue:         return UIColor(hue: 0, saturation: 0, brightness: 0.4, alpha: 1)
            }
        }
    }
    private func getFont() throws -> UIFont {
        enum Error: ErrorType {
        case missingFontFor(name: String, size: CGFloat)
        }
        func getFont(name name: String, size: CGFloat) throws -> UIFont {
            guard let font = UIFont(name: name, size: size) else { throw Error.missingFontFor(name: name, size: size) }
            return font
        }
        let CRATE_NAME_FONT_NAME = "DINCondensed-Bold"
        switch self {
        case let .crateList(substyle):
            switch substyle {
            case .itemName:             return try getFont(name: CRATE_NAME_FONT_NAME, size: 22)
            case .itemVersion:          return try getFont(name: "HelveticaNeue-Light", size: 12)
            case .itemDescription:      return try getFont(name: "HelveticaNeue", size: 12)
            }
        case let .crateInspector(substyle):
            switch substyle {
            case .titleName:            return try getFont(name: CRATE_NAME_FONT_NAME, size: 24)
            case .infoAuthor:           return try getFont(name: "HelveticaNeue-Light", size: 12)
            case .infoLicense:          return try getFont(name: "HelveticaNeue-Bold", size: 8)
            case .infoDescription:      return try getFont(name: "HelveticaNeue-Light", size: 16)
            case .infoCurrentVersion:   return try getFont(name: "HelveticaNeue-Light", size: 12)
            case .infoDownloadCount:    return try getFont(name: "HelveticaNeue-Light", size: 12)
            case .linkName:             return try getFont(name: "HelveticaNeue-Light", size: 16)
            case .linkValue:            return UIFont.systemFontOfSize(UIFont.labelFontSize())
            case .dependencyName:       return try getFont(name: CRATE_NAME_FONT_NAME, size: 16)
            case .versionName:          return try getFont(name: "HelveticaNeue-Light", size: 16)
            case .versionValue:         return try getFont(name: "HelveticaNeue-Light", size: 16)
            }
        }
    }
    private func getAlignment() -> NSTextAlignment {
        switch self {
        case let .crateList(substyle):
            switch substyle {
            case .itemName:             return .Left
            case .itemVersion:          return .Right
            case .itemDescription:      return .Natural // Must not be `Justified` to provide ending ellipsis.
            }
        case let .crateInspector(substyle):
            switch substyle {
            case .titleName:            return .Center
            case .infoAuthor:           return .Center
            case .infoLicense:          return .Center
            case .infoDescription:      return .Center
            case .infoCurrentVersion:   return .Center
            case .infoDownloadCount:    return .Center
            case .linkName:             return .Left
            case .linkValue:            return .Right
            case .dependencyName:       return .Left
            case .versionName:          return .Left
            case .versionValue:         return .Right
            }
        }
    }
    private func getLineBreakMode() -> NSLineBreakMode {
        switch self {
        case let .crateInspector(substyle):
            switch substyle {
            case .infoDescription:      return .ByCharWrapping
            default:                    return .ByTruncatingTail
            }
        default:                        return .ByTruncatingTail
        }
    }
}
extension NSAttributedString {
    private func foregroundColored(style: Style) -> NSAttributedString {
        return foregroundColored(style.getForegroundColor())
    }
    private func fonted(style: Style) throws -> NSAttributedString {
        return fonted(try style.getFont())
    }
    private func paragraphStyled(style: Style) -> NSAttributedString {
        let ps = NSMutableParagraphStyle()
        ps.alignment = style.getAlignment()
        ps.lineBreakMode = style.getLineBreakMode()
        ps.hyphenationFactor = 1
        return paragraphStyled(ps)
    }
    func stylized(style: Style) throws -> NSAttributedString {
        return try fonted(style).foregroundColored(style).paragraphStyled(style)
    }
    func stylizedSilently(style: Style) -> NSAttributedString? {
        return try? stylized(style)
    }
}









