//
//  CCScrrenBlockViewController.swift
//  Tumblr
//
//  Created by caikaixuan on 2018/5/11.
//  Copyright © 2018年 caikaixuan. All rights reserved.
//

import UIKit
import AVFoundation

let kColorCircleFillColor = UIColor.init(hex: "9cb6c7")!

class CCScrrenBlockViewController: UIViewController {

    @IBOutlet weak var code3: UIView!
    @IBOutlet weak var code2: UIView!
    @IBOutlet weak var code1: UIView!
    @IBOutlet weak var code4: UIView!
    
    @IBOutlet weak var tipLabel: UILabel!
        
    @IBOutlet weak var errorLabel: UILabel!
    
    var pwd:String = ""
    var userPwd:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupInitData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    func setupInitData(){
        
        self.code1.layer.borderColor = kColorCircleFillColor.cgColor
        self.code2.layer.borderColor = kColorCircleFillColor.cgColor
        self.code3.layer.borderColor = kColorCircleFillColor.cgColor
        self.code4.layer.borderColor = kColorCircleFillColor.cgColor
        
        if let str = UserDefaults.standard.string(forKey: kUserPassword){
            pwd = str
        }
        
        if pwd.count == 0 {
            self.tipLabel.text = "请设置你的不热密码"
        }
        
    }
    
    @IBAction func pwdNumClick(_ sender: UIButton) {
        
        if self.userPwd.count < 4 {
            self.userPwd.append(String(sender.tag))
            self.reloadButtonState()
            if self.userPwd.count == 4 {
                if self.pwd.count == 0{
                    UserDefaults.standard.set(self.userPwd, forKey: kUserPassword)
                    UserDefaults.standard.synchronize()
                    DispatchQueue.main.async {
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.changeRootTabBar()
                    }
                }
                else if self.pwd == self.userPwd{
                    DispatchQueue.main.async {
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.changeRootTabBar()
                    }
                }else{
                    self.showError();
                }
            }else if self.userPwd.count > 4{
                self.showError();
            }
        }
        else {
            self.showError()
        }
        
    }

    @IBAction func delClick(_ sender: Any) {
        
        if self.userPwd.count > 0 {
            
            self.userPwd.remove(at: self.userPwd.index(before: self.userPwd.endIndex))
            self.reloadButtonState()
        }
        
    }
    
    func reloadButtonState(){
        for index in 1...4{
            let view = self.view.viewWithTag(100+index)
            if self.userPwd.count >= index {
                view?.backgroundColor = kColorCircleFillColor
            }
            else {
                view?.backgroundColor = UIColor.clear
            }
        }
    }
    
    func showError() {
        self.errorLabel.isHidden = false
        self.userPwd.removeAll()
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            self.reloadButtonState()
        }
        
        
    }
    
}
