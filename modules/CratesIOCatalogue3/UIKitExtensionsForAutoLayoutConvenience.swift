//
//  UIKitExtensionsForAutoLayoutConvenience.swift
//  StackViewPlayground
//
//  Created by Hoon H. on 2016/06/17.
//  Copyright © 2016 Eonil. All rights reserved.
//

import UIKit

/// Designed only for convenience.
/// You cannot deinstall once installed constraints.
/// Anyway, installed constraints will be deinstalled automatically when the views die.
protocol PinnableViewType {
}
protocol OutlinePinnableViewType: PinnableViewType {
}

extension UIView: PinnableViewType {
}
extension UIScrollView: OutlinePinnableViewType {
}
extension UIStackView: OutlinePinnableViewType {
}

extension PinnableViewType where Self: UIView {
    private func prepare() {
        translatesAutoresizingMaskIntoConstraints = false
    }
    private func append(c: NSLayoutConstraint) {
        c.priority = UILayoutPriorityDefaultHigh
        c.active = true
    }
    private func isAncestor(view: UIView) -> Bool {
        if superview === view { return true }
        return superview?.isAncestor(view) ?? false
    }
    /// Just set `translatesAutoresizingMaskIntoConstraints = false`.
    func pin() {
        prepare()
    }
    func pinCenterAndSize() {
        pinCenter()
        pinSize()
    }
    func pinSize() {
        prepare()
        guard let superview = superview else { fatalError("This view cannot be pinned because there's no superview to pin onto.") }
        pinSizeTo(superview)
    }
    func pinCenter() {
        pinCenterX()
        pinCenterY()
    }
    func pinCenterX() {
        prepare()
        append(NSLayoutConstraint(item: self, attribute: .CenterX, relatedBy: .Equal, toItem: superview, attribute: .CenterX, multiplier: 1, constant: 0))
    }
    func pinCenterY() {
        prepare()
        append(NSLayoutConstraint(item: self, attribute: .CenterY, relatedBy: .Equal, toItem: superview, attribute: .CenterY, multiplier: 1, constant: 0))
    }
    /// Pins size to a view.
    /// - Parameter view: Must be one of ancestor views.
    func pinSizeTo(view: UIView) {
        assert(isAncestor(view))
        prepare()
        pinWidthTo(view)
        pinHeightTo(view)
    }
    /// Pins width to a view.
    /// - Parameter view: Must be one of ancestor views.
    func pinWidthTo(view: UIView, constant: CGFloat = 0) {
        assert(isAncestor(view))
        prepare()
        append(NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: constant))
    }
//    /// Pins width to be less than or equal to width of a view.
//    /// - Parameter view: Must be one of ancestor views.
//    func pinWidthLessThanOrEqualTo(view: UIView, constant: CGFloat = 0) {
//        assert(isAncestor(view))
//        prepare()
//        append(NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .LessThanOrEqual, toItem: view, attribute: .Width, multiplier: 1, constant: constant))
//    }
    /// Pins width to a view.
    /// - Parameter view: Must be one of ancestor views.
    func pinHeightTo(view: UIView, constant: CGFloat = 0) {
        assert(isAncestor(view))
        prepare()
        append(NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 1, constant: constant))
    }

    /// Pins size to a constant value.
    func pinSizeTo(width: CGFloat, _ height: CGFloat) {
        prepare()
        pinWidthTo(width)
        pinHeightTo(height)
    }
    /// Pins width to a constant value.
    func pinWidthTo(value: CGFloat) {
        prepare()
        append(NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: value))
    }
    /// Pins height to a constant value.
    func pinHeightTo(value: CGFloat) {
        prepare()
        append(NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: value))
    }
}
extension OutlinePinnableViewType where Self: UIView {

    /// Pins left-side on super-view's left-side.
    func pinLeft(displacement: CGFloat = 0) {
        prepare()
        append(NSLayoutConstraint(item: self, attribute: .Left, relatedBy: .Equal, toItem: superview, attribute: .Left, multiplier: 1, constant: displacement))
    }
    /// Pins right-side on super-view's right-side.
    func pinRight(displacement: CGFloat = 0) {
        prepare()
        append(NSLayoutConstraint(item: self, attribute: .Right, relatedBy: .Equal, toItem: superview, attribute: .Right, multiplier: 1, constant: displacement))
    }
    /// Pins top-side on super-view's top-side.
    func pinTop(displacement: CGFloat = 0) {
        prepare()
        append(NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: superview, attribute: .Top, multiplier: 1, constant: displacement))
    }
    /// Pins bottom-side on super-view's bottom-side.
    func pinBottom(displacement: CGFloat = 0) {
        prepare()
        append(NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: superview, attribute: .Bottom, multiplier: 1, constant: displacement))
    }
}










