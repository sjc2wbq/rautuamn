//
//  CustomAnnotationView.swift
//  RautumnProject
//
//  Created by Kun Huang on 2017/5/25.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit

class CustomAnnotationView: MAAnnotationView {


    fileprivate let aWidth = 70.0
    fileprivate let aHeifht = 75.0
    fileprivate let imageR = 50.0
    
    public var selectBlock:(() -> Void)?
    var headerImageView: UIImageView?
    
    override init!(annotation: MAAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        buildUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buildUI() {
        self.frame = CGRect.init(x: 0.0, y: 0.0, width: aWidth, height: aHeifht)
        let backgroundImageView = UIImageView.init(frame: self.bounds)
        backgroundImageView.image = UIImage.init(named: "形状-8")
        backgroundImageView.contentMode = .scaleAspectFill
        
        self.addSubview(backgroundImageView)
        
        headerImageView = UIImageView.init(frame: CGRect.init(x: 0.0, y: 0.0, width: imageR, height: imageR))
        headerImageView?.layer.cornerRadius = CGFloat(imageR/2.0)
        
        headerImageView?.center = CGPoint.init(x: aWidth/2.0, y: aWidth/2.0)
        headerImageView?.clipsToBounds = true
        headerImageView?.contentMode = .scaleAspectFill
        backgroundImageView.addSubview(headerImageView!)
        
    
    }
    
    

}
