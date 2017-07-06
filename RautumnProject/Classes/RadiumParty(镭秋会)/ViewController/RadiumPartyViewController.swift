//
//  RadiumPartyViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/5.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import Eureka
import SwiftyDrop
class RadiumPartyViewController: UIViewController {
    // MARK:- 懒加载属性
  let emptyView = UIView(frame: UIApplication.shared.keyWindow!.bounds)
    var selectedIndex = 0
    fileprivate lazy var pageTitleView: PageTitleView = {[weak self] in
        let titleFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50)
        let titles = ["附近镭友", "附近活动", "附近群组", "镭友民调"]
        let titleView = PageTitleView(frame: titleFrame, titles: titles)
        titleView.delegate = self
        return titleView
        }()
    
    fileprivate lazy var pageContentView: PageContentView = {[weak self] in
        // 1.确定内容的frame
        let contentFrame = CGRect(x: 0, y: 50, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 50)
        // 2.确定所有的子控制器
        let vc1 = NearFriendViewController()
        let vc2 = NearActivityViewController()
        let vc3 = NearGroupViewController()
        let vc4 = NearOpinionPollsViewController()
        let pageContentView = PageContentView(frame: contentFrame, childVcs: [vc1,vc2,vc3,vc4], parentViewController: self)
        pageContentView.delegate = self
        
        return pageContentView
        }()

    override func viewDidLoad() {
        super.viewDidLoad()
            title = "镭秋会"
        emptyView.backgroundColor = UIColor.white
        // 设置UI界面
        setupUI()
           }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserModel.shared.rank.value == "U"{
            self.view.addSubview(emptyView)
            let vc = UIAlertController(title: "温馨提示", message: "开通注册会员后，才能浏览镭秋会的内容，是否去开通？", preferredStyle: .alert)
            vc.addAction(UIAlertAction(title: "取消", style: .cancel, handler: {_ in
                 let tabBarVC = UIApplication.shared.keyWindow?.rootViewController as! TabBarController
                    tabBarVC.selectedIndex = 0
            }))
            vc.addAction(UIAlertAction(title: "去开通", style: .default, handler: {[unowned self] _ in
                if UserModel.shared.inApp{
                    let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "InAppOpeningMemberTableViewController") as! InAppOpeningMemberTableViewController
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }else{
                    let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "OpeningMemberTableViewController") as! OpeningMemberTableViewController
                    vc.type = 2
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }
                
            }))
            self.present(vc, animated: true, completion: nil)
        }else{
            emptyView.removeFromSuperview()
        }
        
    }
   }
// MARK:- 设置UI界面
extension RadiumPartyViewController {
    
    fileprivate func setupUI() {
        
        // 1.添加TitltView
        view.addSubview(pageTitleView)
        
        // 2.添加contentView
        view.addSubview(pageContentView)
        
    }
    
}
extension RadiumPartyViewController{
    func rightBarButtonItemAction() {
        if selectedIndex == 1 {
            if UserModel.shared.rank.value == "M" && UserModel.shared.starLevel < 1{
                let vc = UIAlertController(title: "温馨提示", message: "对不起，您的镭友数达到8个以上，才能组局！", preferredStyle: .alert)
                vc.addAction(UIAlertAction(title: "确定", style: .cancel, handler: nil))
                self.present(vc, animated: true, completion: nil)
                return
            }
            let vc = CreateActivtyViewController()
            navigationController?.pushViewController(vc, animated: true)
        }else  if selectedIndex == 2 {
            if UserModel.shared.rank.value == "M" && UserModel.shared.starLevel < 1{
                let vc = UIAlertController(title: "温馨提示", message: "对不起，您的镭友数达到8个以上，才能组群！", preferredStyle: .alert)
                vc.addAction(UIAlertAction(title: "确定", style: .cancel, handler: nil))
                self.present(vc, animated: true, completion: nil)
                return
            }

           let vc =  UIStoryboard(name: "RadiumParty", bundle: nil).instantiateViewController(withIdentifier: "CreateGroupViewController")
//            let vc = CreateGroupViewController()
            navigationController?.pushViewController(vc, animated: true)
        }else  if selectedIndex == 3 {
            if UserModel.shared.rank.value == "M" && UserModel.shared.starLevel < 1 {
                let vc = UIAlertController(title: "温馨提示", message: "对不起，您的镭友数达到8个以上，才能发起民调！", preferredStyle: .alert)
                vc.addAction(UIAlertAction(title: "确定", style: .cancel, handler: nil))
         
                self.present(vc, animated: true, completion: nil)
                return
            }

            let vc = PollTableViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }

}
// MARK:- 遵守PageTitleViewDelegate协议
extension RadiumPartyViewController : PageTitleViewDelegate {
    func pageTitltView(_ titleView: PageTitleView, selectedIndex index: Int) {
        selectedIndex = index
        if index == 0 {
            self.navigationItem.rightBarButtonItem = nil
        }else{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"findFrinedPlus"), style: .plain, target: self, action: #selector(rightBarButtonItemAction))
        }
        pageContentView.setCurrentIndex(index)
    }
}

// MARK:- 遵守PageContentViewDelegate
extension RadiumPartyViewController : PageContentViewDelegate {
    func pageContentView(_ contentView: PageContentView, progress: CGFloat, sourceIndex: Int, targetIndex: Int) {
        selectedIndex = targetIndex
        if targetIndex == 0 {
            self.navigationItem.rightBarButtonItem = nil
        }else{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"findFrinedPlus"), style: .plain, target: self, action: #selector(rightBarButtonItemAction))
        }
        pageTitleView.setTitleWithProgress(progress, sourceIndex: sourceIndex, targetIndex: targetIndex)
    }
}
