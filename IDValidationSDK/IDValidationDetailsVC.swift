//
//  IDValidationBaseVC.swift
//  Medyear
//
//  Created by Rahimjon Abdullayev on 4/4/21.
//  Copyright © 2021 Personiform. All rights reserved.
//

import UIKit
//import SideMenuSwift
//import Firebase
import AWSRekognition
import MLKit

enum IDValidationCase {
    case cardFront
    case cardBack
    case face
}

public class IDValidationDetailsVC: BaseController {

    private var idFrontImage: UIImage?
    private var isComparisonDone: Bool = false
    private var idBackBarcode: Barcode?
    var currentPage = 0
    var indexCount = 0
    
    lazy var descriptionLbl:UILabel = {
        let l = UILabel()
        l.text = "In order to obtain a Medyear Plus account, we must first verify your identity. Please provide the following information in order to proceed with the identity verification."
        l.numberOfLines = 0
        l.lineBreakMode = .byWordWrapping
        l.textAlignment = .center
        return l
    }()
    
    lazy var scrollView:UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    lazy var contentView: UIView = {
        let v = UIView()
        return v
    }()
    
    //MARK: First Step
    
    lazy var firstViewCon: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 2
        v.backgroundColor = .white
        return v
    }()
    
    lazy var border1: UIView = {
        let v = UIView()
        v.backgroundColor = .lightGray
        return v
    }()
    
    lazy var firstHeaderCon: UIView = {
        let v = UIView()
        return v
    }()

    lazy var firstIndexBg: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBlue
        v.layer.cornerRadius = 20
        v.clipsToBounds = true
        return v
    }()
    
    lazy var firstIndex:UILabel = {
        let l = UILabel()
        l.text = "1"
        l.textColor = .white
        l.textAlignment = .center
        l.font = UIFont.systemFont(ofSize: 16)
        return l
    }()
    lazy var firstSummi: UIImageView = {
        let v = UIImageView()
        v.tintColor = .lightGray
        v.image = UIImage(named: "arrow_down_normal")?.withRenderingMode(.alwaysTemplate)
        v.contentMode = .scaleAspectFit
        return v
    }()
    lazy var firstDoneIV: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(named: "ic_done")
        v.contentMode = .scaleAspectFit
        return v
    }()
    lazy var firstIV: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(named: "identity1")
        v.contentMode = .scaleAspectFit
        return v
    }()
    lazy var firstStartBtn: UIButton = {
        let b = UIButton()
        b.setTitle("Start", for: .normal)
        b.tag = 1
        b.backgroundColor = .systemBlue
        b.layer.cornerRadius = 4
        b.addTarget(self, action: #selector(startBtnAction(_:)), for: .touchUpInside)
        return b
    }()
    lazy var firstToggleBtn: UIButton = {
        let b = UIButton()
        b.setTitle("", for: .normal)
        b.tag = 1
        b.addTarget(self, action: #selector(toggleBtnAction(_:)), for: .touchUpInside)
        return b
    }()
    
    lazy var firstTitle:UILabel = {
        let l = UILabel()
        l.text = "Driver License or State ID (Front)"
        l.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return l
    }()
    
    lazy var firstDesctiption:UILabel = {
        let l = UILabel()
        l.text = "Scan front side of your ID"
        l.font = UIFont.systemFont(ofSize: 14)
        l.textAlignment = .center
        return l
    }()
    
    //MARK: Second Step
    
    lazy var secondViewCon: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 2
        v.backgroundColor = .white
        return v
    }()
    
    lazy var border2: UIView = {
        let v = UIView()
        v.backgroundColor = .lightGray
        return v
    }()
    
    lazy var secondHeaderCon: UIView = {
        let v = UIView()
        return v
    }()

    lazy var secondIndexBg: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBlue
        v.layer.cornerRadius = 20
        v.clipsToBounds = true
        return v
    }()
    
    lazy var secondIndex:UILabel = {
        let l = UILabel()
        l.text = "2"
        l.textColor = .white
        l.textAlignment = .center
        l.font = UIFont.systemFont(ofSize: 16)
        return l
    }()
    lazy var secondSummi: UIImageView = {
        let v = UIImageView()
        v.tintColor = .lightGray
        v.image = UIImage(named: "arrow_down_normal")?.withRenderingMode(.alwaysTemplate)
        v.contentMode = .scaleAspectFit
        return v
    }()
    lazy var secondDoneIV: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(named: "ic_done")
        v.contentMode = .scaleAspectFit
        return v
    }()
    lazy var secondIV: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(named: "identity1")
        v.contentMode = .scaleAspectFit
        return v
    }()
    lazy var secondStartBtn: UIButton = {
        let b = UIButton()
        b.setTitle("Start", for: .normal)
        b.tag = 2
        b.backgroundColor = .systemBlue
        b.layer.cornerRadius = 4
        b.addTarget(self, action: #selector(startBtnAction(_:)), for: .touchUpInside)
        return b
    }()
    lazy var secondToggleBtn: UIButton = {
        let b = UIButton()
        b.setTitle("", for: .normal)
        b.tag = 2
        b.addTarget(self, action: #selector(toggleBtnAction(_:)), for: .touchUpInside)
        return b
    }()
    
    lazy var secondTitle:UILabel = {
        let l = UILabel()
        l.text = "Driver License or State ID (Front)"
        l.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return l
    }()
    
    lazy var secondDesctiption:UILabel = {
        let l = UILabel()
        l.text = "Scan front side of your ID"
        l.font = UIFont.systemFont(ofSize: 14)
        l.textAlignment = .center
        return l
    }()
    
    //MARK: Third Step
    
    lazy var thirdViewCon: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 2
        v.backgroundColor = .white
        return v
    }()
    
    lazy var border3: UIView = {
        let v = UIView()
        v.backgroundColor = .lightGray
        return v
    }()
    
    lazy var thirdHeaderCon: UIView = {
        let v = UIView()
        return v
    }()

    lazy var thirdIndexBg: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBlue
        v.layer.cornerRadius = 20
        v.clipsToBounds = true
        return v
    }()
    
    lazy var thirdIndex:UILabel = {
        let l = UILabel()
        l.text = "2"
        l.textColor = .white
        l.textAlignment = .center
        l.font = UIFont.systemFont(ofSize: 16)
        return l
    }()
    lazy var thirdSummi: UIImageView = {
        let v = UIImageView()
        v.tintColor = .lightGray
        v.image = UIImage(named: "arrow_down_normal")?.withRenderingMode(.alwaysTemplate)
        v.contentMode = .scaleAspectFit
        return v
    }()
    lazy var thirdDoneIV: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(named: "ic_done")
        v.contentMode = .scaleAspectFit
        return v
    }()
    lazy var thirdIV: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(named: "identity1")
        v.contentMode = .scaleAspectFit
        return v
    }()
    lazy var thirdStartBtn: UIButton = {
        let b = UIButton()
        b.setTitle("Start", for: .normal)
        b.tag = 2
        b.backgroundColor = .systemBlue
        b.layer.cornerRadius = 4
        b.addTarget(self, action: #selector(startBtnAction(_:)), for: .touchUpInside)
        return b
    }()
    lazy var thirdToggleBtn: UIButton = {
        let b = UIButton()
        b.setTitle("", for: .normal)
        b.tag = 2
        b.addTarget(self, action: #selector(toggleBtnAction(_:)), for: .touchUpInside)
        return b
    }()
    
    lazy var thirdTitle:UILabel = {
        let l = UILabel()
        l.text = "Driver License or State ID (Front)"
        l.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return l
    }()
    
    lazy var thirdDesctiption:UILabel = {
        let l = UILabel()
        l.text = "Scan front side of your ID"
        l.font = UIFont.systemFont(ofSize: 14)
        l.textAlignment = .center
        return l
    }()
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .lightGray
        setupView()
        
        firstTitle.text = "Driver License or State ID (Front)"
        firstDesctiption.text = "Scan front side of your ID"
        secondTitle.text = "Driver License or State ID (Back)"
        secondDesctiption.text = "Scan back side of your ID"
        thirdTitle.text = "Selfie Photo"
        thirdDesctiption.text = "Provide your selfie photo"
    }

    override func navigationSetup() {
        self.changeNavigationTitleView("ID Validation".localize())
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationItem.leftBarButtonItem = self.backBarButton
    }
    
    func setupView() {
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(contentView)
        contentView.addSubview(descriptionLbl)
        
        self.scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        self.contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalTo(self.view.snp.width)
            make.height.equalTo(self.view.snp.height).priority(750)
        }
        descriptionLbl.snp.makeConstraints { (make) in
            make.left.top.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(120)
        }
        
        //step first
        contentView.addSubview(firstViewCon)
        firstViewCon.addSubview(firstHeaderCon)
        firstHeaderCon.addSubview(firstIndexBg)
        firstIndexBg.addSubview(firstDoneIV)
        firstIndexBg.addSubview(firstIndex)
        firstHeaderCon.addSubview(firstTitle)
        firstHeaderCon.addSubview(firstSummi)
        firstHeaderCon.addSubview(border1)
        firstHeaderCon.addSubview(firstToggleBtn)
        firstViewCon.addSubview(firstDesctiption)
        firstViewCon.addSubview(firstIV)
        firstViewCon.addSubview(firstStartBtn)
        
        firstViewCon.snp.makeConstraints { (make) in
            make.top.equalTo(descriptionLbl.snp.bottom).offset(20)
            make.left.right.equalTo(descriptionLbl)
            make.height.equalTo(360)
        }
        firstHeaderCon.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(66)
        }
        firstIndexBg.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.left.equalTo(10)
            make.centerY.equalToSuperview()
        }
        firstDoneIV.snp.makeConstraints { (make) in
            make.width.equalTo(19)
            make.center.equalToSuperview()
        }
        firstIndex.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        firstTitle.snp.makeConstraints { (make) in
            make.left.equalTo(firstIndexBg.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
        firstSummi.snp.makeConstraints { (make) in
            make.width.height.equalTo(12)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-15)
        }
        border1.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.bottom.left.right.equalToSuperview()
        }
        firstToggleBtn.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        firstDesctiption.snp.makeConstraints { (make) in
            make.top.equalTo(firstHeaderCon.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
        }
        firstIV.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(firstDesctiption.snp.bottom).offset(10)
            make.height.equalTo(140)
        }
        firstStartBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(firstIV.snp.bottom).offset(30)
            make.width.equalTo(225)
            make.height.equalTo(44)
        }

        //second step
        contentView.addSubview(secondViewCon)
        secondViewCon.addSubview(secondHeaderCon)
        secondHeaderCon.addSubview(secondIndexBg)
        secondIndexBg.addSubview(secondDoneIV)
        secondIndexBg.addSubview(secondIndex)
        secondHeaderCon.addSubview(secondTitle)
        secondHeaderCon.addSubview(secondSummi)
        secondHeaderCon.addSubview(border2)
        secondHeaderCon.addSubview(secondToggleBtn)
        secondViewCon.addSubview(secondDesctiption)
        secondViewCon.addSubview(secondIV)
        secondViewCon.addSubview(secondStartBtn)
        
        secondViewCon.snp.makeConstraints { (make) in
            make.top.equalTo(firstViewCon.snp.bottom).offset(10)
            make.left.right.equalTo(firstViewCon)
            make.height.equalTo(360)
        }
        secondHeaderCon.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(66)
        }
        secondIndexBg.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.left.equalTo(10)
            make.centerY.equalToSuperview()
        }
        secondDoneIV.snp.makeConstraints { (make) in
            make.width.equalTo(19)
            make.center.equalToSuperview()
        }
        secondIndex.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        secondTitle.snp.makeConstraints { (make) in
            make.left.equalTo(secondIndexBg.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
        secondSummi.snp.makeConstraints { (make) in
            make.width.height.equalTo(12)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-15)
        }
        border2.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.bottom.left.right.equalToSuperview()
        }
        secondToggleBtn.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        secondDesctiption.snp.makeConstraints { (make) in
            make.top.equalTo(secondHeaderCon.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
        }
        secondIV.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(secondDesctiption.snp.bottom).offset(10)
            make.height.equalTo(140)
        }
        secondStartBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(secondIV.snp.bottom).offset(30)
            make.width.equalTo(225)
            make.height.equalTo(44)
        }
        
        //third step
        contentView.addSubview(thirdViewCon)
        thirdViewCon.addSubview(thirdHeaderCon)
        thirdHeaderCon.addSubview(thirdIndexBg)
        thirdIndexBg.addSubview(thirdDoneIV)
        thirdIndexBg.addSubview(thirdIndex)
        thirdHeaderCon.addSubview(thirdTitle)
        thirdHeaderCon.addSubview(thirdSummi)
        thirdHeaderCon.addSubview(border3)
        thirdHeaderCon.addSubview(thirdToggleBtn)
        thirdViewCon.addSubview(thirdDesctiption)
        thirdViewCon.addSubview(thirdIV)
        thirdViewCon.addSubview(thirdStartBtn)
        
        thirdViewCon.snp.makeConstraints { (make) in
            make.top.equalTo(secondViewCon.snp.bottom).offset(10)
            make.left.right.equalTo(secondViewCon)
            make.height.equalTo(360)
            make.bottom.equalToSuperview().offset(-20)
        }
        thirdHeaderCon.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(66)
        }
        thirdIndexBg.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.left.equalTo(10)
            make.centerY.equalToSuperview()
        }
        thirdDoneIV.snp.makeConstraints { (make) in
            make.width.equalTo(19)
            make.center.equalToSuperview()
        }
        thirdIndex.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        thirdTitle.snp.makeConstraints { (make) in
            make.left.equalTo(thirdIndexBg.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
        thirdSummi.snp.makeConstraints { (make) in
            make.width.height.equalTo(12)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-15)
        }
        border2.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.bottom.left.right.equalToSuperview()
        }
        thirdToggleBtn.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        thirdDesctiption.snp.makeConstraints { (make) in
            make.top.equalTo(thirdHeaderCon.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
        }
        thirdIV.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(thirdDesctiption.snp.bottom).offset(10)
            make.height.equalTo(140)
        }
        thirdStartBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(thirdIV.snp.bottom).offset(30)
            make.width.equalTo(225)
            make.height.equalTo(44)
        }
    }

    
    //MARK: Actions
    
    @objc func startBtnAction(_ sender: UIButton){
        switch sender.tag {
        case 1:
            self.validationAction(.cardFront)
            break
        case 2:
            self.validationAction(.cardBack)
            break
        case 3:
            self.validationAction(.face)
            break
        default:
            break
        }
        
    }
    
    @objc func toggleBtnAction(_ sender: UIButton){
        UIView.animate(withDuration: 0.1) {
            switch sender.tag {
            case 1:
                if sender.isSelected {
//                    self.FirstHeight.constant = 66
                    self.firstIndexBg.backgroundColor = .themeLightGrey
                    self.firstIndex.textColor = .gray
                    self.firstSummi.image = UIImage(named: "arrow_down_normal")?.withRenderingMode(.alwaysTemplate)
                }else{
                    self.firstIndexBg.backgroundColor = .themeBlue
                    self.firstIndex.textColor = .white
//                    self.FirstHeight.constant = 360
                    self.firstSummi.image = UIImage(named: "arrow_up_normal")?.withRenderingMode(.alwaysTemplate)
                }
                break
            case 2:
                if sender.isSelected {
                    self.secondIndexBg.backgroundColor = .themeLightGrey
                    self.secondIndex.textColor = .gray
//                    self.SecondHeight.constant = 66
                    self.secondSummi.image = UIImage(named: "arrow_down_normal")?.withRenderingMode(.alwaysTemplate)
                }else{
                    self.secondIndexBg.backgroundColor = .themeBlue
                    self.secondIndex.textColor = .white
//                    self.SecondHeight.constant = 360
                    self.secondSummi.image = UIImage(named: "arrow_up_normal")?.withRenderingMode(.alwaysTemplate)
                }
                break
            case 3:
                if sender.isSelected {
                    self.thirdIndexBg.backgroundColor = .themeLightGrey
                    self.thirdIndex.textColor = .gray
//                    self.ThirdHeight.constant = 66
                    self.thirdSummi.image = UIImage(named: "arrow_down_normal")?.withRenderingMode(.alwaysTemplate)
                }else{
                    self.thirdIndexBg.backgroundColor = .themeBlue
                    self.thirdIndex.textColor = .white
//                    self.ThirdHeight.constant = 360
                    self.thirdSummi.image = UIImage(named: "arrow_up_normal")?.withRenderingMode(.alwaysTemplate)
                }
                break
            default:
                break
            }
            sender.isSelected = !sender.isSelected
            self.view.setNeedsLayout()
        }
    }
    
    @IBAction func nextBtnAction(_ sender: UIButton) {
//        if let barcode = self.idBackBarcode {
//            HUDController.sharedController.contentView = HUDContentView.ProgressStatusView(title: "", subtitle: "")
//            HUDController.sharedController.show()
//            let address: AddressModel = AddressModel(jsonString: "{}")
//            if let dl = barcode.driverLicense{
//                address.addressLine1 = dl.addressStreet
//                address.city = dl.addressCity
//                address.zip = dl.addressZip
//                address.state = dl.addressState
//                address.type = "Home".localize()
//                UserService.sharedInstance.updateAddress(address, success: { (code, result) in
//                    self.view.showSuccessHUD("", subTitle: "", false)
//                    let ctrl: CreateSecureEmailVC = CreateSecureEmailVC()
//                    self.navigationController?.pushViewController(ctrl, animated: true)
//                    debugPrint("Result - ", result ?? "")
//                }) { (code, error) in
//                    self.showErrorHUD(error)
//                }
//                return
//            }else {
//                let ctrl: EditAddressVC = EditAddressVC()
//                self.navigationController?.pushViewController(ctrl, animated: true)
//            }
//
//        }
        
    }
    
    
}


extension IDValidationDetailsVC: IDPhotoWithFirebaseStepFirstVCDelegate {
    
    func validationAction(_ type: IDValidationCase){
        switch type {
        case .cardFront:
            if let _ = idFrontImage {
                let alert: UIAlertController = UIAlertController(title: "Warning".localize(), message: "You already have scanned - Driver License or State ID (Front). Do you want to reset and scan it again?".localize(), preferredStyle: .alert)
                let okAction = UIAlertAction(title: "YES", style: .default) { (action) in
                    self.idFrontImage = nil
                    self.validationAction(.cardFront)
                }
                let cancelAction = UIAlertAction(title: "NO".localize(), style: .cancel) { (action) in
                }
                alert.addAction(okAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true) {
                }
            }else{
                let ctrl = IDPhotoWithFirebaseStepFirstVC()
                ctrl.delegate = self
                ctrl.modalPresentationStyle = .fullScreen
                self.navigationController?.present(ctrl, animated: true, completion: nil)
            }
        case .cardBack:
            let ctrl = IDPhotoWithFirebaseStepFirstVC()
            ctrl.delegate = self
            ctrl.isIDFront = false
            ctrl.modalPresentationStyle = .fullScreen
            self.navigationController?.present(ctrl, animated: true, completion: nil)
        case .face:
            if let idImage = self.idFrontImage{
                if !self.isComparisonDone {
                    let ctrl = IDSelfieValidateWithRekognitionVC()
                    ctrl.idFrontImage = idImage
                    ctrl.modalPresentationStyle = .fullScreen
                    ctrl.attemptFailed = {(atmptCount: Int) in
                        DispatchQueue.main.async {
                            UserDefaults.IDAttemptCount(atmptCount)
                            self.backButtonAction(nil)
                        }
                    }
                    ctrl.manualUpdoadDone = {(completed: Bool) in
                        DispatchQueue.main.async {
                            self.backButtonAction(nil)
                        }
                    }
                    ctrl.comparisonDone = {(completed: Bool) in
                        DispatchQueue.main.async {
                            self.isComparisonDone = true
                            self.thirdToggleBtn.isEnabled = false
                            self.thirdIndexBg.backgroundColor = .themeGreen
                            self.thirdIndex.textColor = .white
//                            self.ThirdHeight.constant = 66
                            self.thirdDoneIV.isHidden = false
                            self.thirdIndex.isHidden = true
                            self.thirdSummi.image = UIImage(named: "arrow_down_normal")?.withRenderingMode(.alwaysTemplate)
                            self.view.setNeedsLayout()
//                            self.nextBtnBg.isHidden = false
                        }
                    }
                    self.navigationController?.present(ctrl, animated: true, completion: nil)
                }else{
                    let alert: UIAlertController = UIAlertController(title: "Warning".localize(), message: "You already have scanned - Selfie Photo. Do you want to reset and scan it again?".localize(), preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "YES".localize(), style: .default) { (action) in
                        DispatchQueue.main.async {
                            self.isComparisonDone = false
                            self.validationAction(.face)
                        }
                    }
                    let cancelAction = UIAlertAction(title: "NO".localize(), style: .cancel) { (action) in
                    }
                    alert.addAction(okAction)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true) {
                        
                    }
                }
            }else{
                let alert: UIAlertController = UIAlertController(title: "Warning".localize(), message: "Please, Scan Driver License or State ID (Front) First.".localize(), preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK".localize(), style: .cancel) { (action) in
                    
                }
                alert.addAction(okAction)
                self.present(alert, animated: true) {
                    
                }
            }
        }
    }
    
    func scanFinishedSuccessfull(_ scannedImage: UIImage?){
        idFrontImage = scannedImage
        firstToggleBtn.isEnabled = false
        firstIndexBg.backgroundColor = .themeGreen
        firstIndex.textColor = .white
//        FirstHeight.constant = 66
        firstSummi.image = UIImage(named: "arrow_down_normal")?.withRenderingMode(.alwaysTemplate)
        firstDoneIV.isHidden = false
        firstIndex.isHidden = true
        // open second step
        secondToggleBtn.isEnabled = true
        secondIndexBg.backgroundColor = .themeBlue
        secondIndex.textColor = .white
//        SecondHeight.constant = 360
        firstSummi.image = UIImage(named: "arrow_down_normal")?.withRenderingMode(.alwaysTemplate)
        view.setNeedsLayout()
    }
    
    func scanIDBackFinishedSuccessfull(_ barcode: Barcode?) {
        idBackBarcode = barcode
        secondToggleBtn.isEnabled = false
        secondIndexBg.backgroundColor = .themeGreen
        secondIndex.textColor = .white
//        SecondHeight.constant = 66
        secondDoneIV.isHidden = false
        secondIndex.isHidden = true
        firstSummi.image = UIImage(named: "arrow_down_normal")?.withRenderingMode(.alwaysTemplate)
        //open third step
        thirdToggleBtn.isEnabled = true
        thirdIndexBg.backgroundColor = .themeBlue
        thirdIndex.textColor = .white
//        ThirdHeight.constant = 360
        thirdSummi.image = UIImage(named: "arrow_down_normal")?.withRenderingMode(.alwaysTemplate)
        view.setNeedsLayout()
    }
}


