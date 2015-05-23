//
//  WatchView.swift
//  Twatch
//
//  Created by TaiWei on 15/5/23.
//  Copyright (c) 2015 TaiWei. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class WatchConfig : NSObject{
    //Background and marker image
    var bgImageName:String?
    
    //***Hands****
    var showSecondHand:Bool!=true //Show second hand or not
    var hourHandImageName:String? //File name of hour hand image
    var minHandImageName:String? //File name of minute hand image
    var secHandImageName:String? //File name of second hand image
    var handHasShadow:Bool!=false
}

class WatchView : UIView {
    var config:WatchConfig!
    
    var hourHand:CALayer!
    var minHand:CALayer!
    var secHand:CALayer! 
    var timer:NSTimer!

    init(rect:CGRect,config:WatchConfig){
        super.init(frame: rect)
        self.config=config
        defaultSetup()
    }

    required init(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
    func start(){
        timer=NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateWatch:", userInfo: nil, repeats: true)
    }
    
    func stop(){
        timer?.invalidate()
        //timer=nil
    }
    
    func updateWatch(theTimer:NSTimer) {
        let dateComp=NSCalendar.currentCalendar().components(NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit | NSCalendarUnit.SecondCalendarUnit, fromDate: NSDate())
        let sec=dateComp.second
        let min=dateComp.minute
        var hour=dateComp.hour
        //for PM time
        if hour>12  {
            hour-=12
        }
       
        let minAngle=degrees2Radians(Float(min*6)) //分针度数 /60.0*360
        let hourAngle=degrees2Radians(Float(hour*30))+minAngle/12 //时针度数 x/12.0*360
        
        //show Analog WatchFace
        if config.showSecondHand == true {
            let secAngle=degrees2Radians(Float(sec*6)) //秒针度数 /60.0*360
           
            secHand.removeAnimationForKey("transform")
            let ani=CABasicAnimation(keyPath: "transform")
            secHand.transform=CATransform3DMakeRotation(CGFloat(secAngle+Float(M_PI)), 0, 0, 1)
        }
        minHand.transform=CATransform3DMakeRotation(CGFloat(minAngle+Float(M_PI)), 0, 0, 1)
        hourHand.transform=CATransform3DMakeRotation(CGFloat(hourAngle+Float(M_PI)), 0, 0, 1)
        
    }
    
    func defaultSetup(){
        //Hands
        hourHand=setHourLayer(config.hourHandImageName==nil ?nil:UIImage(named:config.hourHandImageName!)!.CGImage)
        minHand=setMinuteLayer(config.minHandImageName==nil ? nil:UIImage(named:config.minHandImageName!)!.CGImage)
        self.layer.addSublayer(minHand)
        self.layer.addSublayer(hourHand)

        if config.showSecondHand==true {
            secHand=setSecondLayer(config.secHandImageName==nil ? nil:UIImage(named:config.secHandImageName!)!.CGImage)
           
            self.layer.addSublayer(secHand)
        }
        //self.layer.backgroundColor
    }

    
    private func degrees2Radians(degrees:Float)->Float{
        return Float(Double(degrees)*M_PI/Double(180))
    }
    
    //Watch Hands Setting
    //Hour hand layer
    func setHourLayer(image:CGImageRef!)->CALayer{
        let length=min(self.frame.size.width/2,self.frame.size.height/2) //
        var w,h:CGFloat
        let scale=1.0 //config.scale
        
        var hour=CALayer()
        
        hour.backgroundColor=UIColor.clearColor().CGColor
            hour.cornerRadius=0
            hour.contents=image
            w=CGFloat(CGImageGetWidth(image)/Int(scale))
            h=CGFloat(CGImageGetHeight(image)/Int(scale))

        hour.bounds=CGRect(x: 0, y: 0, width: w, height: h)
        
        let center=CGPoint(x:self.frame.size.width/2, y:self.frame.size.height/2) //center-point
        hour.position=center
        
        hour.anchorPoint=CGPoint(x: 0.5, y: 0)//Rotate from center
        
        if config.handHasShadow == true {
            addLayerShadow(hour)
        }
        return hour
    }
    
    //Minute hand layer
    func setMinuteLayer(image:CGImageRef!)->CALayer{
        let length=min(self.frame.size.width/2,self.frame.size.height/2)
        var w,h:CGFloat
       let scale=1.0  //config.scale
        
        var minute=CALayer()
            minute.backgroundColor=UIColor.clearColor().CGColor
            minute.contents=image
            w=CGFloat(CGImageGetWidth(image)/Int(scale))
            h=CGFloat(CGImageGetHeight(image)/Int(scale))

        minute.bounds=CGRect(x: 0, y: 0, width: w, height: h)
        
        let center=CGPoint(x:self.frame.size.width/2, y:self.frame.size.height/2) //center-point
        minute.position=center
        
        minute.anchorPoint=CGPoint(x: 0.5, y: 0)//Rotate from center
        
        if config.handHasShadow == true {
            addLayerShadow(minute)
        }
        return minute
    }
    
    //Second hand layer
    func setSecondLayer(image:CGImageRef!)->CALayer{
        let length=min(self.frame.size.width/2,self.frame.size.height/2) //
        var w,h:CGFloat
        let scale=1.0 //config.scale
        
        var sec=CALayer()
            sec.backgroundColor=UIColor.clearColor().CGColor
            sec.borderWidth=0
            sec.borderColor=UIColor.clearColor().CGColor
            sec.contents=image
            w=CGFloat(CGImageGetWidth(image)/Int(scale))
            h=CGFloat(CGImageGetHeight(image)/Int(scale))
        
        sec.anchorPoint=CGPoint(x: 0.5, y: 0)//Rotate from center
        sec.bounds=CGRect(x: 0, y: 0, width: w, height: h)
        let center=CGPoint(x:self.frame.size.width/2, y:self.frame.size.height/2) //Center
        sec.position=center
        //While not rotating from Center
        //sec.position=CGPoint(x: CGFloat(1+config.secXCorrection)*self.frame.size.width/2, y: CGFloat(1+config.secYCorrection)*self.frame.size.height/2)
        
        if config.handHasShadow == true {
            addLayerShadow(sec)
        }
        return sec
    }
    
    private func addLayerShadow(layer:CALayer?){
        if let l=layer {
            l.shadowColor=UIColor.blackColor().CGColor
            l.shadowOffset=CGSize(width: 1,height: 1)
            l.shadowOpacity=0.8
        }
    }
    
    deinit{
        self.stop()
    }

}