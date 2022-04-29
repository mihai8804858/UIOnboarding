//
//  UIOnboardingViewController.swift
//  UIOnboarding Demo
//
//  Created by Lukman Aščić on 14.02.22.
//

import UIKit

final class UIOnboardingViewController: UIViewController {
    private var onboardingScrollView: UIScrollView!
    private var onboardingStackView: UIOnboardingStack!
    private var onboardingStackViewWidth: NSLayoutConstraint!
    
    private var topOverlayView: UIOnboardingOverlay!
    private var bottomOverlayView: UIOnboardingOverlay!
    
    private var continueButton: UIOnboardingButton!
    private var continueButtonWidth: NSLayoutConstraint!
    private var continueButtonHeight: NSLayoutConstraint!
    private var continueButtonBottom: NSLayoutConstraint!
    
    private var onboardingTextView: UIOnboardingTextView!

    private lazy var statusBarHeight: CGFloat = getStatusBarHeight()
        
    private func enoughSpaceToShowFullList() -> Bool {
        let onboardingStackHeight: CGFloat = onboardingStackView.frame.height
        let availableSpace: CGFloat = (view.frame.height -
                                       bottomOverlayView.frame.height -
                                       view.safeAreaInsets.bottom -
                                       onboardingScrollView.contentInset.top +
                                       (traitCollection.horizontalSizeClass == .regular ? 48 : 12))
        return onboardingStackHeight > availableSpace
    }
    private var overlayIsHidden: Bool = false
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    private let configuration: UIOnboardingViewConfiguration
    private let device: UIDevice
    weak var delegate: UIOnboardingViewControllerDelegate?
    
    init(withConfiguration configuration: UIOnboardingViewConfiguration, device: UIDevice = .current) {
        self.configuration = configuration
        self.device = device
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("UIOnboardingViewController: deinit {}")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isUserInteractionEnabled = false
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureScrollView()
        setUpTopOverlay()
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startOnboardingAnimation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateUI()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        onboardingStackView.onboardingTitleLabel.font = .systemFont(ofSize: traitCollection.horizontalSizeClass == .regular ? 80 : (UIScreenType.isiPhoneSE || UIScreenType.isiPhone6s ? 41 : 44), weight: .heavy)

        continueButtonHeight.constant = UIFontMetrics.default.scaledValue(for: traitCollection.horizontalSizeClass == .regular ? 50 : (UIScreenType.isiPhoneSE ? 48 : 52))
        continueButton.titleLabel?.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: traitCollection.horizontalSizeClass == .regular ? 19 : 17, weight: .bold))
        
        if #available(iOS 15.0, *) {
            onboardingTextView.font =  UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: traitCollection.horizontalSizeClass == .regular ? 15 : 13))
            onboardingTextView.maximumContentSizeCategory = .accessibilityMedium
        } else {
            onboardingTextView.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: traitCollection.horizontalSizeClass == .regular ? 15 : 13), maximumPointSize: traitCollection.horizontalSizeClass == .regular ? 21 : 19)
        }
        onboardingTextView.layoutIfNeeded()
        continueButton.layoutIfNeeded()
    }
}

extension UIOnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollViewHeight = scrollView.frame.size.height
        let scrollContentSizeHeight = scrollView.contentSize.height
        let scrollOffset = scrollView.contentOffset.y

        var viewOverlapsWithOverlay: Bool {
            return scrollOffset >= -(self.statusBarHeight / 1.5)
        }
        UIView.animate(withDuration: 0.21) {
            self.topOverlayView.alpha = viewOverlapsWithOverlay ? 1 : 0
        }

        var hasReachedBottom: Bool {
            return scrollOffset + scrollViewHeight >= scrollContentSizeHeight + bottomOverlayView.frame.height + view.safeAreaInsets.bottom
        }

        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.21) {
                self.bottomOverlayView.blurEffectView.effect = hasReachedBottom ? nil : UIBlurEffect.init(style: .regular)
                self.overlayIsHidden = hasReachedBottom
            }
        }
    }
}

extension UIOnboardingViewController {
    func configureScrollView() {
        onboardingScrollView = .init(frame: .zero)
        onboardingScrollView.delegate = self
        
        onboardingScrollView.isScrollEnabled = false
        onboardingScrollView.showsHorizontalScrollIndicator = false
        onboardingScrollView.backgroundColor = .systemGroupedBackground
        onboardingScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(onboardingScrollView)
        pin(onboardingScrollView, toEdgesOf: view)
        
        setUpOnboardingStackView()
        setUpBottomOverlay()
    }
    
    func setUpOnboardingStackView() {
        onboardingStackView = .init(withConfiguration: configuration)
        onboardingScrollView.addSubview(onboardingStackView)
        
        onboardingStackView.topAnchor.constraint(equalTo: onboardingScrollView.topAnchor).isActive = true
        onboardingStackView.bottomAnchor.constraint(equalTo: onboardingScrollView.bottomAnchor).isActive = true
        
        onboardingStackViewWidth = onboardingStackView.widthAnchor.constraint(equalToConstant: traitCollection.horizontalSizeClass == .regular ? 480 : view.frame.width - (UIScreenType.setUpPadding() * 2))
        onboardingStackViewWidth.isActive = true
        onboardingStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

    func setUpTopOverlay() {
        topOverlayView = .init(frame: .zero)
        view.addSubview(topOverlayView)
        
        topOverlayView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        topOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        topOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topOverlayView.heightAnchor.constraint(equalToConstant: getStatusBarHeight()).isActive = true
    }

    func setUpBottomOverlay() {
        bottomOverlayView = .init(frame: .zero)
        view.addSubview(bottomOverlayView)
        
        bottomOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bottomOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        
        setUpOnboardingButton()
        setUpOnboardingTextView()
    }

    func setUpOnboardingButton() {
        continueButton = .init(withConfiguration: configuration.buttonConfiguration)
        continueButton.delegate = self
        bottomOverlayView.addSubview(continueButton)
        
        continueButtonBottom = continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: traitCollection.horizontalSizeClass == .regular ? -60 : -40)
        continueButtonBottom.isActive = true
        
        continueButtonWidth = continueButton.widthAnchor.constraint(equalToConstant: traitCollection.horizontalSizeClass == .regular ? 340 : view.frame.width - (UIScreenType.setUpPadding() * 2))
        continueButtonWidth.isActive = true
        
        continueButton.centerXAnchor.constraint(equalTo: onboardingStackView.centerXAnchor).isActive = true
        
        continueButtonHeight = continueButton.heightAnchor.constraint(equalToConstant: UIFontMetrics.default.scaledValue(for: traitCollection.horizontalSizeClass == .regular ? 50 : UIScreenType.isiPhoneSE ? 48 : 52))
        continueButtonHeight.isActive = true
    }
    
    func setUpOnboardingTextView() {
        onboardingTextView = .init(withConfiguration: configuration.textViewConfiguration)
        bottomOverlayView.addSubview(onboardingTextView)
        
        onboardingTextView.bottomAnchor.constraint(equalTo: continueButton.topAnchor).isActive = true
        onboardingTextView.leadingAnchor.constraint(equalTo: continueButton.leadingAnchor).isActive = true
        onboardingTextView.trailingAnchor.constraint(equalTo: continueButton.trailingAnchor).isActive = true
        onboardingTextView.topAnchor.constraint(equalTo: bottomOverlayView.topAnchor, constant: 16).isActive = true
    }
    
    func startOnboardingAnimation() {
        UIView.animate(withDuration: UIAccessibility.isReduceMotionEnabled ? 0.8 : 1.533, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.6, options: .curveEaseInOut) {
            self.onboardingStackView.transform = .identity
            self.onboardingStackView.alpha = 1
        } completion: { (_) in
            self.onboardingStackView.animate {
                self.bottomOverlayView.alpha = 1
                self.onboardingScrollView.isScrollEnabled = true
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
    func updateUI() {
        onboardingScrollView.contentInset = .init(top: traitCollection.horizontalSizeClass == .regular ? 140 - getStatusBarHeight() : UIScreenType.setUpTopSpacing(),
                                                  left: 0,
                                                  bottom: bottomOverlayView.frame.height + view.safeAreaInsets.bottom,
                                                  right: 0)
        onboardingScrollView.scrollIndicatorInsets = .init(top: 0,
                                                           left: 0,
                                                           bottom: bottomOverlayView.frame.height - view.safeAreaInsets.bottom,
                                                           right: 0)
        
        let isIpadPro: Bool = max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height) > 1024
                    
        onboardingStackViewWidth.constant = traitCollection.horizontalSizeClass == .regular ? 480 : (traitCollection.horizontalSizeClass == .compact && view.frame.width == 320 ? view.frame.width - 60 : (isIpadPro && traitCollection.horizontalSizeClass == .compact && view.frame.width == 639 ? 340 : view.frame.width - (UIScreenType.setUpPadding() * 2)))
        
        continueButtonBottom.constant = traitCollection.horizontalSizeClass == .regular || (isIpadPro && traitCollection.horizontalSizeClass == .compact && view.frame.width == 639) ? -60 : -40
        
        continueButtonWidth.constant = traitCollection.horizontalSizeClass == .regular ? 340 : (traitCollection.horizontalSizeClass == .compact && view.frame.width == 320 ? view.frame.width - 60 : (isIpadPro && traitCollection.horizontalSizeClass == .compact && view.frame.width == 639 ? 300 : view.frame.width - (UIScreenType.setUpPadding() * 2)))
                
        view.layoutIfNeeded()
        bottomOverlayView.subviews.first?.alpha = enoughSpaceToShowFullList() ? 1 : 0
        onboardingScrollView.isScrollEnabled = enoughSpaceToShowFullList()
        onboardingScrollView.showsVerticalScrollIndicator = enoughSpaceToShowFullList()
        
        continueButton.layoutIfNeeded()
        continueButton.sizeToFit()
        
        UIView.performWithoutAnimation {
            onboardingStackView.featuresList.beginUpdates()
            onboardingStackView.featuresList.endUpdates()
        }
        onboardingStackView.layoutIfNeeded()
        onboardingStackView.onboardingTitleLabel.setLineHeight(lineHeight: 0.9)

        if !overlayIsHidden {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.21) {
                    self.bottomOverlayView.blurEffectView.effect = self.enoughSpaceToShowFullList() ? UIBlurEffect.init(style: .regular) : nil
                }
            }
        }
    }
}

extension UIOnboardingViewController: UIOnboardingButtonDelegate {
    func didPressContinueButton() {
        delegate?.didFinishOnboarding(onboardingViewController: self)
    }
}
