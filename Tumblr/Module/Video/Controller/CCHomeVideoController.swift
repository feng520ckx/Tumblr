//
//  CCHomeVideoController.swift
//  Tumblr
//
//  Created by caikaixuan on 2018/5/11.
//  Copyright © 2018年 caikaixuan. All rights reserved.
//

import UIKit
import SwiftyJSON

class CCHomeVideoController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let client =  CCAuthorizedManager.shared.client
    var pageNum : Int = 0
    
    lazy var dataArray:NSMutableArray? = {
        let array = NSMutableArray.init()
        return array
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MBProgressHUD.fastshow(view: self.view)
        let refreshHeader = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(initData))
        refreshHeader?.activityIndicatorViewStyle = .white
        refreshHeader?.stateLabel.textColor = UIColor.white
        refreshHeader?.lastUpdatedTimeLabel.textColor = UIColor.white
        
        self.tableView.mj_header = refreshHeader
        self.initData();
        self.registerCell();
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func initData(){
        pageNum = 0
        let paramter = ["type":"video"]
        client?.dashboardRequest(paramter, callback: { (data, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if error != nil{
                print("出错了---",error)
            }else{
                let json = JSON.init(data)
                self.dataArray=NSMutableArray.init(array: json["posts"].arrayValue)
                DispatchQueue.main.async {
                    self.tableView.reloadData();
                }
                if self.tableView.mj_footer == nil {
                    let loadMoreFooter = MJRefreshAutoNormalFooter.init(refreshingTarget: self, refreshingAction: #selector(self.loadMoreData))
                    
                    loadMoreFooter?.activityIndicatorViewStyle = .white
                    loadMoreFooter?.stateLabel.textColor = UIColor.white
                    
                    self.tableView.mj_footer = loadMoreFooter
                }
            }
            self.tableView.mj_header.endRefreshing()
            
        }).resume()
        
    }
    
    @objc func loadMoreData(){
        
        pageNum = pageNum + 1
        let paramter = ["type":"video",
                        "offset":String(pageNum*20)]
        
        client?.dashboardRequest(paramter, callback: { (data, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if error != nil{
                print("出错了---",error)
            }else{
                let json = JSON.init(data)
                self.dataArray?.addObjects(from: json["posts"].arrayValue)
                DispatchQueue.main.async {
                    self.tableView.reloadData();
                }
            }
            self.tableView.mj_footer.endRefreshing()
        }).resume()
        
    }
    
    func registerCell(){
        
        self.tableView.register(UINib.init(nibName: "CCVideoTableViewCell", bundle: nil), forCellReuseIdentifier: "CCVideoTableViewCell")
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.dataArray?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CCVideoTableViewCell", for: indexPath) as! CCVideoTableViewCell
        cell.configCell(data: self.dataArray![indexPath.row] as! JSON)
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let data = self.dataArray![indexPath.row] as! JSON
        
        let vc = CCVideoDetailController()
        
        vc.videoURL = data["video_url"].stringValue
        
        self.present(vc, animated: true, completion: nil)
    }

}
