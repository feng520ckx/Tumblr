//
//  CCVideoDetailController.swift
//  Tumblr
//
//  Created by caikaixuan on 2018/7/30.
//  Copyright © 2018年 caikaixuan. All rights reserved.
//

import UIKit

class CCVideoDetailController: UIViewController,KXPlayerDelegate {

  
    @IBOutlet weak var playView: UIView!
    
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    @IBOutlet weak var timeProgressView: UIProgressView!
    var player:KXPlayer?
    
    var videoURL:String = "" {
        didSet{
            print("videoURL=\(videoURL)")
            DispatchQueue.main.async {
                self.player = KXPlayer.init(url: URL.init(string: self.videoURL))
                self.player?.preView = self.playView
                self.player?.isAutoPlay = true
                self.player?.isLoop = true
                self.player?.delegate = self
                self.player?.isMute = true //默认静音
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func player(_ player: KXPlayer!, stateChange state: KXPlayerState) {
        
        switch state {
        case .keepUp:
            self.loadingView.startAnimating()
            self.loadingView.isHidden = false
        case .playing:
            self.loadingView.stopAnimating()
            self.loadingView.isHidden = true
        case .loading:
            self.loadingView.startAnimating()
            self.loadingView.isHidden = false
        case .paused:
            print("")
        case .finish:
            print("")
        case .unKnow:
            self.loadingView.startAnimating()
            self.loadingView.isHidden = false
        default:
            self.loadingView.startAnimating()
            self.loadingView.isHidden = false
        }
    }
    
    func player(_ player: KXPlayer!, cacheTimeChange time: KTime) {
        
    }
    
    func player(_ player: KXPlayer!, slideTimeChange time: KTime) {
        DispatchQueue.main.async {
            self.timeProgressView.progress = time.value
        }
    }
    
    
    @IBAction func closeButtonClick(_ sender: Any) {
        self.player?.shutdown()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareButtonClick(_ sender: Any) {
       //视频暂时分享不了
    }
    
        
    @IBAction func muteButtonClick(_ button: UIButton) {
        button.isSelected = !button.isSelected
        self.player?.isMute = !button.isSelected
    }
    
}
