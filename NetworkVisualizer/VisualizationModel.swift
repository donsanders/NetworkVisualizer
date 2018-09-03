//
//  VisualizationModel.swift
//  NetworkVisualizer
//
//  Created by Don Sanders on 9/2/18.
//  Copyright © 2018 Don Sanders. All rights reserved.
//

import Foundation

class VisualizationModel  {

    static var nodeIndex: [String:Int] = [:]
    static var nodeName: [Int:String] = [:]
    static var nodeAlias: [String:String] = [:]
    var edges: [[Int]] = []

    init(filename: String) {
        loadCsvFromBundle(filename: filename)
    }

    init(filename: String, edges: [[Int]]) {
        self.edges = edges
        loadCsvFromBundle(filename: filename)
    }

    func updateEdgesForNewNode() {
        var newEdges: [[Int]] = []
        var count = 0
        for row in edges {
            var newRow = row
            newRow.append(0)
            newEdges.append(newRow)
            count = newEdges.count
        }
        newEdges.append(Array(repeating: 0, count: count + 1))
        edges = newEdges
    }

    static func register(node: String, model: VisualizationModel) -> Int? {
        let nodeTrimmed = node.trimmingCharacters(in: .whitespacesAndNewlines)
        return registerTrimmed(node: nodeTrimmed, model: model)
    }

    static func registerTrimmed(node: String, model: VisualizationModel) -> Int? {
        if nodeIndex[node] != nil { return nodeIndex[node] }
        let nodeCount = nodeIndex.count
        nodeIndex[node] = nodeCount
        nodeName[nodeCount] = node
        nodeAlias[node] = String(format:"%02X", nodeCount)
        print("registering \(node) alias \(nodeAlias[node])")
        model.updateEdgesForNewNode()
        return nodeCount
    }

    func loadCsvFromBundle(filename: String) {
        do {
            if let path = Bundle.main.path(forResource: filename, ofType: "csv") {
                let data = try String(contentsOfFile:path, encoding: String.Encoding.utf8)
                var rows : [String] = []
                var readData =  [String]()
                rows = data.components(separatedBy: "\n")
                var anonymizedData:String = ""
                for data in 0..<rows.count - 1 {
                    readData = rows[data].components(separatedBy: ";")
                    if let source = readData.first {
//                        print("source node \(source)")
                        guard let sourceIndex = VisualizationModel.register(node: source, model:self) else {
                            continue
                        }
                        anonymizedData.append(VisualizationModel.nodeAlias[source] ?? "")
                        for node in readData[1 ..< readData.count] {
//                            print("  edge to \(node)")
                            if let destinationIndex = VisualizationModel.register(node: node, model:self) {
                                edges[sourceIndex][destinationIndex] = 1
                                anonymizedData.append(";" + (VisualizationModel.nodeAlias[node] ?? ""))
                            }
                        }
                        //                    print("readData \(readData)")
                    }
                    anonymizedData.append("\n")
                }
                anonymizedData.append("\n")
                print("Anonymizing \(filename)")
                print(anonymizedData)
            }
        } catch let err as NSError {
            // do something with Error}
            print(err)
        }
    }

}
