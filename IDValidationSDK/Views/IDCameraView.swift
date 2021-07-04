//
//  IDCameraView.swift
//  Medyear
//
//  Created by Bahrom Abdullaev on 9/23/19.
//  Copyright © 2019 Personiform. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import ZImageCropper
import MLKit



class IDCameraView: UIView {
    
    
    var session: AVCaptureSession!
    var input: AVCaptureDeviceInput!
    var device: AVCaptureDevice!
    var imageOutput: AVCaptureStillImageOutput!
    var preview: AVCaptureVideoPreviewLayer!
    
    let cameraQueue = DispatchQueue(label: "com.medyear.IDCameraView.Queue")
    private var lastFrame: CMSampleBuffer?
    var lastImage: UIImage?
    
    public var currentPosition = AVCaptureDevice.Position.back
    
    var changeImage: ((_ image: UIImage?) -> ())?
    var IDDetectedAction: ((_ image: UIImage?) -> ())?
    
    var detectStartLabel: Bool = false
    var detectStartText: Bool = false
    var detectStartFace: Bool = false
    var isDetectLabelFinish: Bool = false
    var isDetectFaceFinish: Bool = false
    var isDetectTextFinish: Bool = false
    
    var IDDetected: Bool{isDetectFaceFinish && isDetectTextFinish}//&& isDetectLabelFinish }
    var detectStart: Bool {detectStartFace || detectStartText || detectStartLabel}
    
    var labelConfidance: Float = 0.0
    var faceConfidance: Float = 0.0
    var textConfidance: Float = 0.0
    
    let cWidth = kPortraitWidth - 30
    
    private lazy var imageView: UIImageView = {
        let iv: UIImageView = UIImageView(frame: self.bounds)
        iv.contentMode = .scaleAspectFit
        let b = CGRect(x: ((self.lastImage?.size.width ?? 360) - self.width)/CGFloat(2.0), y: ((self.lastImage?.size.height ?? 480) - self.height)/CGFloat(2.0), width: self.width, height: self.height)
        debugPrint("Bounds to Crop - ", b)
        debugPrint("Image size - ", self.lastImage?.size ?? "")
        iv.image = self.cropToBounds(img: self.lastImage!, width: self.width, height: self.height)
        debugPrint("Image Bounds - ", iv.bounds)
        return iv
    }()
    
    private lazy var animationViewTop: UIView = {
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
    
    public func setupCamera() {
        self.setUpCaptureSessionOutput()
        self.setUpCaptureSessionInput()
    }
    
    public func reSetupCamera(){
        self.deInitialize()
        self.isDetectFaceFinish = false
        self.isDetectTextFinish = false
        self.isDetectLabelFinish = false
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
        if !self.IDDetected{
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
                                if !self.IDDetected{
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
                for item in device.formats{
                    debugPrint("Format - ", item.formatDescription)
                }
                //debugPrint("Active Format Before - ", device.activeFormat.formatDescription)
                //debugPrint("Device Zoom - ", device.videoZoomFactor)
                try device.lockForConfiguration()
                device.activeFormat = device.formats.last!
                device.videoZoomFactor = 10
                //device.videozo
                device.unlockForConfiguration()
                
                //debugPrint("Active Format After - ", device.activeFormat.formatDescription)
                //debugPrint("Device Zoom - ", device.videoZoomFactor)
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


extension IDCameraView: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("Failed to get image buffer from sample buffer. - ")
            return
        }
        if self.detectStart {
            return
        }
        
        if self.IDDetected{
            guard let imageBuffer = CMSampleBufferGetImageBuffer(lastFrame!) else {
                debugPrint("Failed to get image buffer from sample buffer. - ")
                return
            }
            let ciimage : CIImage = CIImage(cvPixelBuffer: imageBuffer)
            self.lastImage = self.convert(cmage: ciimage)
            self.stopSession()
            if self.session.isRunning {
                debugPrint("Stopped  - ")
                DispatchQueue.main.async {
                    //self.addSubview(self.imageView)
                    if let action = self.IDDetectedAction{
                        action(self.lastImage)
                    }
                }
            }
            return
        }
        debugPrint("Result - ", self.isDetectFaceFinish ? "Face Detected," : "Face Not Detected,", self.isDetectTextFinish ? "Text Detected," : "Text not Detected,", self.isDetectLabelFinish ? "Label Detected" : "Label not detected")
        lastFrame = sampleBuffer
        let visionImage = VisionImage(buffer: sampleBuffer)
        //let orientation =
        //
        let visionOrientation = UIUtilities.imageOrientation(deviceOrientation: UIDevice.current.orientation, cameraPosition: .back)
        visionImage.orientation = visionOrientation
        let imageWidth = CGFloat(CVPixelBufferGetWidth(imageBuffer))
        let imageHeight = CGFloat(CVPixelBufferGetHeight(imageBuffer))
        
        if !self.isDetectTextFinish{
            recognizeTextOnDevice(in: visionImage, width: imageWidth, height: imageHeight)
        }else if !self.isDetectFaceFinish {
            detectFacesOnDevice(in: visionImage, width: imageWidth, height: imageHeight)
        }else if !self.isDetectLabelFinish{
            detectImageLabelsAutoMLOndevice(in: visionImage, width: imageWidth, height: imageHeight)
        }
    }
    
    // Convert CIImage to CGImage
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        debugPrint("CGI Image Width and Height - ", cgImage.width, cgImage.height)
        let image:UIImage = UIImage(cgImage: cgImage, scale: 1, orientation: .right)
        debugPrint("Image Width and Height - ", image.size.width, image.size.height)
        return image
    }
    
    func cropToBounds(img: UIImage, width: CGFloat, height: CGFloat) -> UIImage {

        let cgimage = img.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)

        posX = 0
        posY = ((contextSize.height - self.height) / 2)
        let aspect = self.height/contextSize.height
        cgwidth = contextSize.width * aspect
        cgheight = self.height

        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        debugPrint("Rect - ", rect)
        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!

        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: img.scale, orientation: .right)
        debugPrint("Size - ", image.size)
        return image
    }
    
    //    // Create a UIImage from sample buffer data
    //    func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage  {
    //        // Get a CMSampleBuffer's Core Video image buffer for the media data
    //        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
    //        // Lock the base address of the pixel buffer
    //        CVPixelBufferLockBaseAddress(imageBuffer, [])
    //
    //        // Get the number of bytes per row for the pixel buffer
    //        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
    //
    //        // Get the number of bytes per row for the pixel buffer
    //        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
    //        // Get the pixel buffer width and height
    //        let width = CVPixelBufferGetWidth(imageBuffer)
    //        let height = CVPixelBufferGetHeight(imageBuffer)
    //
    //        // Create a device-dependent RGB color space
    //        let colorSpace = CGColorSpaceCreateDeviceRGB()
    //
    //        // Create a bitmap graphics context with the sample buffer data
    //        guard let context1 = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: 0) else { return UIImage()}
    //
    //        // Create a Quartz image from the pixel data in the bitmap graphics context
    //        guard let quartzImage = context1.makeImage() else { return UIImage() }
    //        // Unlock the pixel buffer
    //        CVPixelBufferUnlockBaseAddress(imageBuffer, [])
    //
    //        // Create an image object from the Quartz image
    //        //I modified this line: [UIImage imageWithCGImage:quartzImage]; to the following to correct the orientation:
    //        let image =  UIImage(cgImage: quartzImage, scale: UIScreen.main.scale, orientation: .right)
    //
    //
    //        return image
    //    }
}

extension IDCameraView{
    
    private func detectImageLabelsAutoMLOndevice( in visionImage: VisionImage, width: CGFloat, height: CGFloat) {
        
        if self.detectStartLabel {
            return
        }
        self.detectStartLabel = true
        
        let options = ImageLabelerOptions()
        options.confidenceThreshold = 0.6
        let labeler = ImageLabeler.imageLabeler(options: options)
        labeler.process(visionImage) { detectedLabels, error in
            self.detectStartLabel = false
            if let error = error {
                self.isDetectLabelFinish = false
                debugPrint("Failed to detect labels with error: \(error.localizedDescription).")
                return
            }
            
            guard let labels = detectedLabels, !labels.isEmpty else {
                debugPrint("Label is empty!!!")
                self.isDetectLabelFinish = false
                return
            }
            self.labelConfidance = self.getIDConfidanceAvg(labels: labels)
            self.isDetectLabelFinish = self.labelConfidance > 50
                        
        }
    }
    
    private func recognizeTextOnDevice(in image: VisionImage, width: CGFloat, height: CGFloat) {
        
        if self.detectStartText {
            return
        }
        let textRecognizer = TextRecognizer.textRecognizer()
        self.detectStartText = true
        
        textRecognizer.process(image) { text, error in
            
            self.detectStartText = false
            guard error == nil, let text = text else {
                debugPrint("On-Device text recognizer error: ", error.debugDescription)
                self.isDetectTextFinish = false
                return
            }
            // Blocks.
            var count: Int = 0
            var keywordsCount: Int = 0
            for block in text.blocks {
                                
                for line in block.lines{
                    for element in line.elements {
                        count += 1
                        //DL Lincense Card Driver Identification ID
                        //DRIVER LICENSE IDENTIFICATION IDENTITY
                        let txt = element.text.lowercased()
                        if txt.contains("driver") || txt.contains("license") || txt.contains("card") || txt.contains("identification") || txt.contains("identity"){ //|| txt.starts(with: "dl") || txt.starts(with :"id") {
                            keywordsCount += 1
                        }
                    }
                }
            }
            self.isDetectTextFinish = keywordsCount >= 1
            debugPrint("Count - \(count), Keyword Count - \(keywordsCount)")
        }
    }
    
    private func detectFacesOnDevice(in image: VisionImage, width: CGFloat, height: CGFloat) {
        
        if self.detectStartFace {
            return
        }
        self.detectStartFace = true
        let options = FaceDetectorOptions()
        
        // When performing latency tests to determine ideal detection settings,
        // run the app in 'release' mode to get accurate performance metrics
        options.landmarkMode = .all
        //options.contourMode = .all
        options.classificationMode = .all
        options.performanceMode = .accurate
        options.minFaceSize = 0.2
        
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
                
        debugPrint("Face Count - \(faces.count)")
        debugPrint("Width - \(width),  height - \(height)")
        for face in faces {
            DispatchQueue.main.async {
                
                //self.overlayView.isHighlighted = self.isDetectFaceFinish && self.isDetectFaceContourFinish
                //debugPrint("Coordinate - ", normalizedRect)
                //let cHeight = (self.cWidth * 232)/345
                let cHeight = ((width - 30) * 232)/345
                let faceBound = face.frame
                let faceMinX: CGFloat = 15
                let faceMaxX: CGFloat = width - 30
                let faceMinY: CGFloat = height/2 - cHeight/2
                let faceMaxY: CGFloat = faceMinY + cHeight
                
                debugPrint("faceDetection", "processDetectedFaces: ", faceMaxX, faceMaxY)
                debugPrint("faceDetection", "processDetectedFaces: ", faceMinX, faceMinY)
                if (faceBound.origin.x > faceMinX && faceBound.origin.x < faceMaxX && faceBound.origin.y > faceMinY && faceBound.origin.y < faceMaxY) {
                    self.isDetectFaceFinish = true
                } else {
                    self.isDetectFaceFinish = false
                }
                debugPrint("X - \(face.frame.origin.x) Y - \(face.frame.origin.y), Frame - ", face.frame)
            }
            
        }
    }
    
    
}



extension IDCameraView{
    
    private func getIDConfidanceAvg(labels: [ImageLabel]) -> Float{
        
        var posterConfidence: Float = 0
        var count: Float = 0.0
        for label in labels{
            if label.text == "Poster" || label.text == "Paper" {
                count += 1
                posterConfidence += (label.confidence ?? 0)
            }
        }
        if count > 0 {
            debugPrint("Poster Found - ", posterConfidence, count)
            return (posterConfidence/count)*100
        }else{
            debugPrint("Poster Not Found - ", labels.count)
        }
        return 0
    }
    
    func isIDDetected() -> Bool{
        
        return false
    }
}
