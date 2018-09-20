//
//  RoundedTextField.swift
//  WeAreBikers
//
//  Created by Michał Łubgan on 28.08.2018.
//  Copyright © 2018 FiveDotTwelve sp. z o.o. All rights reserved.
//

import UIKit

public class FloatyLabel: FloatyControl {
    
    // MARK: - Properties
    public let label = UILabel()
    
    /// Label's text
    public var text: String? {
        get {
            return label.text
        }
        
        set {
            label.text = newValue
            updateBorder()
        }
    }
    
    // MARK: - Customization properties
    /// Label's number of lines
    public var labelNumberOfLines: Int = 1 {
        didSet {
            label.numberOfLines = labelNumberOfLines
        }
    }
    
    /// Label's font color
    public var labelFieldTextColor: UIColor? = BaseValues.textFieldColor {
        didSet {
            label.textColor = labelFieldTextColor
        }
    }
    
    /// Label's font
    public var labelFont: UIFont? = BaseValues.textFieldFont {
        didSet {
            label.font = labelFont
        }
    }
    
    // MARK: Inits
    public init(labelPaddings: UIEdgeInsets = FloatyControlConstants.textFieldPaddings, placeholderPaddings: FloatyControlPadding = .center) {
        super.init(inputField: label, inputPaddings: labelPaddings, placeholderPadding: placeholderPaddings)
        isPlaceholderFloating = true
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Initial setup
    public func initialSetup(labelPaddings: UIEdgeInsets = FloatyControlConstants.textFieldPaddings, placeholderPaddings: FloatyControlPadding = .center) {
        super.initialSetup(inputField: label, inputPaddings: labelPaddings, placeholderPadding: placeholderPaddings)
    }
    
    override func setup() {
        super.setup()
        isPlaceholderFloating = true
    }
    
}
