//
//  CCVideoTableViewCell.swift
//  Tumblr
//
//  Created by caikaixuan on 2018/7/30.
//  Copyright © 2018年 caikaixuan. All rights reserved.
//

import UIKit
import SwiftyJSON

class CCVideoTableViewCell: UITableViewCell {

    @IBOutlet weak var videoTitleLabel: UILabel!
    
    @IBOutlet weak var videoCoverImageView: UIImageView!
    
    @IBOutlet weak var userHeaderImageView: UIImageView!
    
    @IBOutlet weak var videoTimeLabel: UILabel!
    
    @IBOutlet weak var publisherLabel: UILabel!
    
    @IBOutlet weak var publishTimeLabel: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var likeButton: UIButton!
    
    var data:JSON?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configCell(data:JSON){
        self.data = data
        self.videoTitleLabel.text = data["summary"].stringValue
        let headImageURL = data["trail"][0]["blog"]["theme"]["header_image"].stringValue
        self.userHeaderImageView.kf.setImage(with: URL.init(string: headImageURL))
        self.publisherLabel.text = data["blog_name"].stringValue
        self.publishTimeLabel.text = data["date"].stringValue
        
        let duration = data["duration"].intValue
        let min = String(format:"%02d",duration/60)
        let sec = String(format:"%02d",duration%60)
        self.videoTimeLabel.text = " \(min):\(sec)   "
        let coverImageURL = data["thumbnail_url"].stringValue
        self.videoCoverImageView.kf.setImage(with: URL.init(string: coverImageURL))
        
        self.followButton.isSelected = data["followed"].boolValue
        self.likeButton.isSelected = data["liked"].boolValue
    
    }
    
    @IBAction func followBtnClick(_ button: UIButton) {
        let blogName = self.data!["blog_name"].stringValue
        let client = CCAuthorizedManager.shared.client
        if button.isSelected {
            
            let unfollowRequest = TMRequestFactory.init().unfollowRequest(blogName)
            client?.task(with: unfollowRequest, callback: { (result, error) in
                if error != nil {
                    MBProgressHUD.onlyText(view: nil, text: "取消关注失败", delay: 1)
                }
                else{

                    button.isSelected = false
                }
            }).resume()
        }
        else{
            
            let followRequest = TMRequestFactory.init().followRequest(blogName, parameters: nil)
            client?.task(with: followRequest, callback: { (result, error) in
                if error != nil {
                    MBProgressHUD.onlyText(view: nil, text: "关注失败", delay: 1)
                }
                else{
                    button.isSelected = true
                }
            }).resume()
            
        }
    }
    
    
    @IBAction func likeBtnClick(_ button: UIButton) {
        let postId = self.data!["id"].stringValue
        let reblogKey = self.data!["reblog_key"].stringValue
        let client = CCAuthorizedManager.shared.client
        
        if button.isSelected {
            let unlikeRequest = TMRequestFactory.init().unlikeRequest(postId, reblogKey: reblogKey)
            client?.task(with: unlikeRequest, callback: { (result, error) in
                if error != nil {
                    MBProgressHUD.onlyText(view: nil, text: "取消收藏失败", delay: 1)
                }
                else{
                    button.isSelected = false
                }
            }).resume()
        }
        else{
            let likeRequest = TMRequestFactory.init().likeRequest(postId, reblogKey: reblogKey)
            client?.task(with: likeRequest, callback: { (result, error) in
                if error != nil {
                    MBProgressHUD.onlyText(view: nil, text: "收藏失败", delay: 1)
                }
                else{
                    button.isSelected = true
                }
            }).resume()
        }
    }
    
}
