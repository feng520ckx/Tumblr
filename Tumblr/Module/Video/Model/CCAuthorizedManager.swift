//
//  CCAuthorizedManager.swift
//  Tumblr
//
//  Created by caikaixuan on 2018/5/12.
//  Copyright © 2018年 caikaixuan. All rights reserved.
//

import UIKit
import SwiftyJSON

class CCAuthorizedManager: NSObject ,TMOAuthAuthenticatorDelegate{
    
    static let shared = CCAuthorizedManager()
    var client : TMAPIClient?
    var authenticator : TMOAuthAuthenticator?
    
    override init() {
        super.init()
        if UserDefaults.standard.bool(forKey: kUserIsAuthorized){
            let applicationCredential = TMAPIApplicationCredentials.init(consumerKey: kConsumerKey, consumerSecret: kConsumerSecret)
            
            let token = UserDefaults.standard.string(forKey: kUserToken)
            let secret = UserDefaults.standard.string(forKey: kUserSecret)
            let userCredential = TMAPIUserCredentials.init(token: token, tokenSecret: secret)
            let session = TMURLSession.init(configuration: URLSessionConfiguration.default, applicationCredentials: applicationCredential, userCredentials: userCredential)
            client = TMAPIClient.init(session: session, requestFactory: TMRequestFactory.init())
            client?.userInfoDataTask(callback: { (result, error) in
                if error == nil{
                    let resultJson = JSON.init(result)
                    let blogName = resultJson["user"]["name"].stringValue
                    UserDefaults.standard.setValue(blogName, forKey: kUserBlogName)
                }
            }).resume()
        }
    }
    
    class func isAuthorized() -> Bool {
        return UserDefaults.standard.bool(forKey: kUserIsAuthorized)
    }
    
    func authorized(completionHandler:@escaping (_ result:Int)->()) {
        let applicationCredential = TMAPIApplicationCredentials.init(consumerKey: kConsumerKey, consumerSecret: kConsumerSecret)
        let session = TMURLSession.init(configuration: URLSessionConfiguration.default, applicationCredentials: applicationCredential, userCredentials: TMAPIUserCredentials.init())
        self.authenticator = TMOAuthAuthenticator.init(session: session, applicationCredentials: applicationCredential, delegate: self)
        
        self.authenticator?.authenticate("tumblrioscoder", callback: { (result, error) in
            if error != nil {
                completionHandler(-1)
            }
            else{
                let creds = result as! TMAPIUserCredentials
                let applicationCredential = TMAPIApplicationCredentials.init(consumerKey: kConsumerKey, consumerSecret: kConsumerSecret)
                
                let token = creds.token
                let secret = creds.tokenSecret
                UserDefaults.standard.setValue(token, forKey: kUserToken)
                UserDefaults.standard.setValue(secret, forKey: kUserSecret)
                UserDefaults.standard.set(true, forKey: kUserIsAuthorized)
                UserDefaults.standard.synchronize()
                let userCredential = TMAPIUserCredentials.init(token: token, tokenSecret: secret)
                let session = TMURLSession.init(configuration: URLSessionConfiguration.default, applicationCredentials: applicationCredential, userCredentials: userCredential)
                self.client = TMAPIClient.init(session: session, requestFactory: TMRequestFactory.init())
                self.client?.userInfoDataTask(callback: { (result, error) in
                    if error == nil{
                        let resultJson = JSON.init(result)
                        let blogName = resultJson["user"]["name"].stringValue
                        UserDefaults.standard.setValue(blogName, forKey: kUserBlogName)
                    }
                }).resume()
                completionHandler(1)
            }
        })
    }
    
    func openURL(inBrowser url: URL!) {
        
        UIApplication.shared.openURL(url)
    }
    
    func handleOpenURL(url:URL!)->Bool{
        return self.authenticator!.handleOpen(url)
    }
    
}
