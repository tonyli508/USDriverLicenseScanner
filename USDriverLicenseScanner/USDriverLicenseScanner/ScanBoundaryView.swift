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
        
        self.backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {
        
        let width = rect.width
        let height = rect.height
        
        let length: CGFloat = 40.0
        
        if let context = UIGraphicsGetCurrentContext() {
            let white = UIColor.white.cgColor
            let lineWidth: CGFloat = 4.0
            
            context.setLineWidth(lineWidth)
            context.setStrokeColor(white)
            
            context.setLineCap(CGLineCap.round)
            context.setLineJoin(CGLineJoin.round)
            
            drawConorForPoint(x: 0, y: 0, xOffset: length, yOffset: length, inContext: context)
            drawConorForPoint(x: width, y: 0, xOffset: -length, yOffset: length, inContext: context)
            drawConorForPoint(x: 0, y: height, xOffset: length, yOffset: -length, inContext: context)
            drawConorForPoint(x: width, y: height, xOffset: -length, yOffset: -length, inContext: context)
        }
    }
    
    private func drawConorForPoint(x: CGFloat, y: CGFloat, xOffset: CGFloat, yOffset: CGFloat, inContext: CGContext) {
        inContext.move(to: CGPoint(x: x, y: y + yOffset))
        inContext.addLine(to: CGPoint(x: x, y: y))
        inContext.addLine(to: CGPoint(x: x + xOffset, y: y))
        inContext.strokePath()
    }
}
