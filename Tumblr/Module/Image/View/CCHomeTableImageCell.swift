//
//  CCHomeTableImageCell.swift
//  Tumblr
//
//  Created by caikaixuan on 2018/5/14.
//  Copyright © 2018年 caikaixuan. All rights reserved.
//

import UIKit
import SwiftyJSON

class CCHomeTableImageCell: UITableViewCell {

    private lazy var headImageView:UIImageView = {
        let view = UIImageView.init()
        view.backgroundColor = UIColor.random()
        view.layer.cornerRadius = 30
        view.clipsToBounds = true
        return view
    }()
    
    lazy var imageContentView : CCSpliteImageView = {
        let view = CCSpliteImageView.init(frame: .zero)

        return view
    }()
    
    private lazy var nameLabel:UILabel = {
        let view = UILabel.init()
        
        return view
    }()
    
    private lazy var followButton : UIButton = {
        let view = UIButton.init()
        view.setTitle("关注", for: .normal)
        view.setTitle("取消关注", for: .selected)
        view.setTitleColor(kColorBlue, for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        view.addTarget(self, action: #selector(followButtonClick(button:)), for: .touchUpInside)
        return view
    }()
    
    private lazy var likeButton : UIButton = {
        let button = UIButton.init()
        button.setImage(UIImage.init(named: "unlike"), for: .normal)
        button.setImage(UIImage.init(named: "like"), for: .selected)
        button.addTarget(self, action: #selector(likeButtonClick(button:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var repostButton : UIButton = {
        let button = UIButton.init()
        button.setImage(UIImage.init(named: "send"), for: .normal)
        button.addTarget(self, action: #selector(repostButtonClick(button:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var hotNumLabel : UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "热度 0 ℃"
        return label
    }()
    
    private lazy var timeLabel :UILabel = {
        let view = UILabel.init()
        view.textColor = UIColor.gray
        view.font = UIFont.systemFont(ofSize: 14)
        return view
    }()
    
    private lazy var slugLabel :UILabel = {
        let view = UILabel.init()
        view.numberOfLines = 0
        return view
    }()
    
    private lazy var whiteContentView:UIView = {
        let view = UIView.init()
        view.backgroundColor=UIColor.white
        view.layer.cornerRadius=10
        
        return view
    }()
    
    private var data:JSON?
    
    public var imageClickBlock:ImageDidClickCallBack?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        setupSubViews()
        setupAutoLayout()
        
         self.imageContentView.imageClickBlock = { (selectIndex) in
            if (self.imageClickBlock != nil) {
                self.imageClickBlock!(selectIndex)
            }
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    func setupSubViews() {
        self.contentView.addSubview(self.whiteContentView)
        self.whiteContentView.addSubview(self.headImageView)
        self.whiteContentView.addSubview(self.nameLabel)
        self.whiteContentView.addSubview(self.followButton)
        self.whiteContentView.addSubview(self.slugLabel)
        self.whiteContentView.addSubview(self.timeLabel)
        self.whiteContentView.addSubview(self.imageContentView)
        self.whiteContentView.addSubview(self.hotNumLabel)
        self.whiteContentView.addSubview(self.repostButton)
        self.whiteContentView.addSubview(self.likeButton)
    }
    
    func setupAutoLayout() {
        
        self.whiteContentView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.contentView)
            make.top.equalTo(self.contentView).offset(10)
            make.bottom.equalTo(self.contentView).offset(-10)
        }
        
        self.headImageView.snp.makeConstraints { (make) in
            make.left.top.equalTo(self.whiteContentView).offset(15)
            make.width.height.equalTo(60)
        }
        
        self.nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.headImageView.snp.right).offset(15)
            make.top.equalTo(self.headImageView).offset(10)
        }
        
        self.timeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.nameLabel)
            make.top.equalTo(self.nameLabel.snp.bottom).offset(10)
        }
        
        self.followButton.snp.makeConstraints { (make) in
            make.right.equalTo(self.whiteContentView).offset(-15)
            make.centerY.equalTo(self.nameLabel)
            make.width.equalTo(80)
            make.height.equalTo(30)
        }
        
        self.slugLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.headImageView)
            make.right.equalTo(self.followButton)
            make.top.equalTo(self.headImageView.snp.bottom).offset(10)
        }
        
        self.imageContentView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.whiteContentView)
            make.top.equalTo(self.slugLabel.snp.bottom).offset(10)
        }
        
        self.likeButton.snp.makeConstraints { (make) in
            make.right.equalTo(self.whiteContentView).offset(-15)
            make.top.equalTo(self.imageContentView.snp.bottom)
            make.width.height.equalTo(30)
            make.bottom.equalTo(self.whiteContentView.snp.bottom).offset(-10)
        }
        
        self.repostButton.snp.makeConstraints { (make) in
            make.right.equalTo(self.likeButton.snp.left).offset(-15)
            make.top.width.height.equalTo(self.likeButton)
        }
        
        self.hotNumLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.whiteContentView).offset(15)
            make.centerY.equalTo(self.likeButton)
            make.right.equalTo(self.repostButton.snp.left).offset(-15)
        }
        
    }
    
    func config(data:JSON) {
        self.data = data
        self.nameLabel.text = data["blog_name"].stringValue
        self.timeLabel.text = data["date"].stringValue
        self.slugLabel.text = data["slug"].stringValue
        var layout = data["photoset_layout"].stringValue
        if layout.count == 0 {
            layout = "1"
        }
        self.imageContentView.reload(imageArray: data["photos"].arrayValue, layout: layout)
        self.followButton.isSelected = data["followed"].boolValue
        self.likeButton.isSelected = data["liked"].boolValue
        self.hotNumLabel.text = "热度 \(data["note_count"]) ℃"
        
        if data["trail"].arrayValue.count>0 {
            let headUrl = data["trail"][0]["blog"]["theme"]["header_image"].stringValue
            let bgColor = data["trail"][0]["blog"]["theme"]["background_color"].stringValue
            self.headImageView.backgroundColor = UIColor.init(hex: bgColor)
            self.headImageView.kf.setImage(with: URL.init(string: headUrl))
        }
        
    }
    
    @objc func followButtonClick(button:UIButton){
        let blogName = self.data!["blog_name"].stringValue
        let client = CCAuthorizedManager.shared.client
        if button.isSelected {
            
            let unfollowRequest = TMRequestFactory.init().unfollowRequest(blogName)
            client?.task(with: unfollowRequest, callback: { (result, error) in
                if error != nil {
                    MBProgressHUD.onlyText(view: nil, text: "取消关注失败", delay: 1)
                }
                else{
//                   MBProgressHUD.onlyText(view: nil, text: "取消关注成功", delay: 1)
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
//                    MBProgressHUD.onlyText(view: nil, text: "关注成功", delay: 1)
                    button.isSelected = true
                }
            }).resume()
            
        }
    }
    
    @objc func likeButtonClick(button:UIButton){
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
//                    MBProgressHUD.onlyText(view: nil, text: "取消收藏成功", delay: 1)
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
//                    MBProgressHUD.onlyText(view: nil, text: "收藏成功", delay: 1)
                    button.isSelected = true
                }
            }).resume()
        }

    }
    
    @objc func repostButtonClick(button:UIButton){
        
        
        let alertView = UIAlertView.init(title: "提醒", message: "你确定要转发这条消息吗？", delegate: self, cancelButtonTitle: nil, otherButtonTitles: "取消", "确定")
        
        alertView.show()
       
    }
    

}

extension CCHomeTableImageCell:UIAlertViewDelegate {
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1 {
            
            let client = CCAuthorizedManager.shared.client
            let postId = self.data!["id"].stringValue
            let reblogKey = self.data!["reblog_key"].stringValue
            let blogName = UserDefaults.standard.string(forKey: kUserBlogName)!
            let dict = ["id":postId,
                        "reblog_key":reblogKey]
            let repostRequest = TMRequestFactory.init().reblogPostRequest(withBlogName: blogName, parameters: dict)
            
            client?.task(with: repostRequest, callback: { (result, error) in
                if error != nil {
                    MBProgressHUD.onlyText(view: nil, text: "转发失败", delay: 1)
                }
                else{
                    MBProgressHUD.onlyText(view: nil, text: "转发成功", delay: 1)
                }
            }).resume()
        }
    }
    
}
