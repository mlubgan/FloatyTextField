//
//  FloatyTextView.swift
//  FloatyControl
//
//  Created by Michał Łubgan on 22.09.2018.
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
    
    public var text: String? {
        set {
            textView.text = newValue
            isPlaceholderFloating = !(newValue ?? "").isEmpty
        }
        
        get {
            return textView.text
        }
    }
    
    /// RoundedTextView's delegate, set if user doesn't provide own delegate
    lazy var floatyTextViewDelegate: FloatyTextViewDelegate = {
        let floatyTextViewDelegate = FloatyTextViewDelegate()
        floatyTextViewDelegate.delegate = self
        return floatyTextViewDelegate
    }()
    
    // MARK: Inits
    public init(floatyPaddings: FloatyControlPaddings = .leading, cornerRadius: CGFloat) {
        super.init(inputField: textView, floatyPaddings: floatyPaddings, cornerRadius: cornerRadius)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Initial setup
    public func initialSetup(floatyPaddings: FloatyControlPaddings = .leading, cornerRadius: CGFloat) {
        setup(inputField: textView, floatyPaddings: floatyPaddings, cornerRadius: cornerRadius)
    }
    
    override func setup() {
        delegate = floatyTextViewDelegate
        textView.backgroundColor = .clear
        
        super.setup()
    }
    
    override func doLayout() {
        super.doLayout()
        
        placeholderLabel.snp.makeConstraints { (make) in
            let constraints = make.leading.trailing.top.equalTo(inputField).priority(750)
            placeholderConstraints = [constraints]
        }
        
        inputField.snp.makeConstraints { (make) in
            make.edges.equalTo(Constants.paddings)
        }
    }
    
}

// MARK: - Extension with Constants
private extension FloatyTextView {
    
    // MARK: - Constants
    struct Constants {
        
        private init() { }
        
        // MARK: - InputField and PlaceholderLabel Constants
        static let paddings = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
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

