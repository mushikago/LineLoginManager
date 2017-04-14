//
//  HUDView.swift
//  CheerMeUp
//
//  Created by Tetsuya Shiraishi on 2017/04/05.
//  Copyright © 2017年 MUSHIKAGO DESIGN STUDIO CO., LTD. All rights reserved.
//

import UIKit

class HUDView: UIView {
    
    let kLoadingViewSize:CGFloat = 80
    let kLoadingViewCornerRadius:CGFloat = 6.0

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    class func addHUDViewToView(view:UIView) -> HUDView{
        
        
        struct Static{
            static let hud : HUDView = HUDView()
        }
        
        let loadingView:UIView = self.loadingView(Static.hud)()
        Static.hud.addSubview(loadingView)
        Static.hud.frame = view.bounds
        loadingView.center = Static.hud.center
        view.addSubview(Static.hud)
        view.bringSubview(toFront: Static.hud)
        
        return Static.hud
        
        
        
    }
    
    func loadingView() -> UIView{
        let fullFrame = CGRect(x: 0, y: 0, width: kLoadingViewSize, height: kLoadingViewSize)
        let view = UIView(frame: fullFrame)
        view.layer.cornerRadius = kLoadingViewCornerRadius
        view.backgroundColor = UIColor.gray
        
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        view.addSubview(spinner)
        spinner.startAnimating()
        spinner.center = CGPoint(x: kLoadingViewSize * 0.5, y: kLoadingViewSize * 0.5)
        
        return view
    }
    
    
    public func dismiss(){
        self.removeFromSuperview()
    }
    
    
}
