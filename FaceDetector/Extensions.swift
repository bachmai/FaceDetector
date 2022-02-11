//
//  Extensions.swift
//  FaceDetector
//
//  Created by Bach Mai on 2/10/22.
//

import UIKit

extension CGSize {
    var cgPoint: CGPoint {
        return CGPoint(x: width, y: height)
    }
}

extension CGPoint {
    var cgSize: CGSize {
        return CGSize(width: x, height: y)
    }
}
