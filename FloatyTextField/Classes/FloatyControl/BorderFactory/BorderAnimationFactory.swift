//
//  BorderAnimationFactory.swift
//  FloatyControl
//
//  Created by Michał Łubgan on 22.09.2018.
//  Copyright © 2018 Michał Łubgan. All rights reserved.
//

import UIKit

struct BorderAnimationFactory {

    // MARK: - Instance Methods
    /// Creates paths for animation
    func createBordersForAnimation(config: BorderFactoryConfig) -> BorderFactoryAnimationPaths {
        let containerWidth = config.containerSize.width
        let halfOfText = config.textSpace / 2
        let cornerRadius = config.cornerRadius
        let cornerRadiusConstant = acos((cornerRadius - FloatyConstants.leadingPadding) / cornerRadius)

        let centerX: CGFloat
        let topLeftPoint: CGFloat
        let topRightPoint: CGFloat

        switch config.floatyPaddings {
        case .center:
            centerX = containerWidth / 2
            topLeftPoint = (containerWidth - config.textSpace) / 2
            topRightPoint = (containerWidth + config.textSpace) / 2
        case .leading:
            topLeftPoint = config.cornerRadius
            topRightPoint = topLeftPoint + config.textSpace + 2 * config.sidePadding
            centerX = FloatyConstants.leadingPadding + config.sidePadding + halfOfText
        case .trailing:
            topRightPoint = containerWidth - config.cornerRadius - 2 * config.sidePadding
            topLeftPoint = topRightPoint - config.textSpace
            centerX = containerWidth - FloatyConstants.leadingPadding - config.sidePadding - halfOfText
        }

        let leftPath = UIBezierPath()
        let leadingCenterPoint = CGPoint(x: cornerRadius, y: cornerRadius)
        if config.floatyPaddings == .leading, !config.shouldDrawGap {
            leftPath.addArc(withCenter: leadingCenterPoint, radius: cornerRadius, startAngle: -CGFloat.pi + cornerRadiusConstant, endAngle: -(CGFloat.pi / 2), clockwise: true)
        }
        
        leftPath.move(to: CGPoint(x: config.shouldDrawGap ? centerX : topLeftPoint, y: 0))
        leftPath.addLine(to: CGPoint(x: config.shouldDrawGap ? topLeftPoint : centerX, y: 0))

        if config.floatyPaddings == .leading, config.shouldDrawGap {
            leftPath.addArc(withCenter: leadingCenterPoint, radius: cornerRadius, startAngle: -(CGFloat.pi / 2), endAngle: -CGFloat.pi + cornerRadiusConstant, clockwise: false)
        }
        
        let rightPath = UIBezierPath()
        rightPath.move(to: CGPoint(x: config.shouldDrawGap ? centerX : topRightPoint, y: 0))
        rightPath.addLine(to: CGPoint(x: config.shouldDrawGap ? topRightPoint : centerX, y: 0))

        let animationPaths = BorderFactoryAnimationPaths(leftPath: leftPath, rightPath: rightPath)
        return animationPaths
    }

}
