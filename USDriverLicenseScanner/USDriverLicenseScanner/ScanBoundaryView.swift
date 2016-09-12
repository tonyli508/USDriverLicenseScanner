//
//  ScanBoundaryView.swift
//  Ridepool
//
//  Created by Li Jiantang on 27/05/2015.
//  Copyright (c) 2015 Carma. All rights reserved.
//

import UIKit

/// Scanner boundary frame view
class ScanBoundaryView: UIView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
    }
    
    override func drawRect(rect: CGRect) {
        
        let width = rect.width
        let height = rect.height
        
        let length: CGFloat = 40.0
        
        let context = UIGraphicsGetCurrentContext()
        
        let white = UIColor.whiteColor().CGColor
        let lineWidth: CGFloat = 4.0
        
        CGContextSetLineWidth(context, lineWidth)
        CGContextSetStrokeColorWithColor(context, white)
        
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineJoin(context, CGLineJoin.Round)
        
        drawConorForPoint(0, y: 0, xOffset: length, yOffset: length, inContext: context)
        drawConorForPoint(width, y: 0, xOffset: -length, yOffset: length, inContext: context)
        drawConorForPoint(0, y: height, xOffset: length, yOffset: -length, inContext: context)
        drawConorForPoint(width, y: height, xOffset: -length, yOffset: -length, inContext: context)
    }
    
    private func drawConorForPoint(x: CGFloat, y: CGFloat, xOffset: CGFloat, yOffset: CGFloat, inContext: CGContextRef?) {
        
        CGContextMoveToPoint(inContext, x, y + yOffset)
        CGContextAddLineToPoint(inContext, x, y)
        CGContextAddLineToPoint(inContext, x + xOffset, y)
        CGContextStrokePath(inContext)
    }
}
