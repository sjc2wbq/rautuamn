//
//  WebViewViewController.swift
//  QizhonghuiProject
//
//  Created by Raychen on 2016/7/29.
//  Copyright © 2016年 raychen. All rights reserved.
//

import UIKit
import WebKit
import MBProgressHUD
class WebViewViewController: UIViewController,WKNavigationDelegate{
    var urlStr :String = ""
      var webView: WKWebView!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        let configuration = WKWebViewConfiguration()
         webView = WKWebView(frame:view.bounds, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        view.addSubview(webView)

        // end forEach
        // let myURL = URL(string: "http://localhost:8042")
        let myURL = URL(string: urlStr)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        

    }
    func webView(_ myWebView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }
    
    func webView(_ myWebView: WKWebView, didCommit navigation: WKNavigation!) {
    }
    
    func webView(_ myWebView: WKWebView, didFinish navigation: WKNavigation!) {

    }
}
