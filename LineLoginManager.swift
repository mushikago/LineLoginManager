//
//  LineLoginManager.swift
//  CheerMeUp
//
//  Created by Tetsuya Shiraishi on 2017/04/06.
//  Copyright © 2017年 MUSHIKAGO DESIGN STUDIO CO., LTD. All rights reserved.
//

import UIKit
import LineSDK
import GTMSessionFetcher
import FirebaseAuth

class LineLoginManager: NSObject, LineSDKLoginDelegate {
    
    var iSelf:UIViewController?
    var iFirebaseTokenFetcher:GTMSessionFetcher?
    var iValidationServerDomain = ""
    var iHud:HUDView?
    var iLineSDKAPI: LineSDKAPI?
    
    class var ins : LineLoginManager{
        struct Static{
            static let instance : LineLoginManager = LineLoginManager()
        }
        return Static.instance
    }
    
    public func initialize(_self:UIViewController){
        self.iSelf = _self
        self.iLineSDKAPI = LineSDKAPI(configuration: LineSDKConfiguration.defaultConfig())
        
        let LineSDKConfig = Bundle.main.infoDictionary!["LineSDKConfig"] as! Dictionary<String,AnyObject>
        self.iValidationServerDomain = LineSDKConfig["ValidationServerDomain"] as! String
        
        LineSDKLogin.sharedInstance().delegate = self
    }
    
    public func logout(CallBack:@escaping (_ success:Bool, _ error:Error?) -> Void){
        self.iLineSDKAPI?.logout(queue: DispatchQueue.main, completion: { (success:Bool, error:Error?) in
            CallBack(success, error)
//            if success{
//                print("LINE Logout Succeeded")
//                CallBack(true)
//            }else{
//                print("LINE Logout Failed \(error?.localizedDescription)")
//                CallBack(false)
//            }
        })
        
    }
    
    // MARK: LineSDKLoginDelegate
    
    func didLogin(_ login: LineSDKLogin, credential: LineSDKCredential?, profile: LineSDKProfile?, error: Error?) {
        
        if let error = error {
            print("LINE Login Failed with Error: \(error.localizedDescription) ")
            return
        }
        
        guard let profile = profile, let credential = credential, let accessToken = credential.accessToken else {
            print("Invalid Repsonse")
            return
        }
        
        print("LINE Login Succeeded")
        print("Access Token: \(accessToken.accessToken)")
        print("User ID: \(profile.userID)")
        print("Display Name: \(profile.displayName)")
        print("Picture URL: \(profile.pictureURL)")
        print("Status Message: \(profile.statusMessage)")
        /*
         if let userInfoVC = self.storyboard?.instantiateViewController(withIdentifier: "userInfoViewController") as? UserInfoViewController {
         var data = ["userid" : profile.userID,
         "displayname" : profile.displayName,
         "accesstoken" : accessToken.accessToken]
         
         if let pictureURL = profile.pictureURL {
         data["pictureurl"] = pictureURL.absoluteString
         }
         
         if let statusMessage = profile.statusMessage {
         data["statusmessage"] = statusMessage
         }
         
         userInfoVC.userData = data
         self.present(userInfoVC, animated: true, completion: nil)
         }
         */
        self.requestFirebaseAuthTokenWithLINEAccessToken(lineAccessToken: accessToken.accessToken)
        
    }
    
    private func requestFirebaseAuthTokenWithLINEAccessToken(lineAccessToken:String){
        
        if let fFetcher = self.iFirebaseTokenFetcher{
            if fFetcher.isFetching {
                fFetcher.stopFetching()
            }
        }
        
        let urlString = iValidationServerDomain + "/verifyToken"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!) //NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        let params: [String: String] = [
            "token": lineAccessToken
        ]
        do {
            let requestBody = try JSONSerialization.data(withJSONObject: params, options: [])
            let jsonStr = String(bytes: requestBody, encoding: .utf8)!
            print(jsonStr)
            
            request.httpBody = requestBody
            
            self.iFirebaseTokenFetcher = GTMSessionFetcher.init(request: request)
            if let _self = self.iSelf{
                self.iHud = HUDView.addHUDViewToView(view: _self.view)
            }
            
            
            self.iFirebaseTokenFetcher?.beginFetch(completionHandler: { (data:Data?, error:Error?) in
                
                if let _hud = self.iHud{
                    _hud.dismiss()
                }
                
                if let _data = data{
                    
                    if let jsonStr = String(data: _data, encoding: String.Encoding.utf8){
                        if let _data = jsonStr.data(using: .utf8){
                            do {
                                let dic = try JSONSerialization.jsonObject(with: _data, options: []) as! [String: String]
                                
                                let firebaseToken = dic["firebase_token"]
                                self.authenticateWithFirebaseToken(firebaseToken: firebaseToken!)
                                
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                    
                    
                    
                }else{
                    print("data is empty....")
                }
                
            })
            
            
        } catch (let e) {
            print(e)
        }
        
        
    }
    
    private func authenticateWithFirebaseToken(firebaseToken:String){
        NotificationCenter.default.post(name: Notification.Name(rawValue:"doAuthenticateWithFirebaseToken"), object: nil, userInfo: ["firebaseToken" : firebaseToken])
    }
    
}
