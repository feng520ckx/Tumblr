//
//  CCHomeImageController.swift
//  Tumblr
//
//  Created by caikaixuan on 2018/5/11.
//  Copyright © 2018年 caikaixuan. All rights reserved.
//

import UIKit
import SwiftyJSON
import JXPhotoBrowser

class CCHomeImageController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    lazy var dataArray:NSMutableArray? = {
        let array = NSMutableArray.init()
        return array
    }()
    
    let client =  CCAuthorizedManager.shared.client

    var pageNum : Int = 0
    
    var selectPhotosArray : Array<JSON>?
    var selectRowIndex : Int = 0
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.initData()
        self.registerCell()
        MBProgressHUD.fastshow(view: self.view)

    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTableView(){
        self.tableView.estimatedRowHeight = 100
        let refreshHeader = MJRefreshNormalHeader.init(refreshingTarget: self, refreshingAction: #selector(initData))
        refreshHeader?.activityIndicatorViewStyle = .white
        refreshHeader?.stateLabel.textColor = UIColor.white
        refreshHeader?.lastUpdatedTimeLabel.textColor = UIColor.white
        
        self.tableView.mj_header = refreshHeader
        
    }
    
    @objc func initData(){
    
        let paramter = ["type":"photo"]
        pageNum = 0
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
        let paramter = ["type":"photo",
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
    
    func registerCell() {
        
        self.tableView.register(CCHomeTableImageCell.self, forCellReuseIdentifier: "CCHomeTableImageCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.dataArray?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CCHomeTableImageCell")! as! CCHomeTableImageCell
        
        let dict = self.dataArray![indexPath.row] as! JSON
        cell.config(data:dict)
        cell.imageClickBlock = { (selectIndex) in
            self.openPhotoBrowserWithInstanceMethod(row: indexPath.row, index: selectIndex)
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    
    private func openPhotoBrowserWithInstanceMethod(row : Int,index: Int) {
        // 创建图片浏览器
        self.selectPhotosArray = (self.dataArray![row] as! JSON)["photos"].arrayValue
        self.selectRowIndex = row
        
        let browser = PhotoBrowser()
        // 提供两种动画效果：缩放`.scale`和渐变`.fade`。
        browser.animationType = .scale
        // 浏览器协议实现者
        browser.photoBrowserDelegate = self
        // 装配页码指示器插件，提供了两种PageControl实现，若需要其它样式，可参照着自由定制
        // 光点型页码指示器
        browser.plugins.append(DefaultPageControlPlugin())
        // 数字型页码指示器
        browser.plugins.append(NumberPageControlPlugin())
        // 指定打开图片组中的哪张
        browser.originPageIndex = index
        // 展示
        self.present(browser, animated: true, completion: nil)
        /*
         // 可主动关闭图片浏览器
         DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
         browser.dismiss(animated: false)
         }*/
    }
    
}

// 实现浏览器代理协议
extension CCHomeImageController: PhotoBrowserDelegate {
    /// 共有多少张图片
    func numberOfPhotos(in photoBrowser: PhotoBrowser) -> Int {
        return self.selectPhotosArray!.count
    }
    
    /// 各缩略图图片，也是图片加载完成前的 placeholder
    func photoBrowser(_ photoBrowser: PhotoBrowser, originImageForIndex index: Int) -> UIImage? {
        let cell = self.tableView.cellForRow(at: IndexPath.init(row: self.selectRowIndex, section: 0)) as? CCHomeTableImageCell
        return (cell?.imageContentView.imageArray[index] as! UIImageView).image
    }
    
    /// 各缩略图所在 view
    func photoBrowser(_ photoBrowser: PhotoBrowser, originViewForIndex index: Int) -> UIView? {
        let cell = self.tableView.cellForRow(at: IndexPath.init(row: self.selectRowIndex, section: 0)) as? CCHomeTableImageCell
        return cell?.imageContentView.imageArray[index] as! UIImageView
    }
    
    /// 高清图
    func photoBrowser(_ photoBrowser: PhotoBrowser, highQualityUrlForIndex index: Int) -> URL? {
        let urlURL = (self.selectPhotosArray![index])["original_size"]["url"].stringValue
        return URL(string: urlURL)
    }
    
    /// 原图
    func photoBrowser(_ photoBrowser: PhotoBrowser, rawUrlForIndex index: Int) -> URL? {
        let urlURL = (self.selectPhotosArray![index])["original_size"]["url"].stringValue
        return URL(string: urlURL)
    }
    
    /// 加载本地图片，本地图片的展示将优先于网络图片
    func photoBrowser(_ photoBrowser: PhotoBrowser, localImageForIndex index: Int) -> UIImage? {
        
        return nil
    }
    
    func photoBrowser(_ photoBrowser: PhotoBrowser, didLongPressForIndex index: Int, image: UIImage) {
        
        WXShareHelper.share(scene: WXSceneSession, objType: .Image, shareData: image)
    }
}
