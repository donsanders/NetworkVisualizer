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
    static let v1 = CGPoint(x: 2.5, y: 2.5)
    static let v2 = CGPoint(x: -2.5, y: -2.5)
    static let p0 = CGPoint(x: 25, y: 125)
    static let p1 = CGPoint(x: 175, y: 75)
    static let p2 = CGPoint(x: 100, y: 225)
    var positions: [CGPoint] = [p0, p1, p2]
    var velocities: [CGPoint] = [v0, v1, v2]
    var colors: [UIColor] = [UIColor.red, UIColor.green, UIColor.blue]
    var radius: CGFloat = 50

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func applyInverseSquareForce(velocity: CGPoint, delta: CGPoint) -> CGPoint {
        let scalar: CGFloat = 10
        var newVelocity = velocity
        let horizontalDistance = delta.x
        let horizontalDistanceSquared = horizontalDistance * horizontalDistance
        let horizontalForce = scalar / CGFloat(horizontalDistanceSquared)
        newVelocity.x += horizontalForce

        let verticalDistance = delta.y
        let verticalDistanceSquared = verticalDistance * verticalDistance
        let verticalForce = scalar / CGFloat(verticalDistanceSquared)
        newVelocity.y += verticalForce

        return newVelocity
    }

    func updateVelocityForBalls(velocity: CGPoint, position: CGPoint, i: Int) -> CGPoint {
        var newVelocity = velocity
        var j = 0
        for ball in positions {
            print("position \(position) ball \(ball)")
            if i == j { j += 1; continue }
            let delta = CGPoint(x: position.x - ball.x, y: position.y - ball.y)
            let vDelta = applyInverseSquareForce(velocity: newVelocity, delta: delta)
            print("i \(i) j \(j) newVelocity \(newVelocity) vDelta \(vDelta)")
            newVelocity = CGPoint(x: newVelocity.x - vDelta.x, y: newVelocity.y - vDelta.y)
            j += 1
        }
        return newVelocity
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
            var newVelocity = updateVelocityForWalls(velocity: velocity, position: position)
//            newVelocity = updateVelocityForBalls(velocity: newVelocity, position: position, i: i)
            newVelocities.append(newVelocity)
            if fabs(newVelocity.x) > 10.0 { print("newVelocity.x \(newVelocity.x)") }
            if fabs(newVelocity.y) > 10.0 { print("newVelocity.y \(newVelocity.y)") }
            i += 1
        }
        velocities = newVelocities
    }

    func updatePositions() {
        var newPositions: [CGPoint] = []
        var i = 0
        for position in positions {
            var newPosition = CGPoint(x: position.x + velocities[i].x, y: position.y + velocities[i].y)
            if (newPosition.x + radius > frame.width) {
                newPosition.x = frame.width - radius - 1
            }
            if (newPosition.y + radius > frame.height) {
                newPosition.y = frame.height - radius - 1
            }
            if (newPosition.x < 0 || newPosition.x.isNaN) {
                newPosition.x = 1
            }
            if (newPosition.y < 0 || newPosition.y.isNaN) {
                newPosition.y = 1
            }
            if fabs(newPosition.x) > 100.0 { print("newPosition.x \(newPosition.x)") }
            if fabs(newPosition.y) > 100.0 { print("newPosition.y \(newPosition.x)") }
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

    func drawCircle(origin: CGPoint, radius: CGFloat, fillColor: UIColor) {
        let circleRect = CGRect(origin: origin, size: CGSize(width: radius, height: radius))
        let path = UIBezierPath(ovalIn: circleRect)
        fillColor.setFill()
        path.fill()
    }

    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)
        var i = 0
        for node in positions {
            let origin = node
            drawCircle(origin: origin, radius: radius, fillColor: colors[i])
            i += 1
        }
    }

}

