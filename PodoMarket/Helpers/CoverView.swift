//
//  CoverView.swift
//  PodoMarket
//
//  Created by 정주리 on 2021/03/30.
//  Copyright © 2021 zool2. All rights reserved.
//

import UIKit

class CoverView: UIView {

    var coverView:UIView = {
        let view = UIView()
        view.frame = CGRect(x:0, y:0, width:414, height:896)
        view.backgroundColor = UIColor.white
        view.alpha = 0.5
        
        return view
    }()
}

