//
//  UIOnboardingViewConfiguration.swift
//  UIOnboarding
//
//  Created by Lukman Aščić on 14.02.22.
//

import UIKit

public struct UIOnboardingViewConfiguration {
    public var appIcon: UIImage
    public var firstTitleLine: NSMutableAttributedString
    public var secondTitleLine: NSMutableAttributedString
    public var features: Array<UIOnboardingFeature>
    public let featureStyle: UIOnboardingFeatureStyle
    public var textViewConfiguration: UIOnboardingTextViewConfiguration? = nil
    public var buttonConfiguration: UIOnboardingButtonConfiguration
    public var backgroundColor: UIColor

    public init(appIcon: UIImage,
                firstTitleLine: NSMutableAttributedString,
                secondTitleLine: NSMutableAttributedString,
                features: Array<UIOnboardingFeature>,
                featureStyle: UIOnboardingFeatureStyle = .init(),
                textViewConfiguration: UIOnboardingTextViewConfiguration? = nil,
                buttonConfiguration: UIOnboardingButtonConfiguration,
                backgroundColor: UIColor = .systemBackground) {
        self.appIcon = appIcon
        self.firstTitleLine = firstTitleLine
        self.secondTitleLine = secondTitleLine
        self.features = features
        self.featureStyle = featureStyle
        self.textViewConfiguration = textViewConfiguration
        self.buttonConfiguration = buttonConfiguration
        self.backgroundColor = backgroundColor
    }
}
