//
//  WXShareHelper.swift
//  Tumblr
//
//  Created by caikaixuan on 2018/5/17.
//  Copyright © 2018年 caikaixuan. All rights reserved.
//

import Foundation

enum ShareObjType {
    case Image
    case Video
}


class WXShareHelper: NSObject {
    
    class func share(scene:WXScene,objType:ShareObjType,shareData:Any){
        
        switch objType {
        case .Image:
            self.shareImage(scene: scene, image: shareData as! UIImage)
        case .Video:
            self.shareVideo(scene: scene, video: shareData as! String)

        }
        
    }
    
    private class func shareImage(scene:WXScene,image:UIImage){
        let message = WXMediaMessage.init()
        let imageData = UIImagePNGRepresentation(image)
        let imageObj = WXImageObject.init()
        imageObj.imageData = imageData
        
        message.mediaObject = imageObj
        
        let req = SendMessageToWXReq.init()
        req.bText = false
        req.message = message
        req.scene = Int32(scene.rawValue)
        WXApi.send(req)
    }
    
    private class func shareVideo(scene:WXScene, video:String){
        let message = WXMediaMessage.init()
        message.title = "嘿嘿嘿 发现一个好看的视频"
        message.description = "来看一看嘛~"
        
        let videoObj = WXVideoObject.init()
        videoObj.videoUrl = video
        videoObj.videoLowBandUrl = video
        
        let req = SendMessageToWXReq.init()
        req.bText = false
        req.message = message
        req.scene = Int32(scene.rawValue)
        WXApi.send(req)
        
    }
    
    
}
