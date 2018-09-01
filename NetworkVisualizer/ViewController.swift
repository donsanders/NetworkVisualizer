//
//  ViewController.swift
//  NetworkVisualizer
//
//  Created by Don Sanders on 8/30/18.
//  Copyright © 2018 Don Sanders. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var visualizationView: VisualizationView!
    var displayLink: CADisplayLink?
    var startTime = 0.0
    let animLength = 100000.0

    override func viewDidLoad() {
        super.viewDidLoad()
        startDisplayLink()
    }

    @IBAction func screenTouched(_ sender: Any) {
        visualizationView.action()
    }

    func startDisplayLink() {
        stopDisplayLink() // make sure to stop a previous running display link
        startTime = CACurrentMediaTime() // reset start time

        // create displayLink & add it to the run-loop
        let displayLink = CADisplayLink(target: self, selector: #selector(displayLinkDidFire))
        displayLink.add(to: .main, forMode: .commonModes)
        self.displayLink = displayLink
    }

    @objc func displayLinkDidFire(_ displayLink: CADisplayLink) {
        var elapsed = CACurrentMediaTime() - startTime
        if elapsed > animLength {
            stopDisplayLink()
            elapsed = animLength // clamp the elapsed time to the anim length
        }

        // Animation logic
        visualizationView.updateState()
        visualizationView.setNeedsDisplay();
    }

    // Invalidate display link if it's non-nil, then set to nil
    func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

}

