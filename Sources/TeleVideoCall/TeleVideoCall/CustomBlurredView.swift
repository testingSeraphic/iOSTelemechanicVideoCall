//
//  CustomBlurredView.swift
//  VideoCall
//
//  Created by Manpreet Singh on 23/10/24.
//

import UIKit

class CustomBlurredView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // create container view
        let containerView = UIView(frame: self.bounds)
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // create custom blur view
        let blurEffect = UIBlurEffect(style: .systemThickMaterialDark)
        let customBlurEffectView = CustomVisualEffectView(effect: blurEffect, intensity: 0.3)
        customBlurEffectView.frame = containerView.bounds
        customBlurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // create semi-transparent black view
        let dimmedView = UIView(frame: containerView.bounds)
        let darkerGray = UIColor(red: 70/255.0, green: 70/255.0, blue: 70/255.0, alpha: 0.6)
        dimmedView.backgroundColor = darkerGray
        dimmedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // add both as subviews
        containerView.addSubview(customBlurEffectView)
        containerView.addSubview(dimmedView)

        // add container view to the main view
        self.addSubview(containerView)
    }
}

final class CustomVisualEffectView: UIVisualEffectView {
    /// Create visual effect view with given effect and its intensity
    ///
    /// - Parameters:
    ///   - effect: visual effect, eg UIBlurEffect(style: .dark)
    ///   - intensity: custom intensity from 0.0 (no effect) to 1.0 (full effect) using linear scale
    init(effect: UIVisualEffect, intensity: CGFloat) {
        theEffect = effect
        customIntensity = intensity
        super.init(effect: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { nil }
    
    deinit {
        animator?.stopAnimation(true)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        effect = nil
        animator?.stopAnimation(true)
        animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [unowned self] in
            self.effect = theEffect
        }
        animator?.fractionComplete = customIntensity
    }
    
    private let theEffect: UIVisualEffect
    private let customIntensity: CGFloat
    private var animator: UIViewPropertyAnimator?
}
