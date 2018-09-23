//
//  BorderFactory.swift
//  FloatyControl
//
//  Created by Michał Łubgan on 22.09.2018.
//  Copyright © 2018 Michał Łubgan. All rights reserved.
//

import UIKit

struct BorderFactory {

    // MARK: - Instance Methods
    /// Creates bezier path with border
    func createBorder(config: BorderFactoryConfig) -> UIBezierPath {
        let containerWidth = config.containerSize.width
        let containerHeight = config.containerSize.height
        let cornerRadius = config.cornerRadius
        
        let gapPoints = findEdgePoints(config: config)
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: cornerRadius, y: 0))
        if config.shouldDrawGap {
            bezierPath.addLine(to: CGPoint(x: gapPoints.left, y: 0))
            bezierPath.move(to: CGPoint(x: gapPoints.right, y: 0))
        }
        bezierPath.addLine(to: CGPoint(x: containerWidth - cornerRadius, y: 0))
        let centerPoint1 = CGPoint(x: containerWidth - cornerRadius, y: cornerRadius)
        bezierPath.addArc(withCenter: centerPoint1, radius: cornerRadius, startAngle: -(CGFloat.pi / 2), endAngle: 0, clockwise: true)
        bezierPath.addLine(to: CGPoint(x: containerWidth, y: containerHeight - cornerRadius))
        let centerPoint2 = CGPoint(x: containerWidth - cornerRadius, y: containerHeight - cornerRadius)
        bezierPath.addArc(withCenter: centerPoint2, radius: cornerRadius, startAngle: 0, endAngle: -((CGFloat.pi * 3) / 2), clockwise: true)
        bezierPath.addLine(to: CGPoint(x: cornerRadius, y: containerHeight))
        let centerPoint3 = CGPoint(x: cornerRadius, y: containerHeight - cornerRadius)
        bezierPath.addArc(withCenter: centerPoint3, radius: cornerRadius, startAngle: -((CGFloat.pi * 3) / 2), endAngle: -CGFloat.pi, clockwise: true)
        bezierPath.addLine(to: CGPoint(x: 0, y: cornerRadius))
        let centerPoint4 = CGPoint(x: cornerRadius, y: cornerRadius)
        bezierPath.addArc(withCenter: centerPoint4, radius: cornerRadius, startAngle: -CGFloat.pi, endAngle: -(CGFloat.pi / 2), clockwise: true)
        
        return bezierPath
    }

    /// Provides top left and right points, the gap will be between them
    private func findEdgePoints(config: BorderFactoryConfig) -> BorderFactoryGapPoints {
        let containerWidth = config.containerSize.width

        let topLeftPoint: CGFloat
        let topRightPoint: CGFloat

        switch config.floatyPaddings {
        case .center:
            topLeftPoint = (containerWidth - config.textSpace) / 2
            topRightPoint = (containerWidth + config.textSpace) / 2
        case .leading:
            topLeftPoint = config.cornerRadius
            topRightPoint = topLeftPoint + config.textSpace + 2 * config.sidePadding
        case .trailing:
            topRightPoint = containerWidth - config.cornerRadius - 2 * config.sidePadding
            topLeftPoint = topRightPoint - config.textSpace
        }

        let gapPoints = BorderFactoryGapPoints(left: topLeftPoint, right: topRightPoint)
        return gapPoints
    }

}
