//
//  UIKit+Extension.swift
//  Tumblr
//
//  Created by caikaixuan on 2018/5/15.
//  Copyright © 2018年 caikaixuan. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    class public func randomGradient() -> UIColor{
        
        UIGraphicsBeginImageContext(CGSize.init(width: UIScreen.main.bounds.size.width, height:UIScreen.main.bounds.size.height))
        
        let ctx = UIGraphicsGetCurrentContext()
        
        let color1 = self.random()
        let color2 = color1.withAlphaComponent(0.6)
        
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors:[color1.cgColor,color2.cgColor] as CFArray, locations:[0.0, 1.0])!
        
        ctx?.drawLinearGradient(gradient, start: CGPoint.init(x: 0, y: 0), end: CGPoint.init(x: 0, y: UIScreen.main.bounds.size.height), options: .drawsAfterEndLocation)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        var color = UIColor.clear 
        if image != nil {
            color = UIColor.init(patternImage: image!)
        }
        return color
    }
    
    class public func random()->UIColor{
        
        let hue = CGFloat(arc4random() % 256) / 256.0 //  0.0 to 1.0
        let saturation = (CGFloat(arc4random() % 128) / 256.0) + 0.5 //0.5 to 1.0, away from white
        let brightness = (CGFloat(arc4random() % 128) / 256.0) + 0.5 //  0.5 to 1.0, away from black
        
        return UIColor.init(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
}

extension MBProgressHUD {
    
    class public func fastshow(view:UIView?){
        
        DispatchQueue.main.async {
            var showView = view
            if view == nil {
                showView = UIApplication.shared.windows.last as! UIView
            }
            let hud = MBProgressHUD.showAdded(to: showView!, animated: true)
            
            hud.contentColor = UIColor.white
            hud.bezelView.backgroundColor = UIColor.black
        }
    }
    
    class public func fastText(view:UIView?,text:String,delay:Int){
        
        DispatchQueue.main.async {
            var showView = view
            if view == nil {
                showView = UIApplication.shared.windows.last as! UIView
            }
            let hud = MBProgressHUD.showAdded(to: showView!, animated: true)
            
            hud.contentColor = UIColor.white
            hud.bezelView.backgroundColor = UIColor.black
            hud.label.text=text
            hud.label.textColor=UIColor.white

            hud.hide(animated: true, afterDelay: TimeInterval(delay))
        }
    }
    
    class public func onlyText(view:UIView?,text:String,delay:Int){
        
        DispatchQueue.main.async {
            var showView = view
            if view == nil {
                showView = UIApplication.shared.windows.last as! UIView
            }
            let hud = MBProgressHUD.showAdded(to: showView!, animated: true)
            
            hud.contentColor = UIColor.white
            hud.bezelView.backgroundColor = UIColor.black
            hud.label.text=text
            hud.label.textColor=UIColor.white
            hud.mode = .text
            hud.hide(animated: true, afterDelay: TimeInterval(delay))
        }
    }
    
}

extension String {
    public var hexInt: Int? {
        let scanner = Scanner(string: self)
        var value: UInt64 = 0
        guard scanner.scanHexInt64(&value) else { return nil }
        return Int(value)
    }
}


extension UIColor {
    public convenience init?(hex: String) {
        var str = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if str.hasPrefix("#") {
            let indexOffsetBy1 = str.index(str.startIndex, offsetBy: 1)
            str = String(str[indexOffsetBy1...])
        }
        guard str.count == 6 else { return nil }
        
        let startIndex = str.startIndex
        let endIndex = str.endIndex
        
        let indexOffsetBy2 = str.index(startIndex, offsetBy: 2)
        let indexOffsetBy4 = str.index(startIndex, offsetBy: 4)
        
        let red = str[startIndex..<indexOffsetBy2]
        let green = str[indexOffsetBy2..<indexOffsetBy4]
        let blue = str[indexOffsetBy4..<endIndex]
        
        guard let redIn255 = String(red).hexInt else { return nil }
        guard let greenIn255: Int = String(green).hexInt else { return nil }
        guard let blueIn255: Int = String(blue).hexInt else { return nil }
        
        let redFloat = CGFloat(redIn255) / 255.0;
        let greenFloat = CGFloat(greenIn255) / 255.0;
        let blueFloat = CGFloat(blueIn255) / 255.0;
        
        self.init(red: redFloat, green: greenFloat, blue: blueFloat, alpha: 1)
    }
}



