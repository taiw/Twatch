//
//  InterfaceController.swift
//  Twatch WatchKit Extension
//
//  Created by TaiWei on 14/11/21.
//  Copyright (c) 2015 TaiWei. All rights reserved.
//

import WatchKit
import Foundation
import QuartzCore

class InterfaceController: WKInterfaceController {
 
    var _watchView: WatchView!

    var rect:CGRect!
    
    @IBOutlet weak var hands: WKInterfaceGroup! //Watch Hands
    @IBOutlet weak var bg: WKInterfaceGroup! //WatchFace background
    
    override init(){
        super.init()
        rect=WKInterfaceDevice.currentDevice().screenBounds
        // config - you may change it with customized loading method
        let config=WatchConfig()
        config.showSecondHand=true //But it's slow
        config.handHasShadow=true
        config.setValue("bg-default.jpg", forKey: "bgImageName") //metal
        
        config.setValue("sechand.png", forKey: "secHandImageName")
        config.setValue("minhand.png", forKey: "minHandImageName")
        config.setValue("hourhand.png", forKey: "hourHandImageName")
        
        _watchView=WatchView(rect: rect,config:config)
    }
    
    override func awakeWithContext(context: AnyObject!) {
      super.awakeWithContext(context)
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "update", userInfo: nil, repeats: true)
       
        
    }
    
    override func willActivate() {
        super.willActivate()
        _watchView.start()
        hands.setBackgroundImageData(dataOfViewImage(_watchView))
        
        bg.setBackgroundImageNamed(_watchView.config.bgImageName)
    }
    
    func update(){
       hands.setBackgroundImageData(dataOfViewImage(_watchView))
        let df=NSDateFormatter()
        df.dateFormat="yy-MM-dd"
        self.setTitle(df.stringFromDate(NSDate()))

      
    }
    
    func dataOfViewImage(view:UIView)->NSData{
        UIGraphicsBeginImageContext(view.bounds.size)
        
        view.layer.renderInContext(UIGraphicsGetCurrentContext())
        let img:UIImage=UIGraphicsGetImageFromCurrentImageContext()
        let imgData:NSData=UIImagePNGRepresentation(img)// UIImageJPEGRepresentation(img,100)
        UIGraphicsEndImageContext()
        return imgData
    }

    override func didDeactivate() {
        _watchView.stop()
        super.didDeactivate()
    }
}
