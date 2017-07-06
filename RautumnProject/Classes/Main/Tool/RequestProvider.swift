        //
//  RequestProvider.swift
//  TargetObject
//
//  Created by Raychen on 2016/10/2.
//  Copyright © 2016年 raychen. All rights reserved.
//

import UIKit
import ObjectMapper
import AFNetworking
import RxSwift
import MBProgressHUD
import AliyunOSSiOS
        let PREURL = "http://www.rautumn.com/"
        let requestUrl = "http://www.rautumn.com/appserver/api"
        
        // http://www.rautumn.com:8070
        
//        let PREURL = "http://www.rautumn.com:8070/"
//        let requestUrl = "http://www.rautumn.com:8070/appserver/api"
        
//        let PREURL = "http://106.14.21.175/"
//        let requestUrl = "http://106.14.21.175/appserver/api"
//          let PREURL = "http://192.168.3.210:8080/rautumn/"
//          let requestUrl = "http://192.168.3.210:8080/rautumn/appserver/api"
        enum UploadFileType {
            case mp4
            case png
            case gif
            case mp3
    }
        struct UploadImages {
            
            var type = UploadFileType.png
            var imageUrl = ""
            
            init(type: UploadFileType, url: String){
                self.type = type
                self.imageUrl = url
            }
        }
        
class RequestProvider {

    ///网络请求
  static  func request(api:ParametersAPI) -> Observable<Result<(URLSessionDataTask, Any?)>> {

    let manager = AFHTTPSessionManager()
    log.info("====================================================================================")
    log.info("json =========  \(desEncryptToString(api.parameters))")
    log.info("====================================================================================")
    return
        Observable.create({ (observer) -> Disposable in
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            manager.post(requestUrl, parameters: api.parameters, progress: { (progress ) in
                }, success: { (task, response) in
                    log.info(response)
                    let json = response as! [String:Any]
                    if json["result_code"] as! String == "1"{
                        let message = json["message"] as! String
                        log.error("error============\(message)")
                        let error =  NSError(domain: message, code: 1, userInfo: nil)
                        observer.onNext(Result.failure(error))
                    }else{
                        observer.onNext(Result.success((task, response)))
                    }
                    observer.onCompleted()
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }, failure: { (_, error ) in
                      let error  = error as NSError
                    observer.onNext(Result.failure(NSError(domain:  error.userInfo["NSLocalizedDescription"] as! String, code: 1, userInfo: nil)))
                    observer.onCompleted()
                    log.error("error============\(error)")
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    
            })
            return Disposables.create()
        })
    }
    
    // 上传多张图片或者gif
    static func upLoadImageUrls(imageUrls:[String]) -> Observable<Result<String>>{
        log.info("upLoadImageUrls----\(upLoadImageUrls)")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if imageUrls.count == 0 {
             return Observable.create({ (observer) -> Disposable in
                observer.onNext(Result.success(""))
                observer.onCompleted()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                log.info("上传多张图片成功。。。")
                return Disposables.create()
             })
        }
         var result = ""
        var uploadCount = 0
        return Observable.create({ (observer) -> Disposable in
            for (index,imageUrl) in imageUrls.enumerated(){
                let put = OSSPutObjectRequest()
                put.bucketName = "rautumn"
                if imageUrl.hasSuffix(".gif") {
                    put.objectKey = "rautumn/iOS/image/\(NSDate().timeIntervalSince1970)\(index).gif"
                } else {
                    put.objectKey = "rautumn/iOS/image/\(NSDate().timeIntervalSince1970)\(index).png"
                }
               
                put.uploadingFileURL = URL(string:imageUrl)
                let putTask = appDelegate.ossClient?.putObject(put)
                putTask?.continue({ (task) -> Any? in
                    if task.error == nil{
                        uploadCount += 1
                         let publicURL =  appDelegate.ossClient?.presignPublicURL(withBucketName: put.bucketName, withObjectKey: put.objectKey).result as! String
                        result += "\(publicURL),"
                        if uploadCount == imageUrls.count{
                            result = (result as NSString).substring(to: (result as NSString).length - 1)
                             observer.onNext(Result.success(result))
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                              log.info("result----\(result)")
                            log.info("上传多张图片成功。。。")
                            observer.onCompleted()

                        }
                    }else{
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        observer.onNext(Result.failure(NSError(domain: "上传图片失败！", code: 1, userInfo: nil)))
                        observer.onCompleted()

                    }

                    return nil
                })
                
            }
            
            return Disposables.create()
        })

    }
    static func upload(type:UploadFileType,fileUrl:URL?) -> Observable<Result<String>> {
        
        print("url = \(fileUrl)")
        
        if let fileUrl = fileUrl{
            
            
            if fileUrl.absoluteString == "" {
                
                print("1111")
                return Observable.just(Result.success(""))
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            if fileUrl.absoluteString == UserModel.shared.vcrUrl {
                
                
                print("22222")
                
                return Observable.create({ (observer) -> Disposable in
                    observer.onNext(Result.success(""))
                    observer.onCompleted()
                    return Disposables.create()
                })
            }
            let put = OSSPutObjectRequest()
            switch type {
            case .mp4:
                put.bucketName = "rautumn"
                put.objectKey = "rautumn/iOS/video/\(NSDate().timeIntervalSince1970).mov"
            case .mp3:
                put.bucketName = "rautumn"
                put.objectKey = "rautumn/iOS/audioFile/\(NSDate().timeIntervalSince1970).aac"
                
            case .png:
                put.bucketName = "rautumn"
                put.objectKey = "rautumn/iOS/image/\(NSDate().timeIntervalSince1970).png"
            default: break
                
            }
            
            
            put.uploadingFileURL = fileUrl
            put.uploadProgress = {(bytesSent,totalByteSent,totalBytesExpectedToSend) in
                            log.info("bytesSent=====\(bytesSent) ==== totalByteSent==== \(totalByteSent) === totalBytesExpectedToSend===\(totalBytesExpectedToSend)")
            }
            let putTask = appDelegate.ossClient?.putObject(put)
    
            print("3333333")
        
            return Observable.create { (observer) -> Disposable in
                
                print("4445556")
                putTask?.continue(successBlock: { (task) -> Any? in
                    
                    print("sssss")
                    if task.error == nil{
                        print("---------------------")
                        let publicURL =  appDelegate.ossClient?.presignPublicURL(withBucketName: put.bucketName, withObjectKey: put.objectKey).result as! String
                        observer.onNext(Result.success(publicURL))
                        observer.onCompleted()
                    }else{
                        
                        var errorDomain = ""
                        if type == .mp4 {
                            errorDomain = "上传视频失败！"
                        } else if type == .mp3 {
                            errorDomain = "上传音频失败！"
                        } else {
                            errorDomain = "上传图片失败！"
                        }
                        
                        observer.onNext(Result.failure(NSError(domain: errorDomain, code: 1, userInfo: nil)))
                        observer.onCompleted()
                    }
                    log.info("上传\(type == .mp4 ? "视频" : "图片")成功。。。")
                    log.info("type-------\(type)----fileUrl-----\(fileUrl)")
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    
                    return nil
                })
                
                
                print("4444444")
                return Disposables.create()
            }
        }
        
        print("5555555")
        return Observable.just(Result.success(""))
    }
    
    ///上传视频或者图片
   static func upload(type:UploadFileType,data:Data) -> Observable<Result<String>> {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let put = OSSPutObjectRequest()
        switch type {
        case .mp4:
            put.bucketName = "rautumn"
            put.objectKey = "rautumn/iOS/video/\(NSDate().timeIntervalSince1970).mov"
        case .png:
            
            put.bucketName = "rautumn"
            put.objectKey = "rautumn/iOS/image/\(NSDate().timeIntervalSince1970).png"
        default: break
           
        }
        put.uploadingData = data
        put.uploadProgress = {(bytesSent,totalByteSent,totalBytesExpectedToSend) in
         log.info("bytesSent=====\(bytesSent) ==== totalByteSent==== \(totalByteSent) === totalBytesExpectedToSend===\(totalBytesExpectedToSend)")
        }

        let putTask = appDelegate.ossClient?.putObject(put)
 
       return Observable.create { (observer) -> Disposable in
        putTask?.continue(successBlock: { (task) -> Any? in
            if task.error == nil{
               let publicURL =  appDelegate.ossClient?.presignPublicURL(withBucketName: put.bucketName, withObjectKey: put.objectKey).result as! String
                observer.onNext(Result.success(publicURL))
                log.info("上传二进制文件成功！")
                log.info("type-------\(type)----data-----\(data)")
                log.info("上传\(type == .mp4 ? "视频" : "图片")成功。。。")
                observer.onCompleted()
                
            }else{
                observer.onNext(Result.failure(NSError(domain: type == .mp4 ? "上传视频失败！" : "上传图片失败！", code: 1, userInfo: nil)))
                observer.onCompleted()
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false

            return nil
        })

            return Disposables.create()
        }

    }
    //删除视频或者文件
   static func  deleteFile(type:UploadFileType,name:String) -> Observable<Result<Bool>> {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let delete = OSSDeleteObjectRequest()
        delete.bucketName = type == .mp4 ? "rautumn" : "rautumn"
        delete.objectKey = name
        let deleteTask = appDelegate.ossClient?.deleteObject(delete)
        deleteTask?.waitUntilFinished()
        return Observable.create { (observer) -> Disposable in
            if deleteTask!.error == nil {
                observer.onNext(Result.success(true))
            }else{
                observer.onNext(Result.failure(NSError(domain: type == .mp4 ? "删除视频失败！" : "删除图片失败！", code: 1, userInfo: nil)))
            }
            observer.onCompleted()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            return Disposables.create()
            
        }
    }
}
private extension RequestProvider{
     static func desEncryptToString(_ param:[String:Any]) -> String{
        var  str = ""
        param.forEach { (key,value) in
            str += "\(key)=\("\(value)".replacingOccurrences(of: "&", with: "%26", options: NSString.CompareOptions.literal, range: nil))&"
        }
        return (str as NSString).substring(to: (str as NSString).length - 1)
    }
}

public enum AlamofireError: Error {
    case ImageMapping(URLSessionDataTask)
    case JSONMapping(URLSessionDataTask)
    case StringMapping(URLSessionDataTask)
    case StatusCode(URLSessionDataTask)
    case Data(URLSessionDataTask)
    case Underlying(Error)
}

 extension ObservableType where E == Result<(URLSessionDataTask, Any?)> {

     func mapObject<T: Mappable>(type: T.Type) -> Observable<Result<ResponseInfo<T>>> {
        return
            observeOn(SerialDispatchQueueScheduler(qos:.background))
            .flatMap { result -> Observable<Result<ResponseInfo<T>>> in
                let info = result.map(transform: { (task, response) -> ResponseInfo<T> in
                    guard let object = Mapper<ResponseInfo<T>>().map(JSONObject: response) else {
                        throw AlamofireError.JSONMapping(task)
                    }
                    return    object

                })
                return    Observable.just(info)
            }
            .observeOn(MainScheduler.instance)
    }

}
