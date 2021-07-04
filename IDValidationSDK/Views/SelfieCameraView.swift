//
//  SelfieCameraView.swift
//  Medyear
//
//  Created by Bahrom Abdullaev on 9/28/19.
//  Copyright © 2019 Personiform. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
//import Firebase
import MLKit


class SelfieCameraView: UIView {
    
    var session: AVCaptureSession!
    var input: AVCaptureDeviceInput!
    var device: AVCaptureDevice!
    var imageOutput: AVCaptureStillImageOutput!
    var preview: AVCaptureVideoPreviewLayer!
    
    let cameraQueue = DispatchQueue(label: "com.medyear.SelfieCameraView.Queue")
    private var lastFrame: CMSampleBuffer?
    var lastImage: UIImage?
    
    public var currentPosition = AVCaptureDevice.Position.front
    
    var faceDetected: ((_ image: UIImage?, _ isDetectFace: Bool, _ isDetectSmile: Bool) -> ())?
        
    var detectStartFace: Bool = false
    var detectStartFaceContour: Bool = false
    var isDetectFaceFinish: Bool = false
    var isDetectFaceContourFinish: Bool = false
    
    var IDDetected: Bool{isDetectFaceFinish && isDetectFaceContourFinish}
    var detectStart: Bool {detectStartFace || detectStartFaceContour}
        
    var faceConfidance: Float = 0.0
    var isFirstTry: Bool = false
    
    private lazy var animationViewTop: UIView={
        let v = UIView()
        v.frame = CGRect(x: 0, y: 0, width: self.width, height: 2.5)
        v.backgroundColor = UIColor.updatesHeaderBgColor()
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = v.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let vibrancyBlurEffect = UIBlurEffect(style: .dark)
        let vibrancyEffect = UIVibrancyEffect(blurEffect: vibrancyBlurEffect)
        let vibrancyBlurEffectView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyBlurEffectView.frame = v.bounds
        vibrancyBlurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.contentView.addSubview(vibrancyBlurEffectView)
        v.addSubview(blurEffectView)
        
        return v
    }()
    
    private lazy var overlayView: UIImageView={
        let iv: UIImageView = UIImageView(image: UIImage(named: "face_overlay.png"), highlightedImage: UIImage(named: "face_overlay_green.png"))
        
        return iv
    }()
    
    
    deinit {
        self.preview?.removeFromSuperlayer()
        self.session = nil
        self.input = nil
        self.imageOutput = nil
        self.preview = nil
        self.device = nil
    }
    
    public func setupCamera(){
        self.setUpCaptureSessionOutput()
        self.setUpCaptureSessionInput()
    }
    
    public func startSession() {
        cameraQueue.async {
            if self.session != nil{
                self.session.startRunning()
            }
        }
    }
    
    public func stopSession() {
        cameraQueue.async {
            if self.session != nil{
                self.session.stopRunning()
            }
        }
    }
    
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        preview?.frame = bounds
        //self.overlayView.frame = bounds
    }
    
    
    private func createPreview() {
        preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = AVLayerVideoGravity.resizeAspectFill
        preview.frame = bounds
        layer.addSublayer(preview)
//        self.addSubview(self.overlayView)
    }
    
    
    
    private func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devices(for: AVMediaType.video)
        return devices.filter { $0.position == position }.first
    }
    
    public func capturePhoto(completion: @escaping CameraShotCompletion) {
        isUserInteractionEnabled = false
        
        guard let output = imageOutput, let orientation = AVCaptureVideoOrientation(rawValue: UIDevice.current.orientation.rawValue) else {
            completion(nil)
            return
        }
        
        let size = frame.size
        
        cameraQueue.sync {
            takePhoto(output, videoOrientation: orientation, cropSize: size) { image in
                DispatchQueue.main.async() { [weak self] in
                    self?.isUserInteractionEnabled = true
                    completion(image)
                }
            }
        }
    }
    
    public func focusCamera(toPoint: CGPoint) -> Bool {
        
        guard let device = device, let preview = preview, device.isFocusModeSupported(.continuousAutoFocus) else {
            return false
        }
        
        do { try device.lockForConfiguration() } catch {
            return false
        }
        
        let focusPoint = preview.captureDevicePointConverted(fromLayerPoint: toPoint)
        
        device.focusPointOfInterest = focusPoint
        device.focusMode = .continuousAutoFocus
        
        device.exposurePointOfInterest = focusPoint
        device.exposureMode = .continuousAutoExposure
        
        device.unlockForConfiguration()
        
        return true
    }
    
    public func cycleFlash() {
        guard let device = device, device.hasFlash else {
            return
        }
        
        do {
            
            try device.lockForConfiguration()
            if device.flashMode == .on {
                device.flashMode = .off
            } else if device.flashMode == .off {
                device.flashMode = .auto
            } else {
                device.flashMode = .on
            }
            device.unlockForConfiguration()
        } catch _ { }
    }
    
    public func swapCameraInput() {
        
        guard let session = session, let currentInput = input else {
            return
        }
        
        session.beginConfiguration()
        session.removeInput(currentInput)
        
        if currentInput.device.position == AVCaptureDevice.Position.back {
            currentPosition = .front
            device = cameraWithPosition(position: currentPosition)
        } else {
            currentPosition = .back
            device = cameraWithPosition(position: currentPosition)
        }
        
        guard let newInput = try? AVCaptureDeviceInput(device: device) else {
            return
        }
        
        input = newInput
        
        session.addInput(newInput)
        session.commitConfiguration()
    }
    
    public func rotatePreview() {
        
        guard preview != nil else {
            return
        }
        switch UIApplication.shared.statusBarOrientation {
        case .portrait:
            preview?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
            break
        case .portraitUpsideDown:
            preview?.connection?.videoOrientation = AVCaptureVideoOrientation.portraitUpsideDown
            break
        case .landscapeRight:
            preview?.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
            break
        case .landscapeLeft:
            preview?.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeLeft
            break
        default: break
        }
        
    }
    
    private func setUpCaptureSessionOutput() {
        
        session = AVCaptureSession()
        
        cameraQueue.async {
            self.session.beginConfiguration()
            // When performing latency tests to determine ideal capture settings,
            // run the app in 'release' mode to get accurate performance metrics
            self.session.sessionPreset = AVCaptureSession.Preset.medium
            
            let output = AVCaptureVideoDataOutput()
            output.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA]
            let outputQueue = DispatchQueue(label: "com.medyear.IDCameraView.OutputQueue")
            output.setSampleBufferDelegate(self, queue: outputQueue)
            guard self.session.canAddOutput(output) else {
                debugPrint("Failed to add capture session output.")
                return
            }
            self.session.addOutput(output)
            
            let connection = output.connection(with: .video)
            connection?.videoOrientation = .portrait
            self.session.commitConfiguration()
            DispatchQueue.main.async() { [weak self] in
                self?.createPreview()
            }
        }
    }
    
    private func setUpCaptureSessionInput() {
        cameraQueue.async {
            let cameraPosition: AVCaptureDevice.Position = self.currentPosition
            guard let device = self.captureDevice(forPosition: cameraPosition) else {
                debugPrint("Failed to get capture device for camera position: \(cameraPosition)")
                return
            }
            do {
                self.session.beginConfiguration()
                let currentInputs = self.session.inputs
                for input in currentInputs {
                    self.session.removeInput(input)
                }
                
                let input = try AVCaptureDeviceInput(device: device)
                guard self.session.canAddInput(input) else {
                    debugPrint("Failed to add capture session input.")
                    return
                }
                self.session.addInput(input)
                self.session.commitConfiguration()
            } catch {
                debugPrint("Failed to create capture device input: \(error.localizedDescription)")
            }
        }
    }
    
    private func captureDevice(forPosition position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        if #available(iOS 10.0, *) {
            let discoverySession = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.builtInWideAngleCamera],
                mediaType: .video,
                position: .unspecified
            )
            return discoverySession.devices.first { $0.position == position }
        }
        return nil
    }
}


extension SelfieCameraView: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("Failed to get image buffer from sample buffer. - ")
            return
        }
        if self.detectStart {
            return
        }
        if self.IDDetected{
            if !self.isFirstTry {

            }
            if let fd = self.faceDetected {
                fd(self.lastImage, self.isDetectFaceContourFinish, self.isDetectFaceFinish)
            }
            return
        }
        
        
        
        debugPrint("Result - ", self.isDetectFaceFinish ? "Face Detected," : "Face Not Detected,")
        lastFrame = sampleBuffer
        let visionImage = VisionImage(buffer: sampleBuffer)
        
        let visionOrientation = UIUtilities.imageOrientation(deviceOrientation: UIDevice.current.orientation, cameraPosition: .back)
        visionImage.orientation = visionOrientation
        
        let imageWidth = CGFloat(CVPixelBufferGetWidth(imageBuffer))
        let imageHeight = CGFloat(CVPixelBufferGetHeight(imageBuffer))
        
        let ciimage : CIImage = CIImage(cvPixelBuffer: imageBuffer)
        self.lastImage = self.convert(cmage: ciimage)
        
        if self.isDetectFaceFinish {
            detectFacesOnDevice(in: visionImage, width: imageWidth, height: imageHeight)
        }else{        
            detectFacesLivenessOnDevice(in: visionImage, width: imageWidth, height: imageHeight)
        }
    }
    
    // Convert CIImage to CGImage
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .right)
        return image
    }
}

extension SelfieCameraView{
        
    
    private func detectFacesOnDevice(in image: VisionImage, width: CGFloat, height: CGFloat) {
        
        if self.detectStartFaceContour {
            return
        }
        self.detectStartFaceContour = true
        let options = FaceDetectorOptions()
        
        // When performing latency tests to determine ideal detection settings,
        // run the app in 'release' mode to get accurate performance metrics
        options.landmarkMode = .none
        options.contourMode = .all
        options.classificationMode = .none
        options.performanceMode = .fast
        options.minFaceSize = 0.2
        
        let faceDetector = FaceDetector.faceDetector(options: options)
        
        var detectedFaces: [Face]? = nil
        do {
            detectedFaces = try faceDetector.results(in: image)
        } catch let error {
            debugPrint("Failed to detect faces with error: \(error.localizedDescription).")
        }
        self.detectStartFaceContour = false
        guard let faces = detectedFaces, !faces.isEmpty else {
            debugPrint("On-Device face detector returned no results.")
            self.isDetectFaceContourFinish = false
            
            return
        }
            
        debugPrint("Face Count - \(faces.count)")
        debugPrint("Width - \(width),  height - \(height)")
        for face in faces {
//            let normalizedRect = CGRect(
//                x: face.frame.origin.x / width,
//                y: face.frame.origin.y / height,
//                width: face.frame.size.width / width,
//                height: face.frame.size.height / height
//            )
            DispatchQueue.main.async {
                //335 x 454 px oval
//                let cHeight = ((kPortraitWidth - 40) * 335)/454
//                let cY = kPortraitHeight/2 - cHeight/2
//                let faceBound = face.frame
//                let faceMinX: CGFloat = 20
//                let faceMaxX: CGFloat = self.overlayView.width/2 - 80
//                let faceMinY: CGFloat = cY
//                let faceMaxY: CGFloat = cY + cHeight
                
                let cHeight = ((width - 40) * 335)/454
                let faceBound = face.frame
                let faceMinX: CGFloat = 20
                let faceMaxX: CGFloat = width/2 - 40
                let faceMinY: CGFloat = height/2 - cHeight/2
                let faceMaxY: CGFloat = faceMinY + cHeight
                
                debugPrint("faceDetection", "processDetectedFaces: ", faceMaxX, faceMaxY)
                if (faceBound.origin.x > faceMinX && faceBound.origin.x < faceMaxX && faceBound.origin.y > faceMinY && faceBound.origin.y < faceMaxY) {
                    self.isDetectFaceContourFinish = true
                } else {
                    self.isDetectFaceContourFinish = false
                }
                self.overlayView.isHighlighted = self.isDetectFaceFinish && self.isDetectFaceContourFinish
                //debugPrint("Coordinate - ", normalizedRect)
                debugPrint("X - \(face.frame.origin.x) Y - \(face.frame.origin.y), Frame - ", face.frame)
            }
            
        }
    }
    
    private func detectFacesLivenessOnDevice(in image: VisionImage, width: CGFloat, height: CGFloat) {
        
        if self.detectStartFace {
            return
        }
        self.detectStartFace = true
        let options = FaceDetectorOptions()
        
        // When performing latency tests to determine ideal detection settings,
        // run the app in 'release' mode to get accurate performance metrics
        options.landmarkMode = .all
        options.classificationMode = .all
        options.performanceMode = .accurate
        options.minFaceSize = 0.4
        
        let faceDetector = FaceDetector.faceDetector(options: options)
        
        var detectedFaces: [Face]? = nil
        do {
            detectedFaces = try faceDetector.results(in: image)
        } catch let error {
            debugPrint("Failed to detect faces with error: \(error.localizedDescription).")
        }
        self.detectStartFace = false
        guard let faces = detectedFaces, !faces.isEmpty else {
            debugPrint("On-Device face detector returned no results.")
            self.isDetectFaceFinish = false
            DispatchQueue.main.sync {
                
            }
            return
        }
        
        //self.isDetectFaceFinish = false
        for face in faces {
            self.isDetectFaceFinish = face.smilingProbability > 0.80 && face.leftEyeOpenProbability > 0.70 && face.rightEyeOpenProbability > 0.70
            debugPrint("Smile Probablity - ", face.smilingProbability, face.leftEyeOpenProbability, face.rightEyeOpenProbability)
            
        }
    }
}


extension SelfieCameraView{
    
        
}
