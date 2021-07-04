//
//  BaseController.swift
//  Medyear
//
//  Created by Bahrom Abdullayev on 12/7/14.
//  Copyright (c) 2014 Personiform. All rights reserved.
//

import UIKit

public class BaseController: UIViewController  {
    
    
    var refreshControl: UIRefreshControl!
   
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.navigationBar.layer.masksToBounds = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationSetup()
        self.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.tabBarController?.tabBar.isHidden = true
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.modalPresentationStyle = UIModalPresentationStyle.fullScreen
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fontsUI(){
        
    }
    func navigationSetup(){
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.layer.masksToBounds = false
    }
    
    func detectScreenShot(action: @escaping () -> ()) {
        let mainQueue = OperationQueue.main
        NotificationCenter.default.addObserver(forName: UIApplication.userDidTakeScreenshotNotification, object: nil, queue: mainQueue) { notification in
            // executes after screenshot
            action()

        }
    }
    
    
   
    
   
    lazy var backBarButton: UIBarButtonItem={
        let _backBarButton = UIBarButtonItem(image: UIImage(named: "backIcon")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(backButtonAction(_:)))
        _backBarButton.tintColor = UIColor.white
        return _backBarButton
    }()
    
    @objc
    func backButtonAction(_ sender: UIButton!){
        self.navigationController?.popViewController(animated: true)
    }
    
    lazy var closeBarButton: UIBarButtonItem={
        let closeBtnBar = UIBarButtonItem(image: UIImage(named: "cm_close_white")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(closeButtonAction(_:)))
        closeBtnBar.tintColor = UIColor.white
        return closeBtnBar
    }()
    
    @objc
    func closeButtonAction(_ sender: UIButton!){
        self.dismiss(animated: true) {
            
        }
    }
    
    
    func configureRefreshControl(){
        if self.refreshControl == nil {
            self.refreshControl = UIRefreshControl()
            self.refreshControl.addTarget(self, action: #selector(BaseController.refreshControlAction), for: .valueChanged)
        }
    }
    
    @objc func refreshControlAction(){
        self.refreshControl.endRefreshing()
    }
    
    func nativeBackButtonIconChange(){
        
        self.title = ""
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "left")?.withRenderingMode(.alwaysTemplate)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "left")?.withRenderingMode(.alwaysTemplate)
        self.navigationItem.setHidesBackButton(false, animated: false)
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    
    
    func animation(_ point: Float, progress: Float) {
        var frame: CGRect!
        let top: CGFloat = 7
        if point == 0 {
            frame = self.view.bounds
        }else{
            frame = self.view.frame
            frame.origin.y = top
            frame.origin.x = top
            frame.size.width = self.view.frame.size.width - 2*top
            frame.size.height = self.view.frame.size.height - 2*top
        }
        UIView.animate(withDuration: 0.4, delay: 0, options: UIView.AnimationOptions(), animations: { () -> Void in
            self.view.frame = frame
        }) { (finished) -> Void in
            
        }
    }
    

    
    
    
}
