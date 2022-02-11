//
//  FaceBoxView.swift
//  FaceDetector
//
//  Created by Bach Mai on 2/10/22.
//

import UIKit

class FaceBoxView: UIView {

    var boundingBoxes: [CGRect] = []

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.setStrokeColor(UIColor.green.cgColor)
        context.setLineWidth(6.0)
        for box in boundingBoxes {
            context.addRect(box)
            context.strokePath()
        }
    }
    
    func clear() {
        boundingBoxes = []
        
        DispatchQueue.main.async {
            self.setNeedsDisplay()
        }
    }
}
