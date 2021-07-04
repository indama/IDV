//
//  IDBackCameraView.swift
//  Medyear
//
//  Created by Bahrom Abdullaev on 1/16/20.
//  Copyright © 2020 Personiform. All rights reserved.
//

import UIKit
import AVFoundation
import MLKit


class IDBackCameraView: UIView {
    
    var session: AVCaptureSession!
    var input: AVCaptureDeviceInput!
    var device: AVCaptureDevice!
    var imageOutput: AVCaptureStillImageOutput!
    var preview: AVCaptureVideoPreviewLayer!
    
    let cameraQueue = DispatchQueue(label: "com.medyear.IDBackCameraView.Queue")
    //private lazy var vision = MLKitVision.
    private var lastFrame: CMSampleBuffer?
    var lastBarcode: Barcode?
    
    public var currentPosition = AVCaptureDevice.Position.back
    
    var IDDetectedAction: ((_ barcode: Barcode?) -> ())?
    
    var detectStart: Bool = false
    var isDetectFinish: Bool = false
    

    let cWidth = kPortraitWidth - 30
    
    
    private lazy var animationViewTop: UIView={
        let v = UIView()
        
        
        let cHeight = (self.cWidth * 232)/345
        let cY = kPortraitHeight/2 - cHeight/2
        
        v.frame = CGRect(x: 15, y: cY, width: cWidth, height: 2.5)
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
    
    deinit {
        self.deInitialize()
    }
    
    public func setupCamera(){
        self.setUpCaptureSessionOutput()
        self.setUpCaptureSessionInput()
    }
    
    public func reSetupCamera(){
        self.deInitialize()
        self.isDetectFinish = false
        self.setupCamera()
    }
    
    private func deInitialize(){
        self.preview?.removeFromSuperlayer()
        self.session = nil
        self.input = nil
        self.imageOutput = nil
        self.preview = nil
        self.device = nil
    }
    
    public func startSession() {
        cameraQueue.async {
            if self.session != nil{
                self.session.startRunning()
            }
        }
        if !self.isDetectFinish{
            self.startAnimation()
        }
    }
    
    public func stopSession() {
        cameraQueue.async {
            if self.session != nil{
                self.session.stopRunning()
            }
        }
    }
    
    @objc
    public func startAnimation(){
        DispatchQueue.main.async {
            self.addSubview(self.animationViewTop)
            // x 232
            let cHeight = (self.cWidth * 232)/345
            self.bringSubviewToFront(self.animationViewTop)
            UIView.animate(
                withDuration: 0.9,
                animations: ({
                    self.animationViewTop.transform = CGAffineTransform(translationX: 0, y: cHeight)
                }),
                completion: ({ _ in
                    DispatchQueue.main.async {
                        UIView.animate(
                            withDuration: 0.9,
                            animations: ({
                                self.animationViewTop.transform = CGAffineTransform(translationX: 0, y: 0)
                            }),
                            completion: ({ _ in
                                if !self.isDetectFinish{
                                    self.startAnimation()
                                }
                            }))
                    }
                    
                }))
        }
        
    }
    
    public func stopAnimation(){
        
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        preview?.frame = bounds
    }
    
    
    private func createPreview() {
        preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = AVLayerVideoGravity.resizeAspectFill
        preview.frame = bounds
        layer.addSublayer(preview)
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
            self.session.sessionPreset = AVCaptureSession.Preset.high
            
            let output = AVCaptureVideoDataOutput()
            output.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA]
            let outputQueue = DispatchQueue(label: "com.medyear.IDCameraView.OutputQueue")
            output.setSampleBufferDelegate(self, queue: outputQueue)
            guard self.session.canAddOutput(output) else {
                print("Failed to add capture session output.")
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
                print("Failed to get capture device for camera position: \(cameraPosition)")
                return
            }
            do {
                try device.lockForConfiguration()
                device.activeFormat = device.formats.last!
                device.videoZoomFactor = 10
                //device.videozo
                device.unlockForConfiguration()
                
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
                try device.lockForConfiguration()
                device.videoZoomFactor = 2
                device.unlockForConfiguration()
                
                self.session.addInput(input)
                self.session.commitConfiguration()
            } catch {
                debugPrint("Failed to create capture device input: \(error.localizedDescription)")
            }
        }
    }
    
    private func captureDevice(forPosition position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        if #available(iOS 10.0, *) {
            var deviceTyps: [AVCaptureDevice.DeviceType] = [.builtInTelephotoCamera]
            if #available(iOS 13.0, *) {
                deviceTyps = [.builtInDualWideCamera, .builtInWideAngleCamera]
            } else {
                deviceTyps = [.builtInWideAngleCamera]
            }
            let discoverySession = AVCaptureDevice.DiscoverySession(
                deviceTypes: deviceTyps,
                mediaType: .video,
                position: .unspecified
            )
            return discoverySession.devices.first { $0.position == position }
        }
        
        
        return AVCaptureDevice.devices(for: .video).first
        
    }
    
}


extension IDBackCameraView: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("Failed to get image buffer from sample buffer. - ")
            return
        }
        if self.detectStart {
            return
        }
        if self.isDetectFinish{
            if self.session.isRunning {
                self.stopSession()
                debugPrint("Stopped  - ")
                DispatchQueue.main.async {
                    if let action = self.IDDetectedAction{
                        action(self.lastBarcode)
                    }
                }
            }
            return
        }
        lastFrame = sampleBuffer
        let visionImage = VisionImage(buffer: sampleBuffer)
        let visionOrientation = UIUtilities.imageOrientation(deviceOrientation: UIDevice.current.orientation, cameraPosition: .back)
        visionImage.orientation = visionOrientation
        let imageWidth = CGFloat(CVPixelBufferGetWidth(imageBuffer))
        let imageHeight = CGFloat(CVPixelBufferGetHeight(imageBuffer))
        
        
        
        detectImageBarcodeAutoMLOndevice(in: visionImage, width: imageWidth, height: imageHeight)
    }
    
    
}

extension IDBackCameraView{
    
    private func detectImageBarcodeAutoMLOndevice(in visionImage: VisionImage, width: CGFloat, height: CGFloat) {
                
        if detectStart {
            return
        }
        let options = BarcodeScannerOptions(formats: .all)
        
        let autoMLOnDeviceLabeler = BarcodeScanner.barcodeScanner(options: options)
        
                
        detectStart = true
        autoMLOnDeviceLabeler.process(visionImage) { (detectedBarcodes, error) in
            //defer { group.leave() }
            
            self.detectStart = false
            
            if let error = error {
                debugPrint("Failed to detect labels with error: \(error.localizedDescription).")
                return
            }
            guard let labels = detectedBarcodes, !labels.isEmpty else {
                return
            }
            
            for item in labels{
                if item.format == .PDF417{
                    debugPrint("Label - ", item.description)
                    debugPrint("JSON - ", item.asJson())
                    debugPrint("contact info - ", item.driverLicense?.asJson())
                    debugPrint("Address - ", item.contactInfo?.addresses?[0].asJson())
                    self.isDetectFinish = true
                    self.lastBarcode = item
                    break;
                }
            }
            
        }
        
        
        //group.wait()
    }
    
    
}


/// Defines UI-related utilitiy methods for vision detection.
public class UIUtilities {
    
    // MARK: - Public
    
    public static func addCircle(
        atPoint point: CGPoint,
        to view: UIView,
        color: UIColor,
        radius: CGFloat
        ) {
        let divisor: CGFloat = 2.0
        let xCoord = point.x - radius / divisor
        let yCoord = point.y - radius / divisor
        let circleRect = CGRect(x: xCoord, y: yCoord, width: radius, height: radius)
        let circleView = UIView(frame: circleRect)
        circleView.layer.cornerRadius = radius / divisor
        circleView.alpha = Constants.circleViewAlpha
        circleView.backgroundColor = color
        view.addSubview(circleView)
    }
    
    public static func addRectangle(_ rectangle: CGRect, to view: UIView, color: UIColor) {
        let rectangleView = UIView(frame: rectangle)
        rectangleView.layer.cornerRadius = Constants.rectangleViewCornerRadius
        rectangleView.alpha = Constants.rectangleViewAlpha
        rectangleView.backgroundColor = color
        view.addSubview(rectangleView)
    }
    
    public static func addShape(withPoints points: [NSValue]?, to view: UIView, color: UIColor) {
        guard let points = points else { return }
        let path = UIBezierPath()
        for (index, value) in points.enumerated() {
            let point = value.cgPointValue
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
            if index == points.count - 1 {
                path.close()
            }
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = color.cgColor
        let rect = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        let shapeView = UIView(frame: rect)
        shapeView.alpha = Constants.shapeViewAlpha
        shapeView.layer.addSublayer(shapeLayer)
        view.addSubview(shapeView)
    }
    
    static func imageOrientation(
        deviceOrientation: UIDeviceOrientation,
        cameraPosition: AVCaptureDevice.Position
        ) -> UIImage.Orientation {
        switch deviceOrientation {
         case .portrait:
           return cameraPosition == .front ? .leftMirrored : .right
         case .landscapeLeft:
           return cameraPosition == .front ? .downMirrored : .up
         case .portraitUpsideDown:
           return cameraPosition == .front ? .rightMirrored : .left
         case .landscapeRight:
           return cameraPosition == .front ? .upMirrored : .down
         case .faceDown, .faceUp, .unknown:
           return .up
        @unknown default:
            return .up
        }
    }
    
    public static func imageOrientation(
        fromDevicePosition devicePosition: AVCaptureDevice.Position = .back
        ) -> UIImage.Orientation {
        var deviceOrientation = UIDevice.current.orientation
        if deviceOrientation == .faceDown || deviceOrientation == .faceUp ||
            deviceOrientation == .unknown {
            deviceOrientation = currentUIOrientation()
        }
        switch deviceOrientation {
        case .portrait:
            return devicePosition == .front ? .leftMirrored : .right
        case .landscapeLeft:
            return devicePosition == .front ? .downMirrored : .up
        case .portraitUpsideDown:
            return devicePosition == .front ? .rightMirrored : .left
        case .landscapeRight:
            return devicePosition == .front ? .upMirrored : .down
        case .faceDown, .faceUp, .unknown:
            return .up
        @unknown default:
            return .up
        }
    }
    
//    public static func visionImageOrientation(
//        from imageOrientation: UIImage.Orientation
//        ) -> VisionDetectorImageOrientation {
//        switch imageOrientation {
//        case .up:
//            return .topLeft
//        case .down:
//            return .bottomRight
//        case .left:
//            return .leftBottom
//        case .right:
//            return .rightTop
//        case .upMirrored:
//            return .topRight
//        case .downMirrored:
//            return .bottomLeft
//        case .leftMirrored:
//            return .leftTop
//        case .rightMirrored:
//            return .rightBottom
//        }
//    }
//
    // MARK: - Private
    
    private static func currentUIOrientation() -> UIDeviceOrientation {
        let deviceOrientation = { () -> UIDeviceOrientation in
            switch UIApplication.shared.statusBarOrientation {
            case .landscapeLeft:
                return .landscapeRight
            case .landscapeRight:
                return .landscapeLeft
            case .portraitUpsideDown:
                return .portraitUpsideDown
            case .portrait, .unknown:
                return .portrait
            }
        }
        guard Thread.isMainThread else {
            var currentOrientation: UIDeviceOrientation = .portrait
            DispatchQueue.main.sync {
                currentOrientation = deviceOrientation()
            }
            return currentOrientation
        }
        return deviceOrientation()
    }
}

// MARK: - Constants

private enum Constants {
    static let circleViewAlpha: CGFloat = 0.7
    static let rectangleViewAlpha: CGFloat = 0.3
    static let shapeViewAlpha: CGFloat = 0.3
    static let rectangleViewCornerRadius: CGFloat = 10.0
}

