//
//  FaceDetectorViewController.swift
//  FaceDetector
//
//  Created by Bach Mai on 2/10/22.
//

import UIKit
import AVFoundation
import Vision

class FaceDetectorViewController: UIViewController {
    
    @IBOutlet weak var cameraView: FaceBoxView!
    @IBOutlet weak var faceBoxView: FaceBoxView!
    @IBOutlet weak var faceCountLabel: UILabel!
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var cameraOutputQueue = DispatchQueue(label: "CameraOutputQueue")
    var sequenceRequestHandler = VNSequenceRequestHandler()

    override func viewDidLoad() {
        super.viewDidLoad()

        // get camera
        captureSession = AVCaptureSession()
        guard let captureDevice = getFrontCamera() else {
            failAlert("No camera detected")
            return
        }
        
        // add camera to input
        do {
            let videoInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(videoInput)
        } catch {
            failAlert("No camera detected")
            return
        }
        
        // video output
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: cameraOutputQueue)
        
        captureSession.addOutput(videoOutput)
        
        let videoConnection = videoOutput.connection(with: .video)
        videoConnection?.videoOrientation = .portrait
        
        // add preview layer to cameraView
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        cameraView.layer.addSublayer(previewLayer)
        captureSession.startRunning()
    }

    private func getFrontCamera() -> AVCaptureDevice? {
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
    }
    
    private func getBackCamera() -> AVCaptureDevice? {
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
    }
    
    private func failAlert(_ title: String, message: String? = "") {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

// MARK: AVCaptureVideoDataOutputSampleBufferDelegate
extension FaceDetectorViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        let detectFaceRequest = VNDetectFaceRectanglesRequest(completionHandler: detectFaceRequestHandler)
        
        do {
            try sequenceRequestHandler.perform([detectFaceRequest], on: imageBuffer, orientation: .leftMirrored)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func detectFaceRequestHandler(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNFaceObservation] else {
            return
        }
        if results.isEmpty {
            faceBoxView.clear()
        } else {
            faceBoxView.boundingBoxes = []
            for result in results {
                let rect = result.boundingBox
                let origin = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.origin)
                let size = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.size.cgPoint)
                faceBoxView.boundingBoxes.append(CGRect(origin: origin, size: size.cgSize))
            }
        }
        
        DispatchQueue.main.async {
            self.faceBoxView.setNeedsDisplay()
            self.faceCountLabel.text = "\(results.count)"
        }
    }
}
