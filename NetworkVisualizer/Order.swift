//
//  Order.swift
//  NetworkVisualizer
//
//  Created by Don Sanders on 9/2/18.
//  Copyright © 2018 Don Sanders. All rights reserved.
//

import Foundation

class Order {
    enum OrderType {
        case addNode
        case addEdge
        case message
        case hideBanner
    }

    let orderType: OrderType
    let frameCount: Int
    let source: String
    let destination: String?
    let model: VisualizationModel?
    let message: String?

    // these should all be private and have public static convenience functions

    init(frameCount: Int, source: String, model: VisualizationModel) {
        self.frameCount = frameCount
        self.source = source
        self.destination = nil
        self.model = model
        message = nil
        orderType = .addNode
    }

    init(frameCount: Int, source: String, destination: String, model: VisualizationModel) {
        self.frameCount = frameCount
        self.source = source
        self.destination = destination
        self.model = model
        message = nil
        orderType = .addEdge
    }

    init(frameCount: Int, message: String) {
        self.frameCount = frameCount
        self.message = "  " + message
        self.source = ""
        self.destination = nil
        self.model = nil
        orderType = .message
    }

    init(frameCount: Int) {
        self.frameCount = frameCount
        self.message = ""
        self.source = ""
        self.destination = nil
        self.model = nil
        orderType = .hideBanner
    }

}
