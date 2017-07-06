//
//  UIButton+Extension.swift
//  RxAlamofireExample
//
//  Created by Raychen on 16/6/3.
//  Copyright © 2016年 Droids on Roids. All rights reserved.
//

import UIKit
extension UIButton{
    /**
     倒计时
     - parameter timeOut:   时间
     - parameter title:     时间为0是的标题
     - parameter waitTitle: 正在倒计时显示的标题
     */
    public func startTime( timeOut:  Int,title:String = "获取验证码",waitTitle:String = "s" )  {
        var timeOut = timeOut
        let queue = DispatchQueue.global()
        let timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: UInt(0)), queue: queue)
    timer.scheduleRepeating(deadline: DispatchTime.now(), interval: DispatchTimeInterval.seconds(1), leeway: DispatchTimeInterval.seconds(0))
        timer.setEventHandler {
            if(timeOut<=0){ //倒计时结束，关闭
                (timer as! DispatchSource).cancel()
                DispatchQueue.main.async(execute: { 
                    self.isEnabled = true
                    self.setTitle(title, for: .normal)
                })
            }else{
                let seconds = timeOut % 60 == 0 ?60:timeOut % 60
                DispatchQueue.main.async(execute: {
                    self.isEnabled = false
                    self.setTitle("\(seconds)\(waitTitle)", for: .disabled)
                    self.setTitle("\(seconds)\(waitTitle)", for: .normal)
                })
                timeOut -= 1
            }
        }
        timer.resume()

    }
}
