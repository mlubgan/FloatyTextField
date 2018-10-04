//
//  FloatyLabel.swift
//  FloatyControl
//
//  Created by Michał Łubgan on 22.09.2018.
//  Copyright © 2018 Michał Łubgan. All rights reserved.
//

import UIKit

public class FloatyLabel: FloatyControl {

    // MARK: - Properties
    public let label = UILabel()

    // MARK: - Inits
    public init(floatyPaddings: FloatyControlPaddings = .leading, cornerRadius: CGFloat) {
        super.init(inputField: label, floatyPaddings: floatyPaddings, cornerRadius: cornerRadius)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Setup Methods
    public func initialSetup(floatyPaddings: FloatyControlPaddings = .leading, cornerRadius: CGFloat) {
        setup(inputField: label, floatyPaddings: floatyPaddings, cornerRadius: cornerRadius)
    }
    
    override func setup() {
        super.setup()

        isPlaceholderFloating = true
    }

    override func doLayout() {
        super.doLayout()

        placeholderLabel.snp.makeConstraints { (make) in
            let constraints = make.leading.top.trailing.equalTo(Constants.paddings).priority(750)
            placeholderConstraints = [constraints]
        }

        inputField.snp.makeConstraints { (make) in
            make.edges.equalTo(Constants.paddings)
        }
    }

}

// MARK: - Extension with Constants
private extension FloatyLabel {

    // MARK: - Constants
    struct Constants {

        private init() { }
        
        // MARK: - InputField and PlaceholderLabel Constants
        static let paddings = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

    }

}
