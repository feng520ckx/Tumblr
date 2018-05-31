//
//  CCSpliteImageView.swift
//  Tumblr
//
//  Created by caikaixuan on 2018/5/14.
//  Copyright © 2018年 caikaixuan. All rights reserved.
//

import UIKit
import SnapKit
import SwiftyJSON
import Kingfisher

class CCSpliteImageView: UIView {
    
    let imageArray:NSMutableArray = {
        let array = NSMutableArray.init()
        return array
    }()

    var imageClickBlock:ImageDidClickCallBack?
    
    func reload(imageArray:Array<JSON>, layout:String){
        for view in self.subviews{
            view.removeFromSuperview()
        }
        self.imageArray.removeAllObjects()
        self.setupLayout(array: imageArray, layout: layout)
    }
    
    func setupLayout(array:Array<JSON>,layout:String){
        let margin = 8
        let scrrenW = UIScreen.main.bounds.size.width
        var p = -1
        for row in 0..<layout.count{
            let rowIndex = layout.index(layout.startIndex, offsetBy: row)
            let col = Int(String(layout[rowIndex]))!
            if col <= 0 {
                continue
            }
            var firstLineView:UIImageView?
            if p != -1{
                firstLineView = self.imageArray[p] as? UIImageView
            }
            // 1 3 1
            let width = (scrrenW - CGFloat((col + 1) * margin)) / CGFloat(col)
            var height: CGFloat = 0
            for col_index in 0..<col {
                p = p + 1
                if height == 0 {
                    let imageW = array[p]["original_size"]["width"].intValue
                    let imageH = array[p]["original_size"]["height"].intValue
                    height = (width / CGFloat(imageW)) * CGFloat(imageH)
                }
                let imageView = UIImageView.init()
                imageView.backgroundColor=UIColor.randomGradient()
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.tag = p
                imageView.isUserInteractionEnabled = true
                let tapEvent = UITapGestureRecognizer.init(target: self, action: #selector(imageTapGesture(tapgesture:)))
                imageView.addGestureRecognizer(tapEvent)
                let imageURL = array[p]["original_size"]["url"].stringValue
                imageView.kf.setImage(with: URL.init(string: imageURL))
                self.addSubview(imageView)
                self.imageArray.add(imageView)
                
                if col_index == 0 {
                    if firstLineView == nil {
                        
                        if row == layout.count-1 {
                            imageView.snp.makeConstraints { (make) in
                                make.width.equalTo(width)
                                make.height.equalTo(height)
                                make.left.equalTo(self).offset(margin)
                                make.top.equalTo(self).offset(margin)
                                make.bottom.equalTo(self).offset(-margin)
                            }
                        }
                        else{
                            imageView.snp.makeConstraints { (make) in
                                make.width.equalTo(width)
                                make.height.equalTo(height)
                                make.left.equalTo(self).offset(margin)
                                make.top.equalTo(self).offset(margin)
                            }
                        }
                    }
                    else {
   
                        if row == layout.count-1 {
                            imageView.snp.makeConstraints { (make) in
                                make.width.equalTo(width)
                                make.left.equalTo(self).offset(margin)
                                make.height.equalTo(height)
                                make.top.equalTo((firstLineView?.snp.bottom)!).offset(margin)
                                make.bottom.equalTo(self).offset(-margin)
                            }
                        }
                        else{
                            imageView.snp.makeConstraints { (make) in
                                make.width.equalTo(width)
                                make.height.equalTo(height)
                                make.left.equalTo(self).offset(margin)
                                make.top.equalTo((firstLineView?.snp.bottom)!).offset(margin)
                            }
                        }
                    }
                }
                else {
                    let lastView = self.imageArray[p-1] as! UIImageView
                    if row == layout.count-1 {
                        imageView.snp.makeConstraints { (make) in
                            make.width.top.equalTo(lastView)
                            make.height.equalTo(height)
                            make.left.equalTo(lastView.snp.right).offset(margin)
                            make.bottom.equalTo(self).offset(-margin)
                        }
                    }
                    else{
                        imageView.snp.makeConstraints { (make) in
                            make.width.top.equalTo(lastView)
                            make.height.equalTo(height)
                            make.left.equalTo(lastView.snp.right).offset(margin)
                        }
                    }
                }
            }
        }
    }
    
    @objc func imageTapGesture(tapgesture:UITapGestureRecognizer) {
        let selectTag = tapgesture.view?.tag
        if self.imageClickBlock != nil {
            self.imageClickBlock!(selectTag!)
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame) // error
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
