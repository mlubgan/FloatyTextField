//
//  FloatyControl.swift
//  FloatyControl
//
//  Created by Michał Łubgan on 22.09.2018.
//  Copyright © 2018 Michał Łubgan. All rights reserved.
//

import UIKit
import SnapKit

public class FloatyControl: UIControl {

    // MARK: - Views Properties
    /// View with rounded border
    let borderView = UIView()
    /// Input, should be overriden with UITextField, UILabel or UITextView
    /// Should setup it's constraints in subclass
    var inputField: UIView!
    /// Label with placeholder, floating when typing
    /// Should setup it's constraints in subclass
    public let placeholderLabel = UILabel()
    /// Indicates floating state paddings - placeholderLabel horizontal alignment
    var floatyPaddings: FloatyControlPaddings!
    /// Corner Radius
    var cornerRadius: CGFloat!
    /// Config used for drawing borders and animating them
    var borderFactoryConfig: BorderFactoryConfig {
        let containerSize = borderView.frame.size
        let scale = Constants.floatingPlaceholderScale
        let textSpace = placeholderLabel.systemLayoutSizeFitting(UILayoutFittingCompressedSize).width * scale
        let sidePadding = Constants.sidePadding

        let config = BorderFactoryConfig(containerSize: containerSize,
            floatyPaddings: floatyPaddings,
            textSpace: textSpace,
            cornerRadius: cornerRadius,
            sidePadding: sidePadding,
            shouldDrawGap: isPlaceholderFloating)

        return config
    }

    // MARK: - Properties
    /// Layer containing borderPath
    var borderLayer: CAShapeLayer?
    /// Layer containg leftPath for border animation
    var leftBorderLayer: CAShapeLayer?
    /// Layer containg rightPath for border animation
    var rightBorderLayer: CAShapeLayer?
    /// Placeholder not-floating constraints
    var placeholderConstraints: [ConstraintMakerFinalizable]?
    /// Placeholder floating constraints
    var placeholderFloatingConstraints: [ConstraintMakerFinalizable]?
    /// Indicates whether border has been already set up
    var didSetupBorder = false
    /// Indicates whether setup has been already called
    var didCallSetup = false
    /// Indicates whether placeholder is currently floating
    var isPlaceholderFloating = false {
        didSet {
            isPlaceholderFloating ? setupFloatingPlaceholder(animated: true) : setupNonFloatingPlaceholder(animated: true)
        }
    }
    /// Provides superview's background color for border animation
    var superviewBackgroundColor: UIColor? {
        return superview?.backgroundColor
    }

    // MARK: - Customization properties
    /// Border color, default is darkGray
    public var borderColor: UIColor = .darkGray {
        didSet {
            updateBorder()
        }
    }

    /// Called before changing placeholder's state to floating
    public var willAnimateFloatingPlaceholder: ((FloatyControl) -> Void)?
    /// Called before changing placeholder's state to normal
    public var willAnimatePlaceholder: ((FloatyControl) -> Void)?

    // MARK: - Inits
    init(inputField: UIView, floatyPaddings: FloatyControlPaddings, cornerRadius: CGFloat) {
        super.init(frame: .zero)
        setup(inputField: inputField, floatyPaddings: floatyPaddings, cornerRadius: cornerRadius)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Setup Methods
    /// Setups properties
    func setup(inputField: UIView, floatyPaddings: FloatyControlPaddings, cornerRadius: CGFloat) {
        didCallSetup = true
        self.inputField = inputField
        self.floatyPaddings = floatyPaddings
        self.cornerRadius = cornerRadius

        setup()
    }

    /// Setups views
    func setup() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false

        doLayout()
    }

    /// Creates constraints for views
    func doLayout() {
        borderView.snp.removeConstraints()
        placeholderLabel.snp.removeConstraints()
        inputField.snp.removeConstraints()

        if borderView.superview == nil {
            addSubview(borderView)
        }

        borderView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        if inputField.superview == nil {
            addSubview(inputField)
        }

        if placeholderLabel.superview == nil {
            addSubview(placeholderLabel)
        }

        makeFloatingPlaceholderConstraints()
    }

    /// Creates constraints for floating state of placeholderLabel
    func makeFloatingPlaceholderConstraints() {
        placeholderLabel.snp.makeConstraints { (make) in
            let horizontalConstraint: ConstraintMakerFinalizable

            switch floatyPaddings {
            case .some(.leading):
                horizontalConstraint = make.leading.equalToSuperview().offset(FloatyConstants.leadingPadding * Constants.floatingPlaceholderScale).priority(750)
            case .some(.center):
                horizontalConstraint = make.centerX.equalToSuperview().priority(750)
            case .some(.trailing):
                horizontalConstraint = make.trailing.equalToSuperview().offset(-FloatyConstants.leadingPadding * Constants.floatingPlaceholderScale).priority(750)
            case .none:
                fatalError("Floaty paddings should be specified")
            }

            let verticalConstraint = make.centerY.equalTo(borderView.snp.top).priority(750)
            placeholderFloatingConstraints = [horizontalConstraint, verticalConstraint]
        }
        placeholderFloatingConstraints?.forEach({ $0.constraint.deactivate() })
    }

    // MARK: - Instance Methods
    /// TextField resignsFirstResponder
    public override func resignFirstResponder() -> Bool {
        return inputField.resignFirstResponder()
    }
    
    /// Updates border
    public func updateBorder() {
        guard didCallSetup else { return }
        
        let borderFactory = BorderFactory()
        let borderBezierPath = borderFactory.createBorder(config: borderFactoryConfig)
        
        let newBorderLayer = setupShapeLayer()
        newBorderLayer.strokeColor = borderColor.cgColor
        newBorderLayer.path = borderBezierPath.cgPath
        borderView.layer.insertSublayer(newBorderLayer, at: 0)
        
        borderLayer?.removeFromSuperlayer()
        leftBorderLayer?.removeFromSuperlayer()
        rightBorderLayer?.removeFromSuperlayer()
        
        borderLayer = newBorderLayer
    }

    // MARK: - Lifecycle methods
    public override func layoutSubviews() {
        super.layoutSubviews()

        guard !didSetupBorder, didCallSetup else { return }
        updateBorder()
        didSetupBorder = true
    }

}

// MARK: - Extension with methods changing state of placeholder
extension FloatyControl {

    func setupFloatingPlaceholder(animated: Bool) {
        willAnimateFloatingPlaceholder?(self)
        
        let config = borderFactoryConfig
        
        if animated {
            animateBorder(config: config) {
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.placeholderConstraints?.forEach({ $0.constraint.deactivate() })
                    strongSelf.placeholderFloatingConstraints?.forEach({ $0.constraint.activate() })

                    let duration = Constants.floatingPlaceholderAnimationDuration
                    let dampingRatio = Constants.floatingPlaceholderDampingRatio

                    UIView.animationQ.add(duration: duration, options: .curveEaseOut, dampingRatio: dampingRatio) { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.borderView.layoutIfNeeded()
                        let scale = Constants.floatingPlaceholderScale
                        strongSelf.placeholderLabel.transform = CGAffineTransform(scaleX: scale, y: scale)
                    }.done { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.updateBorder()
                    }.start()
                }
            }
        } else {
            placeholderConstraints?.forEach({ $0.constraint.deactivate() })
            placeholderFloatingConstraints?.forEach({ $0.constraint.activate() })
            updateViews()
        }
    }

    func setupNonFloatingPlaceholder(animated: Bool) {
        let config = borderFactoryConfig
        
        willAnimatePlaceholder?(self)

        placeholderFloatingConstraints?.forEach({ $0.constraint.deactivate() })
        placeholderConstraints?.forEach({ $0.constraint.activate() })
        
        if animated {
            let duration = Constants.floatingPlaceholderAnimationDuration
            let dampingRatio = Constants.floatingPlaceholderDampingRatio

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Constants.borderAnimationDelay) { [weak self] in
                self?.animateBorder(config: config, completion: { [weak self] in
                    self?.updateBorder()
                })
            }

            UIView.animationQ.add(duration: duration, options: .curveEaseIn, dampingRatio: dampingRatio) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.borderView.layoutIfNeeded()
                strongSelf.placeholderLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
            }.start()
        } else {
            updateViews()
        }
    }

    func updateViews() {
        borderView.layoutIfNeeded()
        updateBorder()
    }

}

// MARK: - Extension with method making deafault setup of CAShapeLayers
extension FloatyControl {

    func setupShapeLayer() -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = Constants.borderWidth
        shapeLayer.position = CGPoint.zero

        return shapeLayer
    }

}

// MARK: - Extension with animateBorder Method
extension FloatyControl {

    func animateBorder(config: BorderFactoryConfig, completion: (() -> Void)?) {
        let borderAnimationFactory = BorderAnimationFactory()
        let animationPaths = borderAnimationFactory.createBordersForAnimation(config: borderFactoryConfig)

        let leftBorderLayer = setupShapeLayer()
        leftBorderLayer.path = animationPaths.leftPath.cgPath
        self.leftBorderLayer = leftBorderLayer

        let rightBorderLayer = setupShapeLayer()
        rightBorderLayer.path = animationPaths.rightPath.cgPath
        self.rightBorderLayer = rightBorderLayer
        
        [leftBorderLayer, rightBorderLayer].forEach { (layer) in
            layer.strokeColor = isPlaceholderFloating ? superviewBackgroundColor?.cgColor : borderColor.cgColor
            layer.strokeStart = 0
            layer.strokeEnd = 1
            borderView.layer.insertSublayer(layer, at: 1)

            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 0
            animation.toValue = 1
            animation.duration = Constants.borderAnimationDuration
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            animation.isRemovedOnCompletion = false
            layer.add(animation, forKey: "line")
        }
        let timeInterval = Constants.borderAnimationDelay
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + timeInterval) {
            completion?()
        }
    }

}

// MARK: - Extension with constants
private extension FloatyControl {

    // MARK: - Constants
    struct Constants {

        private init() { }

        // MARK: BorderLayer Constants
        static let borderWidth: CGFloat = 2
        static let sidePadding: CGFloat = 0

        // MARK: - BorderAnimation Constants
        static let borderAnimationDuration: TimeInterval = 0.175
        static let borderAnimationDelay: TimeInterval = 0.05

        // MARK: - FloatingPlaceholder animation Constants
        static let floatingPlaceholderAnimationDuration: TimeInterval = 0.3
        static let floatingPlaceholderDampingRatio: CGFloat = 1.0
        static let floatingPlaceholderScale: CGFloat = 0.75

    }

}
