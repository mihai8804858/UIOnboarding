//
//  UIOnboardingFeature.swift
//  UIOnboarding
//
//  Created by Lukman Aščić on 14.02.22.
//

import UIKit

public struct UIOnboardingFeature {
    public var icon: UIImage
    public var iconTint: UIColor
    public var title: NSAttributedString
    public var description: NSAttributedString

    public init(
        icon: UIImage,
        iconTint: UIColor = .label,
        title: NSAttributedString,
        description: NSAttributedString
    ) {
        self.icon = icon
        self.iconTint = iconTint
        self.title = title
        self.description = description
    }
}

public struct UIOnboardingFeatureStyle {
    public var spacing: CGFloat

    public init(spacing: CGFloat = 0.8) {
        self.spacing = spacing
    }
}
