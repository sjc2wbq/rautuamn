//
//  NSString+Extension.swift
//  QizhonghuiProject
//
//  Created by Raychen on 2016/6/29.
//  Copyright © 2016年 raychen. All rights reserved.
//

import UIKit

extension String{

    /**
     是否为手机号码
     */
    func isMobileNumber() -> Bool {
        return (isValidateByRegex("^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}$") || isValidateByRegex("^((13[0-2])|(145)|(15[5-6])|(176)|(18[5,6]))\\d{8}|(1709)\\d{7}$") || isValidateByRegex("^((133)|(153)|(177)|(173)|(18[0,1,9]))\\d{8}"))
    }
    /**
     是否为邮编
     */
    func isPostCode() -> Bool {
        return isValidateByRegex("[1-9]\\d{5}")
    }
    /**
     是否为密码
     */
    func isPassWord() -> Bool {
        let text = self as NSString
        return (text.length >= 6 && text.length <= 20)
    }
    fileprivate func isValidateByRegex(_ regex:String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
    func isEmptyString() -> Bool {
        let set = CharacterSet.whitespaces
        return trimmingCharacters(in: set).characters.count == 0
    }
    func width(_ font:CGFloat,height:CGFloat) -> CGFloat {
        return (self as NSString).boundingRect(with: CGSize(width: screenW, height: height), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: font)], context: nil).size.width
    }
    func height(_ font:CGFloat,wight:CGFloat) -> CGFloat {
     return (self as NSString).boundingRect(with: CGSize(width: wight, height: 2200), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: font)], context: nil).size.height
    }
    /*
     是否包含特殊字符
     */
    func containSpecialCharacters() -> Bool{
        let nameCharacters = CharacterSet(charactersIn: "_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789").inverted
        let userNameRange = (self as NSString).rangeOfCharacter(from: nameCharacters)
        if userNameRange.location != NSNotFound{
        return true
        }else{
        return false
        }
    }
}
