//
//  FloatyTextField.swift
//  FloatyControl
//
//  Created by Michał Łubgan on 22.09.2018.
//  Copyright © 2018 Michał Łubgan. All rights reserved.
//

import UIKit

public class FloatyPasswordField: FloatyTextField {

    // MARK: - Public Properties
    public var secureImage: UIImage? {
        didSet {
            set(secure: isSecure)
        }
    }

    public var insecureImage: UIImage? {
        didSet {
            set(secure: isSecure)
        }
    }

    // MARK: - Properties
    private lazy var rightButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(nil, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        return button
    }()

    var isSecure: Bool {
        return textField.isSecureTextEntry
    }

    // MARK: - Setup Methods
    override func setup() {
        super.setup()

        let textFieldSelector = #selector(didChangeText)
        textField.addTarget(self, action: textFieldSelector, for: .editingChanged)
        
        prepareRightView()
        
        textField.isSecureTextEntry = true
        set(secure: isSecure)
    }
    
    private func prepareRightView() {
        textField.rightView = rightButton
        
        guard let rightView = textField.rightView else { return }
        rightView.snp.makeConstraints { (make) in
            make.size.equalTo(Constants.rightButtonSize)
        }
    }

    private func set(secure: Bool) {
        let image = secure ? secureImage : insecureImage
        rightButton.setImage(image, for: .normal)
        
        textField.isSecureTextEntry = secure
    }

    // MARK: - Instance Methods
    @objc private func didTapButton() {
        set(secure: !isSecure)
    }
    
    @objc private func didChangeText() {
        let isEmpty = textField.text?.isEmpty ?? true
        textField.rightViewMode = isEmpty ? .never : .always
        textField.layoutIfNeeded()
    }

}

// MARK: - Extension with SecurityState
private extension FloatyPasswordField {

    enum SecurityState {

        case secure
        case insecure

    }

}

// MARK: - Extension with Constants
private extension FloatyPasswordField {

    struct Constants {

        private init() { }

        // MARK: - RightButton's Constants
        static let rightButtonSize = CGSize(width: 24, height: 24)
        
    }

}
