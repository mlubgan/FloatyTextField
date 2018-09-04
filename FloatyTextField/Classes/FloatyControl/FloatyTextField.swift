//
//  FloatyTextField.swift
//  FloatyTextField
//
//  Created by Michał Łubgan on 30.08.2018.
//  Copyright © 2018 Michał Łubgan. All rights reserved.
//

import UIKit

public class FloatyTextField: FloatyControl {

    // MARK: - Weak properties
    public weak var delegate: UITextFieldDelegate? {
        didSet {
            textField.delegate = delegate
        }
    }

    // MARK: - Properties
    let textField = UITextField()

    /// Textfield's text
    public var text: String? {
        return textField.text
    }
    
    // MARK: - Customization properties
    /// Textfield's font color
    public var textFieldTextColor: UIColor? = BaseValues.textFieldColor {
        didSet {
            textField.textColor = textFieldTextColor
        }
    }

    /// Textfield's font
    public var textFieldFont: UIFont? = BaseValues.textFieldFont {
        didSet {
            textField.font = textFieldFont
        }
    }

    // MARK: Inits
    public init(textFieldPaddings: UIEdgeInsets = FloatyControlConstants.textFieldPaddings, placeholderPadding: FloatyControlPadding = .center) {
        super.init(inputField: textField, inputPaddings: textFieldPaddings, placeholderPadding: placeholderPadding)
    }

    required convenience public init?(coder aDecoder: NSCoder) {
        self.init()
    }

    // MARK: - Initial setup
    override func setup() {
        textField.delegate = delegate
        textField.font = textFieldFont
        textField.textColor = textFieldTextColor
        textField.addTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)

        super.setup()
    }

}

// MARK: - UITextField events
extension FloatyTextField {

    /// Changes state on editing
    @objc func textFieldDidBeginEditing() {
        if !isPlaceholderFloating {
            isPlaceholderFloating = true
        }
    }

    /// Changes state on completion if needed
    @objc func textFieldDidEndEditing() {
        if textField.text?.isEmpty ?? true {
            isPlaceholderFloating = false
        }
    }

}
