//
//  BorderFactoryConfig.swift
//  FloatyControl
//
//  Created by Michał Łubgan on 22.09.2018.
//  Copyright © 2018 Michał Łubgan. All rights reserved.
//

import UIKit

struct BorderFactoryConfig {
    
    // MARK: - Properties
    /// Size of container
    let containerSize: CGSize
    /// Type of floatyPaddings
    let floatyPaddings: FloatyControlPaddings
    /// Space used by text, top gap
    let textSpace: CGFloat
    /// Corner Radius of border
    let cornerRadius: CGFloat
    /// Side padding, added to gap
    let sidePadding: CGFloat
    /// Indicates whether should draw the gap
    let shouldDrawGap: Bool
    
}
