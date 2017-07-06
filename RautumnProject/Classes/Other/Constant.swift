//
//  Constant.swift
//  QizhonghuiProject
//
//  Created by Raychen on 2016/7/1.
//  Copyright © 2016年 raychen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import XCGLogger
import MJRefresh
import ARSLineProgress
import SwiftyDrop
import MBProgressHUD
import RxDataSources
import IBAnimatable
let appDelegate = UIApplication.shared.delegate as! AppDelegate
let log: XCGLogger = {
    // Setup XCGLogger
    let log = XCGLogger.default

    #if USE_NSLOG // Set via Build Settings, under Other Swift Flags
        log.remove(destinationWithIdentifier: XCGLogger.Constants.baseConsoleDestinationIdentifier)
        log.add(destination: AppleSystemLogDestination(identifier: XCGLogger.Constants.systemLogDestinationIdentifier))
        log.logAppDetails()
    #else
    
        let logPath: URL = appDelegate.cacheDirectory.appendingPathComponent("XCGLogger_Log.txt")
        log.setup(level: .debug, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: logPath)

        // Add colour (using the ANSI format) to our file log, you can see the colour when `cat`ing or `tail`ing the file in Terminal on macOS
        // This is mostly useful when testing in the simulator, or if you have the app sending you log files remotely
        if let fileDestination: FileDestination = log.destination(withIdentifier: XCGLogger.Constants.fileDestinationIdentifier) as? FileDestination {
            let ansiColorLogFormatter: ANSIColorLogFormatter = ANSIColorLogFormatter()
            ansiColorLogFormatter.colorize(level: .verbose, with: .colorIndex(number: 244), options: [.faint])
            ansiColorLogFormatter.colorize(level: .debug, with: .black)
            ansiColorLogFormatter.colorize(level: .info, with: .blue, options: [.underline])
            ansiColorLogFormatter.colorize(level: .warning, with: .red, options: [.faint])
            ansiColorLogFormatter.colorize(level: .error, with: .red, options: [.bold])
            ansiColorLogFormatter.colorize(level: .severe, with: .white, on: .red)
            fileDestination.formatters = [ansiColorLogFormatter]
        }


    #endif
    let emojiLogFormatter = PrePostFixLogFormatter()
    emojiLogFormatter.apply(prefix: "🗯🗯🗯 ", postfix: " 🗯🗯🗯", to: .verbose)
    emojiLogFormatter.apply(prefix: "🔹🔹🔹 ", postfix: " 🔹🔹🔹", to: .debug)
    emojiLogFormatter.apply(prefix: "ℹ️ℹ️ℹ️ ", postfix: " ℹ️ℹ️ℹ️", to: .info)
    emojiLogFormatter.apply(prefix: "⚠️⚠️⚠️ ", postfix: " ⚠️⚠️⚠️", to: .warning)
    emojiLogFormatter.apply(prefix: "‼️‼️‼️ ", postfix: " ‼️‼️‼️", to: .error)
    emojiLogFormatter.apply(prefix: "💣💣💣 ", postfix: " 💣💣💣", to: .severe)
    log.formatters = [emojiLogFormatter]
    
    return log
}()
//MARK: - 常量
let screenW = UIScreen.main.bounds.size.width
let screenH = UIScreen.main.bounds.size.height
let bgColor = UIColor(colorLiteralRed: 239 / 255.0, green: 237 / 255.0, blue: 237 / 255.0, alpha: 1)
let placeHolderColor = UIColor.colorWithHexString("#DFDFDF")
let placeHolderImage = UIImage(named:"placeHolderImage")
let defaultHeaderImage = UIImage(named:"register_choseHeaderImg")
let btnNormalImage = UIImage(color: UIColor.colorWithHexString("#3562FF"))
let btnDisableImage = UIImage(color: UIColor.colorWithHexString("#CCCCCC"))
let palceHolderColor = UIColor.gray.withAlphaComponent(0.3)
protocol Drawer {
    /**
     画线
     :param: startPoint 起点
     :param: endPoint   终点
     */
    func drawLine(_ startPoint:CGPoint,endPoint:CGPoint)
}
extension Drawer where Self:UIView{
    
    
    func drawLine(_ startPoint:CGPoint,endPoint:CGPoint,lineH:CGFloat){
        let context = UIGraphicsGetCurrentContext()
        context?.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
        context?.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
        context?.setLineWidth(lineH)
        UIColor.colorWithHexString("#E5E5E5").set()
        //        UIColor.redColor().set()
        context?.strokePath();
    }
    func drawLine(_ startPoint:CGPoint,endPoint:CGPoint){
        let context = UIGraphicsGetCurrentContext()
        context?.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
        context?.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
        context?.setLineWidth(0.5)
        UIColor.colorWithHexString("#DEDEDE").set()
//        UIColor.redColor().set()
        context?.strokePath()
    }
}
extension UIView {
    
    func isLoading(showTitle:String , for view: UIView) -> AnyObserver<Bool> {
        var HUD : MBProgressHUD?
        return UIBindingObserver(UIElement: view, binding: { (hud, isLoading) in
            switch isLoading {
            case true:
                HUD =  MBProgressHUD.bwm_showAdded(to: view, title: showTitle)
            case false:
                HUD?.hide(true, afterDelay: 1)
                break
            }
        }).asObserver()
    }
}
extension UIViewController {
    func show(error:String)  {
        MBProgressHUD.bwm_showTitle(error, to: view, hideAfter: 1.5, msgType: BWMMBProgressHUDMsgType.error)
    }
    
    func show(success:String)  {
        MBProgressHUD.bwm_showTitle(success, to: view, hideAfter: 1.5, msgType: BWMMBProgressHUDMsgType.successful)
    }
    func show(info:String)  {
        MBProgressHUD.bwm_showTitle(info, to: view, hideAfter: 1.5, msgType: BWMMBProgressHUDMsgType.info)
    }


    func isShowHUD(viewController: UIViewController) -> AnyObserver<Bool> {
        let hud = HUD.hud()
        return UIBindingObserver(UIElement: viewController, binding: { (viewController, isLoading) in
            switch isLoading {
            case true:
                hud.show(viewController)
            case false:
                hud.dismiss()
                break
            }
        }).asObserver()
    }
    func isLoading(showTitle:String , for view: UIView) -> AnyObserver<Bool> {
        return UIBindingObserver(UIElement: view, binding: { (hud, isLoading) in
                switch isLoading {
            case true:
//                ARSLineProgress.showWithPresentCompetionBlock { () -> Void in
//                    print("Showed with completion block")
//                }
                    ARSLineProgress.ars_showOnView(view)
            case false:
                ARSLineProgress.hideWithCompletionBlock({ () -> Void in
                    print("Hidden with completion block")
                })
                    break
            }
        }).asObserver()
    }
    
    func isSuccess(showTitle:String , for view: UIView) -> AnyObserver<Bool> {
        return UIBindingObserver(UIElement: view, binding: { (hud, isSuccess) in
            switch isSuccess {
            case true:
                MBProgressHUD.bwm_showTitle(showTitle, to: view, hideAfter: 1.5, msgType: BWMMBProgressHUDMsgType.successful)
            case false:
                MBProgressHUD.bwm_showTitle(showTitle, to: view, hideAfter: 1.5, msgType: BWMMBProgressHUDMsgType.error)
                break
            }
        }).asObserver()
    }
 

   public func header(_ callBack:@escaping () -> ()) -> MJRefreshNormalHeader{
        let  header = MJRefreshNormalHeader {
            callBack()
        }
        header?.lastUpdatedTimeLabel.isHidden = true
        header?.isAutomaticallyChangeAlpha = true
    return header!
    }
  public  func footer(_ callBack:@escaping () -> ()) -> MJRefreshAutoNormalFooter
    {
        let footer = MJRefreshAutoNormalFooter { 
            callBack()
        }
        footer?.isAutomaticallyChangeAlpha = true
        footer?.isAutomaticallyRefresh = true
        footer?.isAutomaticallyHidden = true
        return footer!
    }
}


extension UITableView{
    func addFooterRefresh()  {
        let footer = MJRefreshAutoNormalFooter()
        footer.isAutomaticallyChangeAlpha = true
        footer.isAutomaticallyRefresh = true
        //        footer.isAutomaticallyHidden = true
        self.mj_footer = footer
    }
    func addHeaderRefresh() {
        let  header = MJRefreshNormalHeader()
        header.lastUpdatedTimeLabel.isHidden = true
        header.isAutomaticallyChangeAlpha = true
        self.mj_header = header
        
    }
}
extension UICollectionView{
    func addFooterRefresh()  {
        let footer = MJRefreshAutoNormalFooter()
        footer.isAutomaticallyChangeAlpha = true
        footer.isAutomaticallyRefresh = true
//        footer.isAutomaticallyHidden = true
        self.mj_footer = footer
    }
    func addHeaderRefresh() {
        let  header = MJRefreshNormalHeader()
        header.lastUpdatedTimeLabel.isHidden = true
        header.isAutomaticallyChangeAlpha = true
        self.mj_header = header
    }
}
func priceStringNo￥(_ price:Double) -> String {
    if price < 10000 {
        return "\(Int(price))"
    } else if price >= 10000 && price < 100000000{
        return String(format: "%.2f万",price/10000.00)
    } else{
        return String(format: "%.2f亿",price/100000000.00)
    }
}
func priceString(_ price:Double) -> String {
    if price < 10000 {
        return "\(price)"
    } else if price >= 10000 && price < 100000000{
        return String(format: "￥%.2f万",price/10000.00)
    } else{
        return String(format: "￥%.2f亿",price/100000000.00)
    }
}
func font(_ size:CGFloat) -> UIFont {
//    return UIFont(name: "PingFangSC-Light", size: size)!
    return UIFont.systemFont(ofSize: size)

}
func timeInterval(dateStr:String) -> TimeInterval?{
    let formart =  DateFormatter()
    formart.dateFormat = "YYYY-MM-dd HH:mm:ss"
    let newDate = formart.date(from: dateStr)
    if let newDate = newDate   {
        return TimeInterval(newDate.timeIntervalSince1970)
    }
    return nil

}

func timeInterval(date:Date) -> TimeInterval? {
    let formart =  DateFormatter()
    formart.dateFormat = "YYYY-MM-dd HH:mm:ss"
    let dateStr = formart.string(from: date)
    let newDate = formart.date(from: dateStr)
    if let newDate = newDate   {
        return TimeInterval(newDate.timeIntervalSince1970)
    }
    return nil
}
func time(timeInterval:String) -> String {
    let formart =  DateFormatter()
    formart.dateFormat = "YYYY-MM-dd HH:mm:ss"
let date = Date(timeIntervalSince1970: TimeInterval((timeInterval as NSString).substring(to: 10))!)
    return formart.string(from: date)
}


extension UIViewController{
    func setUpTabBarItem(imageNamed:String,selectedImageNamed:String) {
        tabBarItem.image = UIImage(named:imageNamed)?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        tabBarItem.selectedImage = UIImage(named: selectedImageNamed)?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.colorWithHexString("#757575")], for: UIControlState())
        tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.colorWithHexString("#ff8200")], for: UIControlState.selected)
        
    }
    
}
