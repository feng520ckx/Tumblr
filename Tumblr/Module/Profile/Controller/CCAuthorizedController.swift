//
//  CCAuthorizedController.swift
//  Tumblr
//
//  Created by caikaixuan on 2018/5/12.
//  Copyright © 2018年 caikaixuan. All rights reserved.
//

import UIKit

class CCAuthorizedController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }

    @IBAction func exitButtonClick(_ sender: Any) {
        exit(0)
    }
    
    @IBAction func requestAuthorized(_ sender: Any) {
        MBProgressHUD.fastshow(view: self.view)
        CCAuthorizedManager.shared.authorized { (result) in
            if result == 1{
                print("授权成功")
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.changeRootTabBar()
                }
            }
            else{
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
            }
        }
    }
}
