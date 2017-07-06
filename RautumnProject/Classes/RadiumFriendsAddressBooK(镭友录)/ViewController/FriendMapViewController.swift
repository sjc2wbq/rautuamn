//
//  FriendMapViewController.swift
//  RautumnProject
//
//  Created by xilaida on 2017/5/19.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import SDWebImage
import SimpleAlert
import ObjectMapper


class FriendMapViewController: UIViewController,MAMapViewDelegate {

    var mapView:MAMapView?
    var friends = [Friend]()
    var actionLocation = UIButton.init(type: .custom)
    var newFriends = [Friend]()
    var annotaions = [MAPointAnnotation]()
    
    var isFirstLocated = true
    
    var Acoordinates = [CLLocationCoordinate2D(latitude: 30.561, longitude: 104.105),
                        CLLocationCoordinate2D(latitude: 30.621, longitude: 104.105),
                        CLLocationCoordinate2D(latitude: 30.561, longitude: 104.905)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "镭约吧"
        
        print("friend = \(friends)")
        initMapView()
        
        getFriends()
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        mapView?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        mapView?.delegate = nil
    }
    
    // 初始化地图
    func initMapView() {
        mapView = MAMapView(frame: self.view.bounds)
        mapView?.showsCompass = false
        mapView?.showsScale = false
        mapView?.showsUserLocation = true
        mapView?.zoomLevel = 15
        mapView?.isRotateCameraEnabled = false
        mapView?.userTrackingMode = MAUserTrackingMode.follow
        
        self.view.addSubview(mapView!)
        
        actionLocation.frame = CGRect.init(x: 15.0, y: view.bounds.height-20.0-35.0-64.0, width: 35.0, height: 35.0)
        let image = originImge(#imageLiteral(resourceName: "mapLoction"), size: CGSize.init(width: 25, height: 25))
        actionLocation.setImage(image, for: .normal)
//        actionLocation.setImage(#imageLiteral(resourceName: "gpsnormal"), for: .normal)
        actionLocation.backgroundColor = UIColor.white
        actionLocation.layer.cornerRadius = 5.0
        actionLocation.imageView?.contentMode = .center
        self.view.addSubview(actionLocation)
        actionLocation.addTarget(self, action: #selector(loctionEvent), for: .touchUpInside)
    }
    
    func originImge(_ image:UIImage!, size:CGSize) -> UIImage {
        if UIScreen.main.scale == 2.0 {
            UIGraphicsBeginImageContextWithOptions(size, false, 2.0)
        } else {
            UIGraphicsBeginImageContext(size)
        }
        image.draw(in: CGRect.init(x: 0.0, y: 0.0, width: size.width, height: size.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
    func loctionEvent() {
        mapView?.setCenter((mapView?.userLocation.coordinate)!, animated: true)
    }
    
    func getFriends() {
        let headerResponse  =
            RequestProvider.request(api: ParametersAPI.rauFriendRecord(pageIndex: 1)).mapObject(type: RadiumFriendsAddressBooK.self)
                .shareReplay(1)
    
        headerResponse.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap().subscribe(onNext: { [unowned self] (model ) in
            DBTool.shared.saveAddressBook(dict: Mapper<RadiumFriendsAddressBooK>().toJSON(model))
            
            self.friends = model.friends
            self.addAnnotation()
            
            }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(rx_disposeBag)
        
        headerResponse.flatMap{$0.error}.subscribe(onNext: { (_) in
            
        }, onError:nil, onCompleted: nil, onDisposed: nil).addDisposableTo(rx_disposeBag)
    }
    

    // MARK: -- MAMapViewDelegate
    // 位置或者设备方向更新后，会调用此函数
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        
        if isFirstLocated {
            let coordinate = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
            
            mapView.setCenter(coordinate, animated: false)
            isFirstLocated = false
        }
        
    }
    
    // 添加标注
    func addAnnotation() {
        

        for friend in friends {
        
            if friend.lat == 0.0 {
                continue
            }
            newFriends.append(friend)
        }

        if newFriends.count == 0 {
            
            return
        }
        
        for (index,friend) in newFriends.enumerated() {
            
            let annotation = MAPointAnnotation()
            let coordine = CLLocationCoordinate2D(latitude: friend.lat, longitude: friend.lng)
            annotation.coordinate = coordine
            annotaions.append(annotation)
            
        }

        mapView?.addAnnotations(annotaions)
    }
    
    // 标注
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if annotation is MAPointAnnotation {
            let customReuseIndetifier: String = "customReuseIndetifier"
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: customReuseIndetifier) as? CustomAnnotationView
            
            if annotationView == nil {
                annotationView = CustomAnnotationView.init(annotation: annotation, reuseIdentifier: customReuseIndetifier)
                
                annotationView?.canShowCallout = false
                annotationView?.isDraggable = true
            
            }
            
            let index = annotaions.index(of: annotation as! MAPointAnnotation)
            print("index = \(index)")
            let friend = newFriends[index!]
            annotationView?.headerImageView?.sd_setImage(with: URL.init(string: (friend.headPortUrl)))
            
            return annotationView
        }
        
        return nil
    }
    
    // 选中标注
    func mapView(_ mapView: MAMapView!, didSelect view: MAAnnotationView!) {
        if view is CustomAnnotationView {
            let cusView = view as! CustomAnnotationView
            
            let index = annotaions.index(of: cusView.annotation as! MAPointAnnotation)
            
            let infoView = FriendMapInfoView.infoView()
            let info = newFriends[index!]
            infoView.info = info
            let alert = AlertController.init(view: infoView, style: .alert)
            self.present(alert, animated: true, completion: nil)
            
            infoView.cancelClickedBlock = {_ in
                mapView.deselectAnnotation(cusView.annotation, animated: true)
                alert.dismiss(animated: true, completion: nil)
            }
            
            infoView.sendClickedBlock = {_ in
                mapView.deselectAnnotation(cusView.annotation, animated: true)
                alert.dismiss(animated: true, completion: nil)
                
                let conversationVC = RCDChatViewController()
                conversationVC.conversationType = .ConversationType_PRIVATE;
                conversationVC.targetId = "\(info.userId)"
                print("sssss = \(conversationVC.targetId)")
                conversationVC.title = info.nickName
                conversationVC.displayUserNameInCell = false
                self.navigationController?.pushViewController(conversationVC, animated: true)
            }
        }
    }
    
    

}
