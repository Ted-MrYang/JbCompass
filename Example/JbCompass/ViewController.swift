//
//  ViewController.swift
//  JbCompass
//
//  Created by zans.lb@foxmail.com on 11/11/2022.
//  Copyright (c) 2022 zans.lb@foxmail.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let openButton = UIButton()

    /// 开启指南针按钮
    ///
    /// - Parameter sender: UIButton
    @objc func openCompassBtn(_ sender: UIButton) {
        let compassVC = CompassController()
        compassVC.modalPresentationStyle = .fullScreen
        self.present(compassVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        openButton.setTitleColor(.blue, for: .normal)
        openButton.setTitle("open", for: .normal)
        openButton.addTarget(self, action: #selector(openCompassBtn(_:)), for: .touchUpInside)
        
        view.addSubview(openButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        openButton.sizeToFit()
        openButton.center = view.center
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

