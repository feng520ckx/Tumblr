//
//  CCHomeVideoController.swift
//  Tumblr
//
//  Created by caikaixuan on 2018/5/11.
//  Copyright © 2018年 caikaixuan. All rights reserved.
//

import UIKit


class CCHomeVideoController: UIViewController {

    lazy var scrollView:UIScrollView={
        let view = UIScrollView.init()
        
        return view
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.scrollView.contentSize = CGSize.init(width: self.view.frame.size.width, height: self.view.frame.size.height*3)
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let layout = "2322"
        
        for index in 0..<layout.count {
            let valueIndex = layout.index(layout.startIndex, offsetBy: index)
            print("str=",layout[valueIndex])
        }
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
    }

}
