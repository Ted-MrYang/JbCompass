//
//  CompassController.swift
//  CompassExample
//
//  Created by Liu Chuan on 2018/3/10.
//  Copyright © 2018年 LC. All rights reserved.
//

import UIKit
import CoreLocation
import Contacts
import AudioToolbox
import JbCompass

let screenH: CGFloat = UIScreen.main.bounds.height
let screenW: CGFloat = UIScreen.main.bounds.width

/// 指南针控制器
class CompassController: UIViewController {

    // MARK: - Lazy Loading View
    
    /// 刻度视图
    private lazy var dScaView: DegreeScaleView = {
        let viewF = CGRect(x: 0, y: 0, width: screenW * 0.9, height: screenW * 0.9)
        let scaleV = DegreeScaleView(frame: viewF)
        return scaleV
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        dScaView.center = view.center
    }
    
}

//MARK: - View Life Cycle
extension CompassController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
}

//MARK: - Configure
extension CompassController {
    
    /// 配置UI界面
    private func configUI() {
        view.backgroundColor = .black
        view.addSubview(dScaView)
        
        dScaView.computeDataAction([
            "喜神": LocalType.northEast,
            "福神": LocalType.northEast,
            "财神": LocalType.east,
            "阳贵": LocalType.south,
        ])
        dScaView.localSelected = "阳贵"
        dScaView.start()
    }
}
