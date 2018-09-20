//
//  FloatyTextView.swift
//  FloatyTextField
//
//  Created by Michał Łubgan on 30.08.2018.
//  Copyright © 2018 Michał Łubgan. All rights reserved.
//

import UIKit

open class FloatyTextViewDelegate: NSObject, UITextViewDelegate {
    
    weak var delegate: FloatyTextViewInternalDelegate?
    
    // Always call super method when overriding
    public func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.textViewDidEndEditing(textView)
    }
    
    // Always call super method when overriding
    public func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.textViewDidBeginEditing(textView)
    }
    
}

/// Implements only part of delegate methods, can be added if needed
protocol FloatyTextViewInternalDelegate: class {
    
    func textViewDidBeginEditing(_ textView: UITextView)
    func textViewDidEndEditing(_ textView: UITextView)
    
}

public class FloatyTextView: FloatyControl {

    // MARK: - Weak properties
    public weak var delegate: FloatyTextViewDelegate? {
        didSet {
            if delegate == nil {
                delegate = floatyTextViewDelegate
            }
            delegate?.delegate = self
            textView.delegate = delegate
        }
    }
    
    // MARK: - Properties
    public let textView = UITextView()
    
    /// RoundedTextView's delegate, set if user doesn't provide own delegate
    lazy var floatyTextViewDelegate: FloatyTextViewDelegate = {
        let floatyTextViewDelegate = FloatyTextViewDelegate()
        floatyTextViewDelegate.delegate = self
        return floatyTextViewDelegate
    }()
    
    /// TextView's text
    public var text: String? {
        get {
            return textView.text
        }
        
        set {
            isPlaceholderFloating = newValue != nil
            textView.text = newValue
        }
    }
    
    // MARK: - Customization properties
    /// TextView's font color
    public var textViewTextColor: UIColor? = BaseValues.textFieldColor {
        didSet {
            textView.textColor = textViewTextColor
        }
    }

    /// TextView's font
    public var textViewFont: UIFont? = BaseValues.textFieldFont {
        didSet {
            textView.font = textViewFont
        }
    }

    // MARK: Inits
    public init(textFieldPaddings: UIEdgeInsets = FloatyControlConstants.textFieldPaddings, placeholderPadding: FloatyControlPadding = .center) {
        super.init(inputField: textView, inputPaddings: textFieldPaddings, placeholderPadding: placeholderPadding)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Initial setup
    public func initialSetup(labelPaddings: UIEdgeInsets = FloatyControlConstants.textFieldPaddings, placeholderPaddings: FloatyControlPadding = .center) {
        super.initialSetup(inputField: textView, inputPaddings: labelPaddings, placeholderPadding: placeholderPaddings)
    }
    
    override func setup() {
        delegate = floatyTextViewDelegate
        textView.backgroundColor = .clear
        textView.font = textViewFont
        textView.textColor = textViewTextColor
        
        super.setup()
    }

}

// MARK: RoundedTextViewInternalDelegate
extension FloatyTextView: FloatyTextViewInternalDelegate {
    
    /// Changes the placeholder state on editing if needed
    func textViewDidBeginEditing(_ textView: UITextView) {
        if !isPlaceholderFloating {
            isPlaceholderFloating = true
        }
    }

    /// Changes the placeholder state on editing if needed
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text?.isEmpty ?? true {
            isPlaceholderFloating = false
        }
    }

}
