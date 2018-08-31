//
//  VisualizationView.swift
//  NetworkVisualizer
//
//  Created by Don Sanders on 8/30/18.
//  Copyright © 2018 Don Sanders. All rights reserved.
//

import Foundation
import UIKit

class VisualizationView: UIView {
    
    var frameCount: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func drawCircle(origin: CGPoint, radius: CGFloat) {
        let circleRect = CGRect(origin: origin, size: CGSize(width: radius, height: radius))
        let fillColor = UIColor.red
        let path = UIBezierPath(ovalIn: circleRect)
        fillColor.setFill()
        path.fill()
    }
    
    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)
        let radius = min(frame.width, frame.height) / 2
        let origin = CGPoint(x: (frame.width - radius) / 2, y: (frame.height - radius) / 2)
        drawCircle(origin: origin, radius: radius)
    }

}
