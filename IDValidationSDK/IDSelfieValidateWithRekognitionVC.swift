//
//  IDSelfieValidateWithRekognitionVC.swift
//  Medyear
//
//  Created by Bahrom Abdullaev on 9/21/19.
//  Copyright © 2019 Personiform. All rights reserved.
//

import UIKit
import AWSRekognition

enum  ManualDocumentValidationType: Int{
    
    case pending = 0
    case approved = 1
    case rejected = 2
}

protocol IDSelfieValidateWithRekognitionVCDelegate {
    func scannedSuccessfull(_ image: UIImage?)
}


class IDSelfieValidateWithRekognitionVC: BaseController {
    
    @IBOutlet weak var cameraV: SelfieCameraView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var resultAcceptBtn: UIButton!
    @IBOutlet weak var overlayImg: UIImageView!
    @IBOutlet weak var extraLbl: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var resultAcceptBtnBg: UIView!
    public var selfieImage: UIImage?
    var idFrontImage: UIImage?
    var attemptCount: Int = UserDefaults.IDAttemptCount()
    
    private lazy var  rekognitionObject:AWSRekognition? = AWSRekognition.default()
    
    var attemptFailed: ((_ atmptCount: Int) -> ())?
    var manualUpdoadDone: ((_ completed: Bool) -> ())?
    var comparisonDone: ((_ completed: Bool) -> ())?
    lazy var validation: DirectValidationStatusModel = DirectValidationStatusModel()    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cameraV.setupCamera()
        
        resultAcceptBtnBg.backgroundColor = .themeGreyBtn
        resultAcceptBtn.isEnabled = false
        
        self.cameraV.faceDetected = {(image: UIImage?, isDetectFace: Bool, isSmileDetect: Bool) in
            self.cameraV.stopSession()
            self.selfieImage = image
            self.updateContent(image, isDetectFace, isSmileDetect)
        }
        self.extraLbl.isHidden = true
        self.activityIndicator.isHidden = true
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.cameraV.startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraV.stopSession()
    }
    
    override func fontsUI() {
        super.fontsUI()
        resultAcceptBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
    }
    
    @IBAction func btnCloseAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resultAcceptBtnAction(_ sender: Any) {
                        
    }
   
    
    private func updateContent(_ image: UIImage?, _ isDetectFace: Bool, _ isSmileDetect: Bool) -> Void{
        
        DispatchQueue.main.async {
                        
            if isDetectFace && isSmileDetect{
                self.resultAcceptBtn.isEnabled = true
                self.resultAcceptBtnBg.backgroundColor = .themeBlue
                self.resultAcceptBtn.setTitle("OKAY, LOOKS GOOD", for: .normal)
                let deadlineTime = DispatchTime.now() + .seconds(1)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    
                    if let source = self.idFrontImage?.jpegData(compressionQuality: 1), let target = self.selfieImage?.jpegData(compressionQuality: 1){
                        self.faceComparisonWithAWS(source: source, target: target)
                    }
                }
                return
            }else{
                self.resultAcceptBtn.isEnabled = false
                self.resultAcceptBtnBg.backgroundColor = .themeGreyBtn
                self.resultAcceptBtn.setTitle("PROCESSING", for: .normal)
            }
            if !isSmileDetect{
                //self.titleLbl.text = "Position your face so that it fills the oval, and smile for the camera."
            }else{
                //self.titleLbl.text = "Position your face so that it fills the oval, and smile for the camera."
                //"Make sure good lighting condition and bring your face near to camera until oval changes to green"
            }
            
        }
    }
}



extension IDSelfieValidateWithRekognitionVC{
    
    func faceComparisonWithAWS(source image1:Data, target image2: Data) -> Void {
        
        self.descriptionLbl.isHidden = true
        self.resultAcceptBtnBg.isHidden = true
        self.extraLbl.isHidden = false
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        let request: AWSRekognitionCompareFacesRequest = AWSRekognitionCompareFacesRequest()
        request.similarityThreshold = 85
        let source: AWSRekognitionImage = AWSRekognitionImage()
        source.bytes = image1
        let target: AWSRekognitionImage = AWSRekognitionImage()
        target.bytes = image2
        request.sourceImage = source
        request.targetImage = target
        //self.view.showHUD("", subTitle: "")
        rekognitionObject?.compareFaces(request, completionHandler: { (response, error) in
            
            DispatchQueue.main.async {
                guard let r = response else{
                    debugPrint("Error - ", error?.localizedDescription ?? "")
//                    self.view.showErrorHUD("Sorry, we could not match your selfie with your ID or Driver License photos. Please try again.", title: "")
                    self.comparisonFailed()
                    return
                }
                if let matchedFaces = r.faceMatches, matchedFaces.count > 0{
                    var hasSimiliraty: Bool = false
                    for item in matchedFaces {
                        if let similiraty = item.similarity, similiraty.floatValue >= 85 {
                            hasSimiliraty = true
                            break
                        }
                    }
                    if hasSimiliraty{
                        self.validation.faceImageId = nil
                        self.validation.frontImageId = nil
                        self.validation.Success = true
                        self.validation.Message = "Face Matched".localize()
//                        DirectService.sharedInstance.validationStatus2(self.validation, success: { (code, result) in
//                            DispatchQueue.main.async {
//                                self.view.showSuccessHUD("Face Matched".localize(), subTitle: "", true)
//                                self.pushToDirectEmail()
//                            }
//
//                        }) { (code, error) in
//                            self.view.showErrorHUD(error)
//                            self.comparisonFailed()
//                        }
                    }else{
//                        self.view.showErrorHUD("Sorry, we could not match your selfie with your ID or Driver License photos. Please try again.", title: "")
                        self.comparisonFailed()
                    }
                }else{
//                    self.view.showErrorHUD("Sorry, we could not match your selfie with your ID or Driver License photos. Please try again.", title: "")
                    self.comparisonFailed()
                }
                debugPrint("Response - ", r.description() ?? "")
            }
            
        })
    }
    
    
    func pushToDirectEmail() {
        DispatchQueue.main.async {
            self.resultAcceptBtn.isEnabled = true
            self.extraLbl.text = "Successfully captured".localize()
            self.activityIndicator.isHidden = true
            self.descriptionLbl.isHidden = true
            self.resultAcceptBtnBg.isHidden = false
            self.resultAcceptBtnBg.backgroundColor = .themeGreen
            self.resultAcceptBtn.setTitle("DONE".localize(), for: .normal)
            self.overlayImg.image = UIImage(named: "cameraFaceOverlayDone")
            let deadlineTime = DispatchTime.now() + .seconds(2)
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                if let comparison = self.comparisonDone{
                    comparison(true)
                    self.dismiss(animated: true) {
                        
                    }
                }
            }
        }
    }
    
    
    func comparisonFailed() -> Void {
        
        DispatchQueue.main.async {
//            let manualStatus = UserService.sharedInstance.currentUser.manualDocumentValidationType ?? .pending
            let manualStatus:ManualDocumentValidationType = .pending
            self.descriptionLbl.text = "Sorry, we could not scan your ID or Driver License. Please try again".localize()
            self.overlayImg.image = UIImage(named: "cameraFaceOverlayError")
            self.resultAcceptBtnBg.backgroundColor = .themeYellow
            self.resultAcceptBtn.setTitle("TRY AGAIN".localize()+"(\(3 - self.attemptCount))", for: .normal)
            self.resultAcceptBtnBg.isHidden = false
            self.descriptionLbl.isHidden = false
            self.extraLbl.isHidden = true
            self.activityIndicator.isHidden = true
            
            if  self.attemptCount == 3 || manualStatus == .rejected {
                let deadlineTime = DispatchTime.now() + .seconds(2)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    let alert: UIAlertController = UIAlertController(title: "", message: "Sorry, we’re having trouble verifying your identity instantly. We will need to review manually. Please be on the lookout for an email or app notification from us that your verification has been completed.".localize(), preferredStyle: .alert)
                    let action: UIAlertAction = UIAlertAction(title: "OK".localize(), style: .cancel) { (action) in
                        self.submitToManualValidation()
                    }
                    alert.addAction(action)
//                    alert.show()
                }
                return
            }
                        
            let deadlineTime = DispatchTime.now() + .seconds(5)
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                self.dismiss(animated: true) {
                    if let failed = self.attemptFailed {
                        failed(self.attemptCount + 1)
                    }
                }
            }
            
        }
        
    }
    
    func submitToManualValidation() -> Void {
        
        HUDController.sharedController.contentView
            = HUDContentView.ProgressStatusView(title: "Loading".localize(), subtitle:"Submitting to Manual Validation. This may take a few minutes, please DO NOT close the app.".localize())
        HUDController.sharedController.show()
        let imageType = "8F433D39-ADFA-4AD3-A7AC-2E969C8C7017"
        let front = self.idFrontImage?.jpegData(compressionQuality: 1)?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        let face = self.selfieImage?.jpegData(compressionQuality: 1)?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        if let f = front, let selfie = face {
//            DirectService.sharedInstance.directUploadImageWithType(f, imageType, success: { (code, result) in
//                if let id = result{
//                    self.validation.frontImageId = (id as! NSNumber).intValue
//
//                    DirectService.sharedInstance.directUploadImageWithType(selfie, imageType, success: { (code, result) in
//                        if let id = result{
//                            self.validation.faceImageId = (id as! NSNumber).intValue
//                            self.validation.Success = false
//                            DirectService.sharedInstance.validationStatus2(self.validation, success: { (code, result) in
//                                DispatchQueue.main.async {
//                                    self.view.showSuccessHUD("", subTitle: "", true)
//                                    UserService.sharedInstance.currentUser.manualDocumentValidation = ManualDocumentValidationType.pending.rawValue
//                                    UserDefaults.setUserData(UserService.sharedInstance.currentUser.toJSONString())
//                                    if let m = self.manualUpdoadDone{
//                                        m(true)
//                                    }
//                                    self.dismiss(animated: true) {
//
//                                    }
//                                }
//
//                            }) { (code, error) in
//                                self.showErrorHUD(error)
//                            }
//                        }else{
//                            self.showErrorHUD(MDErrorModel(jsonString: "{}"), title: TRL("Response, Wrong Data"))
//                        }
//
//                    }, failure: { (code, error) in
//                        self.showErrorHUD(error)
//                    })
//                }else{
//                    self.showErrorHUD(MDErrorModel(jsonString: "{}"), title: TRL("Response, Wrong Data"))
//                }
//
//            }, failure: { (code, error) in
//                self.showErrorHUD(error)
//            })
            
        }
    }
}
