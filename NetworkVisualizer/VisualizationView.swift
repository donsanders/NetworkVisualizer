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
    static let v0 = CGPoint(x: 2.5, y: 2.5)
    var positions: [CGPoint] = [CGPoint(x: 25, y: 25)]
    var velocities: [CGPoint] = [v0]
    var radius: CGFloat = 100

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func updateVelocityForWalls(velocity: CGPoint, position: CGPoint) -> CGPoint {
        var newVelocity = velocity
        if (position.x + radius > frame.width) {
            newVelocity.x = -VisualizationView.v0.x
        }
        if (position.y + radius > frame.height) {
            newVelocity.y = -VisualizationView.v0.y
        }
        if (position.x < 0) {
            newVelocity.x = VisualizationView.v0.x
        }
        if (position.y < 0) {
            newVelocity.y = VisualizationView.v0.y
        }
        let scalar: CGFloat = 100.0
        var horizontalDistance = position.x
        var horizontalDistanceSquared = horizontalDistance * horizontalDistance
        var horizontalForce = scalar / CGFloat(horizontalDistanceSquared)
        newVelocity.x += horizontalForce / 1

        var verticalDistance = position.y
        var verticalDistanceSquared = verticalDistance * verticalDistance
        var verticalForce = scalar / CGFloat(verticalDistanceSquared)
        newVelocity.y += verticalForce

        horizontalDistance = frame.width - position.x - radius
        horizontalDistanceSquared = horizontalDistance * horizontalDistance
        horizontalForce = scalar / CGFloat(horizontalDistanceSquared)
        newVelocity.x -= horizontalForce / 1

        verticalDistance = frame.height - position.y - radius
        verticalDistanceSquared = verticalDistance * verticalDistance
        verticalForce = scalar / CGFloat(verticalDistanceSquared)
        newVelocity.y -= verticalForce

        return newVelocity
    }

    func updateVelocities() {
        var newVelocities: [CGPoint] = []
        var i = 0
        for velocity in velocities {
            let position = positions[i]
            let newVelocity = updateVelocityForWalls(velocity: velocity, position: position)
            newVelocities.append(newVelocity)
            i += 1
        }
        velocities = newVelocities
    }

    func updatePositions() {
        var newPositions: [CGPoint] = []
        var i = 0
        for position in positions {
            let newPosition = CGPoint(x: position.x + velocities[i].x, y: position.y + velocities[i].y)
            newPositions.append(newPosition)
            i += 1
        }
        positions = newPositions
    }

    func updateState() {
        frameCount += 1
        updateVelocities()
        updatePositions()
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
        radius = min(frame.width, frame.height) / 2
        for node in positions {
            let origin = node
            drawCircle(origin: origin, radius: radius)
        }
    }

}

