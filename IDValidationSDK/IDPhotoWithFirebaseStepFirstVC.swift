//
//  IDPhotoWithFirebaseStepFirstVC.swift
//  Medyear
//
//  Created by Bahrom Abdullaev on 9/21/19.
//  Copyright © 2019 Personiform. All rights reserved.
//

import UIKit
import AVFoundation
//import Firebase
import MLKit


protocol IDPhotoWithFirebaseStepFirstVCDelegate {
    func scanFinishedSuccessfull(_ scannedImage: UIImage?)
    func scanIDBackFinishedSuccessfull(_ barcode: Barcode?)
}

class IDPhotoWithFirebaseStepFirstVC: BaseController {
    
    @IBOutlet weak var cameraV: IDCameraView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var overlayImg: UIImageView!
    @IBOutlet weak var resultAcceptBtn: UIButton!
    @IBOutlet weak var cameraBackV: IDBackCameraView!
    @IBOutlet weak var resultAcceptBtnBg: UIView!
    private var idImage: UIImage?
    private var barcode: Barcode?
    
    var isIDFront:Bool = true
    var delegate: IDPhotoWithFirebaseStepFirstVCDelegate?
    
    deinit {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultAcceptBtnBg.backgroundColor = .themeGreyBtn
        
        self.checkPermissions()
        self.updateContent(false)
        if self.isIDFront == true {
            self.titleLbl.text = "Driver License or State ID (Front)".localize()
            self.cameraV.setupCamera()
            self.cameraV.isHidden = false
            self.cameraBackV.isHidden = true
            self.cameraV.IDDetectedAction = {(image: UIImage?) in

                self.idImage = image
                self.updateContent(true)
                let deadlineTime = DispatchTime.now() + .seconds(4)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    self.resultAcceptBtnAction(self.resultAcceptBtn)
                }
            }
        } else {
            self.titleLbl.text = "Driver License or State ID (Back)".localize()
            self.cameraBackV.setupCamera()
            self.cameraV.isHidden = true
            self.cameraBackV.isHidden = false
            self.cameraBackV.IDDetectedAction = {(barcode: Barcode?) in

                self.barcode = barcode
                self.updateContent(true)
                let deadlineTime = DispatchTime.now() + .seconds(1)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    self.resultAcceptBtnAction(self.resultAcceptBtn)
                }
            }
            let deadlineTime1 = DispatchTime.now() + .seconds(60)
            DispatchQueue.main.asyncAfter(deadline: deadlineTime1) {
                if self.barcode == nil {
                    self.updateContent(false)
                    self.overlayImg.image = UIImage(named: "cameraOverlayError")
                    self.descriptionLbl.text = "Sorry, we could not scan your ID or Driver License. Please try again".localize()
                    self.resultAcceptBtnBg.backgroundColor = .themeYellow
                    let deadlineTime = DispatchTime.now() + .seconds(2)
                    DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                        self.resultAcceptBtnAction(self.resultAcceptBtn)
                    }
                }
            }
        }
        
        self.resultAcceptBtn.setTitle("DONE".localize(), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.isIDFront{
            self.cameraV.startSession()
        }else{
            self.cameraBackV.startSession()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isIDFront{
            cameraV.stopSession()
        }else{
            cameraBackV.stopSession()
        }
    }
    
    override func fontsUI() {
        super.fontsUI()
        titleLbl.font = appFont(20)
        descriptionLbl.font = appFont(20)
        resultAcceptBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        
    }
    
    @IBAction func btnCloseAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resultAcceptBtnAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        if let del = self.delegate{
            if self.isIDFront{
                del.scanFinishedSuccessfull(self.idImage)
            }else{
                del.scanIDBackFinishedSuccessfull(self.barcode)
            }
        }
    }
    
    
    private func checkPermissions() {
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) != .authorized {
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
                DispatchQueue.main.async() { [weak self] in
                    if !granted {
                        self?.showNoPermissionsView()
                    }
                }
            }
        }
    }
    
    /**
     * Generate the view of no permission.
     */
    private func showNoPermissionsView(library: Bool = false) {
        let permissionsView = PermissionsView(frame: view.bounds)
        let title: String
        let desc: String
        
        if library {
            title = localizedString("permissions.library.title")
            desc = localizedString("permissions.library.description")
        } else {
            title = localizedString("permissions.title")
            desc = localizedString("permissions.description")
        }
        
        permissionsView.configureInView(view, title: title, description: desc, completion: { [weak self] in self?.close() })
    }
    
    internal func close() {
        //onCompletion?(nil, nil)
        //onCompletion = nil
    }
}


extension IDPhotoWithFirebaseStepFirstVC{
    
    private func updateContent(_ detected: Bool){
        
        if detected {
            //self.infoLbl.text = "ID Detected, Please take a photo of the DL/ID"
            resultAcceptBtnBg.backgroundColor = .themeGreen
            overlayImg.image = UIImage(named: "cameraOverlayDone")
            
            self.descriptionLbl.text = "Successfully scanned".localize()
        }else{
            //self.infoLbl.text = "Sorry, we could not scan your ID or Driver License. Please try again."
            resultAcceptBtnBg.backgroundColor = .themeGreyBtn
            overlayImg.image = UIImage(named: "cameraOverlay")
            if isIDFront{
                self.descriptionLbl.text = "Hold your ID card inside of the rectangle so we can scan the front. Make sure there is no glare.".localize()
            }else{
                self.descriptionLbl.text = "Hold your ID card inside of the rectangle so we can scan the back. Make sure there is no glare.".localize()
            }
            
        }
        resultAcceptBtn.isEnabled = detected
    }
   
    
}
