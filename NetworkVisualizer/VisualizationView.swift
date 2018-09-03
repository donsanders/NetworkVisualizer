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
    weak var bannerLabel: UILabel?

    var frameCount: Int = 0

    static let wallStrength = 1.0
    static let v0 = CGPoint(x: wallStrength, y: wallStrength)
    var positions: [CGPoint] = []
    var velocities: [CGPoint] = []
    var appearance: [Int] = []
    var edges: [[Int]] = [[]]
    var colors: [UIColor] = []
    var activatedFrame: Int?
    let radius: CGFloat = 50
    var model1: VisualizationModel?
    var model2: VisualizationModel?
    var model3: VisualizationModel?
    var orderQueue: [Order] = []
    var edgeCount: Int = 0
    var litNode: Int?
    var litExpirtyFrame: Int = 0
    var paused: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        commoninit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commoninit()
    }

    func commoninit() {
        let delta = 45
        model1 = VisualizationModel(filename: "btc-aug-1")
        var endFrame: Int = queueModelForRelease(model: model1!,
                                                 nodeStartFrame: 1,
                                                 nodeReleaseDelta: delta,
                                                 edgeStartFrame: delta * 5,
                                                 edgeReleaseDelta: delta * 5)
        model2 = VisualizationModel(filename: "btc-aug-2", edges: model1!.edges)
        endFrame += delta * 6
        endFrame = queueModelForRelease(model: model2!,
                                        nodeStartFrame: endFrame,
                                        nodeReleaseDelta: delta / 4,
                                        edgeStartFrame: delta * 1,
                                        edgeReleaseDelta: delta / 4)
        insertIntoOrderQueue(order: Order(frameCount: 100, message: "Four nodes in a confinement field"))
        // nodes can be people, airports, web servers, or many other things
        insertIntoOrderQueue(order: Order(frameCount: 400, message: "Nodes connected by edges form a network topology"))
        insertIntoOrderQueue(order: Order(frameCount: 800, message: "Adding edges can cause dramatic changes in behavior"))
        insertIntoOrderQueue(order: Order(frameCount: 1200, message: "Scan 1:  4 seed nodes connected by knows-of edges"))
        insertIntoOrderQueue(order: Order(frameCount: 1900, message: "Scan 2:  Additional nodes are found"))
        insertIntoOrderQueue(order: Order(frameCount: 2250, message: "Scan 2:  Additional nodes are found and edges also"))
        insertIntoOrderQueue(order: Order(frameCount: 2600, message: "Eventually a core of connected nodes that form a small-world is found"))
        // when connected by edges such as handshakes, flights, or links on web pages
        // the collection of nodes and edges forms a network topology
    }

    func insertIntoOrderQueue(order: Order) {
        var i: Int = 0
        while i < orderQueue.count && orderQueue[i].frameCount < order.frameCount { i += 1 }
        orderQueue.insert(order, at: i)
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

    func makeNode(saturation: CGFloat) {
        let radians = CGFloat(frameCount)
        let w = frame.width / 2
        let h = frame.height / 2
        let x = sin(radians) * w
        let y = cos(radians) * h
        let p = CGPoint(x: w + x, y: h + y)
        positions.append(p)
        velocities.append(CGPoint.zero)
        appearance.append(frameCount)
        let color = UIColor.init(hue: radians / 13, saturation: saturation, brightness: 0.9, alpha: 1.0)
        colors.append(color)
    }

    var queuedEdgeCount: Int = 0
    func queueModelForRelease(model: VisualizationModel,
                              nodeStartFrame: Int,
                              nodeReleaseDelta: Int,
                              edgeStartFrame: Int,
                              edgeReleaseDelta: Int) -> Int {
        var rp: Int = nodeStartFrame
        for node in VisualizationModel.nodeIndex.keys {
//            print("xnode \(node)")
            orderQueue.append(Order(frameCount: rp, source: node, model: model))
            rp += nodeReleaseDelta
        }
        rp += edgeStartFrame
        for i in 0..<model.edges.count {
            for j in 0..<model.edges[i].count {
                guard model.edges[i][j] == 1 else { continue }
                if let src = VisualizationModel.nodeName[i], let dest = VisualizationModel.nodeName[j] {
                    print("Adding edge \(src) \(dest)")
                    queuedEdgeCount += 1
                    if queuedEdgeCount == 4 { rp += 60*2 } // HACK
                    orderQueue.append(Order(frameCount: rp, source: src, destination: dest, model: model))
                }
                rp += edgeReleaseDelta
            }
        }
        return rp
    }

    func action() {
        paused = !paused
//        activatedFrame = frameCount
    }

    func applyInverseSquareForceRepulser(delta: CGPoint) -> CGPoint {
//        let scalar: CGFloat = 50
        let scalar: CGFloat = 2
        return applyInverseSquareForceRepulser(scalar: scalar, delta: delta)
    }

    func applyInverseSquareForceRepulser(scalar: CGFloat, delta: CGPoint) -> CGPoint {
        let scalarBase: CGFloat = scalar * sqrt(2)
        let minDelta: CGFloat = 7
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
            if delta.x * delta.x + delta.y + delta.y > ignoreDistance * ignoreDistance { return CGPoint.zero }
            let minDeltaSquared = CGFloat(minDelta * minDelta)
            let force = scalarBase / minDeltaSquared
             newVelocity.x = delta.x >= 0 ? force : -force
             newVelocity.y = delta.y >= 0 ? force : -force
        }
        return newVelocity
    }

    func applySpringForceAttractor(velocity: CGPoint, delta: CGPoint) -> CGPoint {
//        let maxMultiplier:CGFloat = 100
        let maxMultiplier:CGFloat = 0.1
        let distance = sqrt(delta.x * delta.x + delta.y * delta.y)
        var multiplier = distance
        if distance > maxMultiplier {
            multiplier = maxMultiplier
        }
        let horizontalForce = multiplier * delta.x / distance
        let verticalForce = multiplier * delta.y / distance
        return CGPoint(x: horizontalForce, y: verticalForce)

    }

    func updateVelocityForBalls(velocity: CGPoint, position: CGPoint, i: Int) -> CGPoint {
        var newVelocity = velocity
        var j = 0
        for ball in positions {
            let delta = CGPoint(x: position.x - ball.x, y: position.y - ball.y)
            var vDelta1 = CGPoint.zero
            if i != j {
                vDelta1 = applyInverseSquareForceRepulser(delta: delta)
            }
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
            let vDelta1 = applyInverseSquareForceRepulser(scalar: CGFloat(strength), delta: delta)
            newVelocity = CGPoint(x: newVelocity.x - vDelta1.x, y: newVelocity.y - vDelta1.y)
        }
        return newVelocity
    }

    func updateVelocityForWalls(velocity: CGPoint, position: CGPoint) -> CGPoint {
        var newVelocity = velocity
        if (position.x + radius / 2 > frame.width) {
            newVelocity.x = -VisualizationView.v0.x
        }
        if (position.y + radius / 2 > frame.height) {
            newVelocity.y = -VisualizationView.v0.y
        }
        if (position.x - radius / 2 < 0) {
            newVelocity.x = VisualizationView.v0.x
        }
        if (position.y - radius / 2 < 0) {
            newVelocity.y = VisualizationView.v0.y
        }
        let scalar: CGFloat = 1000.0
        var horizontalDistance = position.x - radius / 2
//        var horizontalDistanceSquared = horizontalDistance
        var horizontalDistanceSquared = horizontalDistance * horizontalDistance
        var horizontalForce = scalar / CGFloat(horizontalDistanceSquared)
        newVelocity.x += horizontalForce / 1

        var verticalDistance = position.y - radius / 2
        var verticalDistanceSquared = verticalDistance * verticalDistance
//        var verticalDistanceSquared = verticalDistance
        var verticalForce = scalar / CGFloat(verticalDistanceSquared)
        newVelocity.y += verticalForce

        horizontalDistance = frame.width - position.x - radius / 2
        horizontalDistanceSquared = horizontalDistance * horizontalDistance
//        horizontalDistanceSquared = horizontalDistance
        horizontalForce = scalar / CGFloat(horizontalDistanceSquared)
        newVelocity.x -= horizontalForce / 1

        verticalDistance = frame.height - position.y - radius / 2
        verticalDistanceSquared = verticalDistance * verticalDistance
//        verticalDistanceSquared = verticalDistance
        verticalForce = scalar / CGFloat(verticalDistanceSquared)
        newVelocity.y -= verticalForce

        return newVelocity
    }

    func updateVelocities() {
        var newVelocities: [CGPoint] = []
        var i = 0
//        let speedLimit: CGFloat = 1.0 / sqrt(2.0)
        let speedLimit: CGFloat = 5.0
        for velocity in velocities {
            if (frameCount < appearance[i]) {
                newVelocities.append(velocity)
                i += 1;
                continue
            }
            let position = positions[i]
            let velocity1 = updateVelocityForWalls(velocity: velocity, position: position)
            var velocity2 = updateVelocityForBalls(velocity: velocity1, position: position, i: i)

            let velocitySquared = velocity2.x * velocity2.x + velocity2.y * velocity2.y
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
            if (newPosition.x > frame.width) {
                newPosition.x = frame.width - 1
            }
            if (newPosition.y > frame.height) {
                newPosition.y = frame.height - 1
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

    func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }

    func addNodes() {
        guard let order = orderQueue.first else { return }
        if order.frameCount <= frameCount {
            orderQueue = Array(orderQueue[1..<orderQueue.count])
            switch order.orderType {
            case .addNode:
                let saturation: CGFloat = positions.count < 5 ? 0.9 : 0.8 // HACK
                makeNode(saturation: saturation)
                makeEdges()
            case .addEdge:
                let source = order.source
//                print("case edge \(source) \(positions.count) \(edgeCount)")
                if let destination = order.destination,
                    let sourceIndex = VisualizationModel.nodeIndex[source],
                    let destinationIndex = VisualizationModel.nodeIndex[destination],
                    edges[sourceIndex][destinationIndex] == 0 {
                    edgeCount += 1
                    edges[sourceIndex][destinationIndex] = 1
                    litNode = sourceIndex
                    litExpirtyFrame = frameCount + 40
//                    print("litExpirtyFrame \(litExpirtyFrame)")
                }
            case .message:
                guard let message = order.message else { return }
                bannerLabel?.text = message
//                print("message \(message)")
                if let banner = bannerLabel { setView(view: banner, hidden: false) }
                insertIntoOrderQueue(order: Order(frameCount: frameCount + 60*5))
            case .hideBanner:
//                print("hide banner")
                if let banner = bannerLabel { setView(view: banner, hidden: true) }
            default:
                print("Unknown order type.")
            }
        }
        return
    }

    func updateState() {
        if paused { return }
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

    static var luck: Int = 0
    func drawEdges() {
        var i = 0
        var j = 0
        for node1 in positions {
            j = 0
            if (frameCount < appearance[i] ) { i += 1; continue }
            for node2 in positions {
                VisualizationView.luck += 1
                if edges[i][j] == 0 { j += 1; continue }
                if i > j && edges[j][i] == 1 { j += 1; continue } // Already drawn
//                if (VisualizationView.luck % 5) != 0 { j += 1; continue }
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
        if let litNode = self.litNode {
            let origin = positions[litNode]
            drawCircle(origin: origin, radius: radius / 2, fillColor: UIColor.white)
            if frameCount > litExpirtyFrame { self.litNode = nil }
        }
    }

    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)
        drawEdges()
        drawNodes()
    }

}
