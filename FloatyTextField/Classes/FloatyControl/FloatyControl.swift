//
//  FloatyControl.swift
//  FloatyTextField
//
//  Created by Michał Łubgan on 28.08.2018.
//  Copyright © 2018 Michał Łubgan. All rights reserved.
//

import UIKit
import SnapKit

public class FloatyControl: UIControl {

    // MARK: - Views properties
    /// Should be overriden with UITextField or UITextView
    let inputField: UIView
    let placeholderLabel = UILabel()
    let borderView = UIView()

    // MARK: - Properties
    /// TextField paddings, placeholderLabel paddings are equal while textField is empty
    let inputPaddings: UIEdgeInsets
    /// Floating placeholder paddings
    let placeholderPadding: FloatyControlPadding
    /// Layer containing borderPath
    var borderLayer: CAShapeLayer?
    /// Layer containg leftPath for border animation
    var leftBorderLayer: CAShapeLayer?
    /// Layer containg rightPath for border animation
    var rightBorderLayer: CAShapeLayer?
    /// Determines whether placeholder is floating, on set toggles state
    var isPlaceholderFloating = false {
        didSet {
            isPlaceholderFloating ? setupFloatingPlaceholder(animated: true) : setupPlaceholder(animated: true)
        }
    }
    /// Provides superview's background color for border animation
    var superviewBackgroundColor: UIColor? {
        return superview?.backgroundColor
    }
    /// Determines whether view has called layoutSubviews
    var didCallLayoutSubviews = false

    // MARK: - Placeholder constraints
    /// Constraints for floating state
    var floatingPlaceholderConstraints = [ConstraintMakerFinalizable]()
    /// Constraints for normal state
    var placeholderConstraints = [ConstraintMakerFinalizable]()

    // MARK: - Customization properties
    /// Border color, default is darkGray
    public var borderColor: UIColor? = .darkGray {
        didSet {
            updateBorder()
        }
    }

    /// CornerRadius, default is 16
    public var cornerRadius: CGFloat = 16 {
        didSet {
            updateBorder()
        }
    }

    /// Placeholder text, updates border on set
    public var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
            updateBorder()
        }
    }

    /// Placeholder's font color
    public var placeholderTextColor: UIColor? = BaseValues.placeholderColor {
        didSet {
            placeholderLabel.textColor = placeholderTextColor
        }
    }

    /// Placeholder's font
    public var placeholderFont: UIFont? = BaseValues.placeholderFont {
        didSet {
            placeholderLabel.font = placeholderFont
        }
    }

    // MARK: - Inits
    init(inputField: UIView, inputPaddings: UIEdgeInsets, placeholderPadding: FloatyControlPadding) {
        self.inputField = inputField
        self.inputPaddings = inputPaddings
        self.placeholderPadding = placeholderPadding
        super.init(frame: .zero)
        setup()
    }

    required convenience public init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: - Initial setup
    func setup() {
        placeholderLabel.font = placeholderFont
        placeholderLabel.textColor = placeholderTextColor
        translatesAutoresizingMaskIntoConstraints = false
        doLayout()
    }

    func doLayout() {
        addSubview(borderView)
        let fontSize = placeholderFont?.pointSize ?? 15
        borderView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets(top: fontSize / 2, left: 0, bottom: 0, right: 0))
        }

        borderView.addSubview(inputField)
        inputField.snp.makeConstraints { (make) in
            make.edges.equalTo(inputPaddings)
        }
        setupPlaceholder(animated: false)
    }

    // MARK: - PlaceholderLabel layout
    /// Setups placeholder in textField's frame
    func setupPlaceholder(animated: Bool) {
        if placeholderLabel.superview == nil {
            borderView.addSubview(placeholderLabel)
        }

        if placeholderConstraints.isEmpty {
            makePlaceholderConstraints()
        }

        if animated {
            floatingPlaceholderConstraints.forEach({ $0.constraint.deactivate() })
            placeholderConstraints.forEach({ $0.constraint.activate() })
            let duration = FloatyControlConstants.floatingPlaceholderAnimationDuration
            let dampingRatio = FloatyControlConstants.floatingPlaceholderDampingRatio

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + FloatyControlConstants.borderAnimationDelay) { [weak self] in
                self?.animateBorder(completion: { [weak self] in
                    self?.updateBorder()
                })
            }

            UIView.animationQ.add(duration: duration, options: .curveEaseIn, dampingRatio: dampingRatio) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.borderView.layoutIfNeeded()
                strongSelf.placeholderLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
            }.start()
        } else {
            borderView.layoutIfNeeded()
            updateBorder()
        }
    }

    /// Creates placeholder constraints
    func makePlaceholderConstraints() {
        placeholderLabel.snp.makeConstraints { (make) in
            let constraint = make.edges.equalTo(inputPaddings).priority(750)
            placeholderConstraints.append(constraint)
        }
    }

    /// Setups floating placeholder
    func setupFloatingPlaceholder(animated: Bool) {
        if floatingPlaceholderConstraints.isEmpty, placeholderLabel.superview != nil {
            makeFloatingPlaceholderConstraints()
        }
        if animated {
            animateBorder {
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.placeholderConstraints.forEach({ $0.constraint.deactivate() })
                    strongSelf.floatingPlaceholderConstraints.forEach({ $0.constraint.activate() })
                    let duration = FloatyControlConstants.floatingPlaceholderAnimationDuration
                    let dampingRatio = FloatyControlConstants.floatingPlaceholderDampingRatio
                    UIView.animationQ.add(duration: duration, options: .curveEaseOut, dampingRatio: dampingRatio) { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.borderView.layoutIfNeeded()
                        let scale = FloatyControlConstants.floatingPlaceholderScale
                        strongSelf.placeholderLabel.transform = CGAffineTransform(scaleX: scale, y: scale)
                    }.done { [weak self] in
                        self?.updateBorder()
                    }.start()
                }
            }
        } else {
            borderView.layoutIfNeeded()
            updateBorder()
        }
    }

    /// Creates constraints for floating placeholder
    func makeFloatingPlaceholderConstraints() {
        placeholderLabel.snp.makeConstraints { (make) in
            switch placeholderPadding {
            case .center:
                let constraint = make.centerX.equalToSuperview().priority(750)
                floatingPlaceholderConstraints.append(constraint)
            case .leading(let padding):
                let sidePadding = FloatyControlConstants.floatingPlaceholderSidePadding
                let constraint = make.leading.equalTo(borderView.snp.leading).offset(cornerRadius + padding - 2 * sidePadding).priority(750)
                floatingPlaceholderConstraints.append(constraint)
            case .trailing(let padding):
                let sidePadding = FloatyControlConstants.floatingPlaceholderSidePadding
                let constraint = make.trailing.equalTo(borderView.snp.trailing).offset(-(cornerRadius + padding - 2 * sidePadding)).priority(750)
                floatingPlaceholderConstraints.append(constraint)
            }
            let constraint = make.centerY.equalTo(borderView.snp.top).priority(750)
            floatingPlaceholderConstraints.append(constraint)
        }
    }

    // MARK: - Setup actions
    /// Setups touch action
    func addTapAction() {
        isUserInteractionEnabled = true
        addTarget(self, action: #selector(didTapAction), for: .touchUpInside)
    }

    @objc func didTapAction() {
        inputField.becomeFirstResponder()
    }

    // MARK: - Instance methods
    /// TextField resignsFirstResponder
    override public func resignFirstResponder() -> Bool {
        return inputField.resignFirstResponder()
    }

    // MARK: - Lifecycle methods
    override public func layoutSubviews() {
        super.layoutSubviews()

        guard !didCallLayoutSubviews else { return }
        updateBorder()
        didCallLayoutSubviews = true
    }

}

// MARK: - Extension with struct containing UIBezierPaths for border animation
extension FloatyControl {

    /// Struct used for animating borders
    struct BezierPaths {

        let leftPath: UIBezierPath
        let rightPath: UIBezierPath

    }

}

// MARK: - Border setup methods
extension FloatyControl {

    /// Animates border
    func animateBorder(completion: (() -> Void)?) {
        let bezierPaths = prepareBorderPathForAnimation()

        let leftBorderLayer = CAShapeLayer()
        leftBorderLayer.path = bezierPaths.leftPath.cgPath
        self.leftBorderLayer = leftBorderLayer

        let rightBorderLayer = CAShapeLayer()
        rightBorderLayer.path = bezierPaths.rightPath.cgPath
        self.rightBorderLayer = rightBorderLayer

        for layer in [leftBorderLayer, rightBorderLayer] {
            layer.strokeColor = isPlaceholderFloating ? superviewBackgroundColor?.cgColor : (borderColor ?? .clear).cgColor
            layer.fillColor = UIColor.clear.cgColor
            layer.lineWidth = FloatyControlConstants.borderWidth
            layer.position = CGPoint.zero
            layer.strokeStart = 0
            layer.strokeEnd = 1
            borderView.layer.insertSublayer(layer, at: 1)

            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 0
            animation.toValue = 1
            animation.duration = FloatyControlConstants.borderAnimationDuration
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            animation.isRemovedOnCompletion = false
            layer.add(animation, forKey: "line")
        }

        let timeInterval = FloatyControlConstants.borderAnimationDelay
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + timeInterval) {
            completion?()
        }
    }

    /// Updates border
    func updateBorder() {
        let path = prepareBorderPath()
        let newBorderLayer = CAShapeLayer()
        newBorderLayer.path = path.cgPath
        newBorderLayer.strokeColor = (borderColor ?? .clear).cgColor
        newBorderLayer.fillColor = UIColor.clear.cgColor
        newBorderLayer.lineWidth = FloatyControlConstants.borderWidth
        newBorderLayer.position = CGPoint.zero
        borderView.layer.insertSublayer(newBorderLayer, at: 0)

        borderLayer?.removeFromSuperlayer()
        leftBorderLayer?.removeFromSuperlayer()
        rightBorderLayer?.removeFromSuperlayer()

        borderLayer = newBorderLayer
    }

    /// Draws borderPaths for animating border
    func prepareBorderPathForAnimation() -> BezierPaths {
        let borderViewWidth = borderView.frame.width
        let scale = FloatyControlConstants.floatingPlaceholderScale
        let sidePadding = FloatyControlConstants.floatingPlaceholderSidePadding
        let textSpace = placeholderLabel.systemLayoutSizeFitting(UILayoutFittingCompressedSize).width * scale
        let halfOfText = textSpace / 2

        let centerX: CGFloat

        switch placeholderPadding {
        case .center:
            centerX = borderViewWidth / 2
        case .leading(let padding):
            centerX = cornerRadius + padding + sidePadding + halfOfText
        case .trailing(let padding):
            centerX = borderViewWidth - cornerRadius - padding - sidePadding - halfOfText
        }

        let leftX = centerX - halfOfText - sidePadding
        let rightX = centerX + halfOfText + sidePadding

        let leftPath = UIBezierPath()
        leftPath.move(to: CGPoint(x: isPlaceholderFloating ? centerX : leftX, y: 0))
        leftPath.addLine(to: CGPoint(x: isPlaceholderFloating ? leftX : centerX, y: 0))

        let rightPath = UIBezierPath()
        rightPath.move(to: CGPoint(x: isPlaceholderFloating ? centerX : rightX, y: 0))
        rightPath.addLine(to: CGPoint(x: isPlaceholderFloating ? rightX : centerX, y: 0))

        let bezierPaths = BezierPaths(leftPath: leftPath, rightPath: rightPath)
        return bezierPaths
    }

    /// Draws borderPath
    func prepareBorderPath() -> UIBezierPath {
        let borderViewWidth = borderView.frame.width
        let borderViewHeight = borderView.frame.height
        let scale = FloatyControlConstants.floatingPlaceholderScale
        let sidePadding = FloatyControlConstants.floatingPlaceholderSidePadding
        let textSpace = placeholderLabel.systemLayoutSizeFitting(UILayoutFittingCompressedSize).width * scale

        let topLeftPoint: CGFloat
        let topRightPoint: CGFloat
        switch placeholderPadding {
        case .center:
            topLeftPoint = (borderViewWidth - textSpace) / 2 - sidePadding
            topRightPoint = topLeftPoint + textSpace + 2 * sidePadding
        case .leading(let padding):
            topLeftPoint = cornerRadius + padding
            topRightPoint = cornerRadius + padding + textSpace + 2 * sidePadding
        case .trailing(let padding):
            topRightPoint = borderViewWidth - cornerRadius - padding
            topLeftPoint = borderViewWidth - cornerRadius - padding - 2 * sidePadding - textSpace
        }

        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: cornerRadius, y: 0))
        if isPlaceholderFloating {
            bezierPath.addLine(to: CGPoint(x: topLeftPoint, y: 0))
            bezierPath.move(to: CGPoint(x: topRightPoint, y: 0))
        }
        bezierPath.addLine(to: CGPoint(x: borderViewWidth - cornerRadius, y: 0))
        let centerPoint1 = CGPoint(x: borderViewWidth - cornerRadius, y: cornerRadius)
        bezierPath.addArc(withCenter: centerPoint1, radius: cornerRadius, startAngle: -(CGFloat.pi / 2), endAngle: 0, clockwise: true)
        bezierPath.addLine(to: CGPoint(x: borderViewWidth, y: borderViewHeight - cornerRadius))
        let centerPoint2 = CGPoint(x: borderViewWidth - cornerRadius, y: borderViewHeight - cornerRadius)
        bezierPath.addArc(withCenter: centerPoint2, radius: cornerRadius, startAngle: 0, endAngle: -((CGFloat.pi * 3) / 2), clockwise: true)
        bezierPath.addLine(to: CGPoint(x: cornerRadius, y: borderViewHeight))
        let centerPoint3 = CGPoint(x: cornerRadius, y: borderViewHeight - cornerRadius)
        bezierPath.addArc(withCenter: centerPoint3, radius: cornerRadius, startAngle: -((CGFloat.pi * 3) / 2), endAngle: -CGFloat.pi, clockwise: true)
        bezierPath.addLine(to: CGPoint(x: 0, y: cornerRadius))
        let centerPoint4 = CGPoint(x: cornerRadius, y: cornerRadius)
        bezierPath.addArc(withCenter: centerPoint4, radius: cornerRadius, startAngle: -CGFloat.pi, endAngle: -(CGFloat.pi / 2), clockwise: true)

        return bezierPath
    }

}

// MARK: - Extension with base fonts and colors
extension FloatyControl {

    struct BaseValues {

        static let textFieldFont = UIFont.systemFont(ofSize: 15)
        static let textFieldColor = UIColor.black
        static let placeholderFont = UIFont.systemFont(ofSize: 15)
        static let placeholderColor = UIColor.darkGray

    }

}

// MARK: - Extension with Constants
extension FloatyControl {

    public struct FloatyControlConstants {

        private init() { }

        public static let textFieldPaddings = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        public static let borderWidth: CGFloat = 2
        public static let floatingPlaceholderAnimationDuration: TimeInterval = 0.3
        public static let borderAnimationDuration: TimeInterval = 0.175
        public static let borderAnimationDelay: TimeInterval = 0.05
        public static let floatingPlaceholderDampingRatio: CGFloat = 1.0
        public static let floatingPlaceholderScale: CGFloat = 0.75
        public static let floatingPlaceholderSidePadding: CGFloat = 4

    }

}
