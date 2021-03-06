//
//  FloatyTextField.swift
//  FloatyControl
//
//  Created by Michał Łubgan on 22.09.2018.
//  Copyright © 2018 Michał Łubgan. All rights reserved.
//

import UIKit

public class FloatyTextField: FloatyControl {

    // MARK: - Properties
    public let textField = UITextField()

    public var text: String? {
        set {
            textField.text = newValue
            isPlaceholderFloating = !(newValue ?? "").isEmpty
        }

        get {
            return textField.text
        }
    }

    // MARK: - Inits
    public init(floatyPaddings: FloatyControlPaddings = .leading, cornerRadius: CGFloat) {
        super.init(inputField: textField, floatyPaddings: floatyPaddings, cornerRadius: cornerRadius)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Setup Methods
    public func initialSetup(floatyPaddings: FloatyControlPaddings = .leading, cornerRadius: CGFloat) {
        setup(inputField: textField, floatyPaddings: floatyPaddings, cornerRadius: cornerRadius)
    }

    override func setup() {
        super.setup()
        
        textField.tintColor = .black
        textField.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        textField.addTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
    }

    override func doLayout() {
        super.doLayout()

        placeholderLabel.snp.makeConstraints { (make) in
            let constraints = make.leading.top.equalTo(Constants.paddings).priority(750)
            placeholderConstraints = [constraints]
        }

        inputField.snp.makeConstraints { (make) in
            make.edges.equalTo(Constants.paddings)
        }
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

// MARK: - Extension with Constants
private extension FloatyTextField {

    // MARK: - Constants
    struct Constants {

        private init() { }

        // MARK: - InputField and PlaceholderLabel Constants
        static let paddings = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

    }

}
