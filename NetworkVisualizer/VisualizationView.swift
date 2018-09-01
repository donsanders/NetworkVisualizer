//
//  VisualizationView.swift
//  NetworkVisualizer
//
//  Created by Don Sanders on 8/30/18.
//  Copyright © 2018 Don Sanders. All rights reserved.
//

import Foundation
import UIKit

class VisualizationView: UIButton {

    var frameCount: Int = 0

    static let wallStrength = 1.0
    static let v0 = CGPoint(x: wallStrength, y: wallStrength)
    static let v1 = CGPoint(x: wallStrength, y: wallStrength)
    var positions: [CGPoint] = []
    var velocities: [CGPoint] = []
    var appearance: [Int] = []
    var edges: [[Int]] = [[]]
    var colors: [UIColor] = []
    var activatedFrame: Int?
    let radius: CGFloat = 50

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func action() {
        activatedFrame = frameCount
    }

    func applyInverseSquareForceRepulser(velocity: CGPoint, delta: CGPoint) -> CGPoint {
        let scalar: CGFloat = 10
        return applyInverseSquareForceRepulser(scalar: scalar, velocity: velocity, delta: delta)
    }

    func applyInverseSquareForceRepulser(scalar: CGFloat, velocity: CGPoint, delta: CGPoint) -> CGPoint {
        let minDelta: CGFloat = 50
        var newVelocity = CGPoint.zero
        enum Mode {
            case old
            case corrected
            case fortunate
        }
        let mode = Mode.fortunate
        switch mode {
        case .old:
            let horizontalDistance = min(max(delta.x, minDelta), -minDelta)
            let horizontalDistanceSquared = horizontalDistance * horizontalDistance
            let horizontalForce = scalar / CGFloat(horizontalDistanceSquared)
            newVelocity.x = horizontalForce
            let verticalDistance = min(max(delta.y, minDelta), -minDelta)
            let verticalDistanceSquared = verticalDistance * verticalDistance
            let verticalForce = scalar / CGFloat(verticalDistanceSquared)
            newVelocity.y = verticalForce
        case .corrected:
            var horizontalDistance : CGFloat?
            if delta.x >= 0 { horizontalDistance = max(delta.x, minDelta) }
            else { horizontalDistance = min(delta.x, -minDelta) }
            let horizontalDistanceSquared = horizontalDistance! * horizontalDistance!
            let horizontalForce = scalar / CGFloat(horizontalDistanceSquared)
            newVelocity.x = horizontalForce
            var verticalDistance : CGFloat?
            if delta.y >= 0 { verticalDistance = max(delta.y, minDelta) }
            else { verticalDistance = min(delta.y, -minDelta) }
            let verticalDistanceSquared = verticalDistance! * verticalDistance!
            let verticalForce = scalar / CGFloat(verticalDistanceSquared)
            newVelocity.y = verticalForce
        case .fortunate:
            let ignoreDistance: CGFloat = 50
            let minDeltaSquared = CGFloat(minDelta * minDelta)
            if delta.x * delta.x + delta.y + delta.y > ignoreDistance * ignoreDistance { return CGPoint.zero }
            let force = scalar / minDeltaSquared
            newVelocity.x = delta.x >= 0 ? force : -force
            newVelocity.y = delta.y >= 0 ? force : -force
        }

        return newVelocity
    }

    func applySpringForceAttractor(velocity: CGPoint, delta: CGPoint) -> CGPoint {
        let scalar: CGFloat = 500
        let maxDelta: CGFloat = 250
        let horizontalDistance = max(min(delta.x, maxDelta), -maxDelta) / scalar
        let verticalDistance = max(min(delta.y, maxDelta), -maxDelta) / scalar
        return CGPoint(x: horizontalDistance, y: verticalDistance)
    }

    func updateVelocityForBalls(velocity: CGPoint, position: CGPoint, i: Int) -> CGPoint {
        var newVelocity = velocity
        var j = 0
        for ball in positions {
            let delta = CGPoint(x: position.x - ball.x, y: position.y - ball.y)
            let vDelta1 = applyInverseSquareForceRepulser(velocity: newVelocity, delta: delta)
            var vDelta2 = CGPoint.zero
            if edges[i][j] == 1 { vDelta2 = applySpringForceAttractor(velocity: newVelocity, delta: delta) }
            newVelocity = CGPoint(x: newVelocity.x + vDelta1.x - vDelta2.x, y: newVelocity.y + vDelta1.y - vDelta2.y)
            j += 1
        }
        let propulsionDuration = 0
        if (frameCount < appearance[i] + propulsionDuration || activatedFrame != nil) {
            var strength = appearance[i] + propulsionDuration - frameCount
            if let activatedFrame = activatedFrame { strength = (activatedFrame - frameCount + 1) * 20 }
            let delta = CGPoint(x: frame.width / 2 - position.x, y: frame.height / 2 - position.y)
            let vDelta1 = applyInverseSquareForceRepulser(scalar: CGFloat(strength), velocity: newVelocity, delta: delta)
            newVelocity = CGPoint(x: newVelocity.x + vDelta1.x, y: newVelocity.y + vDelta1.y)
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
        let speedLimit: CGFloat = 10.0 / sqrt(2.0)
        for velocity in velocities {
            if (frameCount < appearance[i]) {
                newVelocities.append(velocity)
                i += 1;
                continue
            }
            let position = positions[i]
            let velocity1 = updateVelocityForWalls(velocity: velocity, position: position)
            var velocity2 = updateVelocityForBalls(velocity: velocity1, position: position, i: i)

            let velocitySquared = velocity2.x*velocity2.x + velocity2.y*velocity2.y
            let speedSquared = speedLimit * speedLimit
            if velocitySquared > speedSquared  {
                let scalar = speedLimit / sqrt(velocitySquared)
                velocity2.x = scalar * velocity2.x
                velocity2.y = scalar * velocity2.y
            }
            newVelocities.append(velocity2)

            i += 1
        }
        velocities = newVelocities
    }

    func updatePositions() {
        var newPositions: [CGPoint] = []
        var i = 0
        for position in positions {
            if (frameCount < appearance[i]) {
                newPositions.append(position)
                i += 1
                continue
            }

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
//            if fabs(newPosition.x) > 320.0 { print("newPosition.x \(newPosition.x)") }
//            if fabs(newPosition.y) > 610.0 { print("newPosition.y \(newPosition.y)") }
            newPositions.append(newPosition)
            i += 1
        }
        positions = newPositions
    }

    func makeEdges() {
        var newEdges: [[Int]] = []
        var count = 1
        for row in edges {
            var newRow = row
            newRow.append(0)
            newEdges.append(newRow)
            count = newEdges.count
        }
        newEdges.append(Array(repeating: 0, count: count))
        edges = newEdges
    }

    func addNodes() {
        // generate angle based on frameCount / 60 can be radians
        let releasePeriod = 60
        switch frameCount % releasePeriod {
        case 1:
            let radians = CGFloat(frameCount / releasePeriod)
            let w = frame.width / 2
            let h = frame.height / 2
            let x = sin(radians) * w
            let y = cos(radians) * h
            let p = CGPoint(x: w + x, y: h + y)
            positions.append(p)
            velocities.append(CGPoint.zero)
            appearance.append(frameCount)
            let color = UIColor.init(hue: radians / 13, saturation: 1.0, brightness: 0.9, alpha: 1.0)
            colors.append(color)
            makeEdges()
            print("\(frameCount / releasePeriod)")
        default:
            return
        }
    }

    func updateState() {
        frameCount += 1
        addNodes()
        updateVelocities()
        updatePositions()
    }

    func drawEdge(start: CGPoint, end: CGPoint) {
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        path.close()
        UIColor.darkGray.set()
        path.stroke()
        path.fill()
    }

    func drawCircle(origin: CGPoint, radius: CGFloat, fillColor: UIColor) {
        let rectTopLeft = CGPoint(x: origin.x - radius / 2, y: origin.y - radius / 2)
        let circleRect = CGRect(origin: rectTopLeft, size: CGSize(width: radius, height: radius))
        let path = UIBezierPath(ovalIn: circleRect)
        fillColor.setFill()
        path.fill(with: CGBlendMode.screen, alpha: 0.5)
    }

    func drawEdges() {
        var i = 0
        var j = 0
        for node1 in positions {
            j = 0
            if (frameCount < appearance[i] ) { i += 1; continue }
            for node2 in positions {
                if edges[i][j] == 0 { j += 1; continue }
                if (frameCount < appearance[j] ) { j += 1; continue }
                drawEdge(start: node1, end: node2)
                j += 1
            }
            i += 1
        }
    }

    func drawNodes() {
        var i = 0
        for node in positions {
            if (frameCount < appearance[i] ) { i += 1; continue }
            let origin = node
            drawCircle(origin: origin, radius: radius, fillColor: colors[i])
            i += 1
        }
    }

    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)
        drawEdges()
        drawNodes()
    }

}
