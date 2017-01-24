//
//  ViewController.swift
//  Circle_Slider
//
//  Created by pxh on 2017/1/19.
//  Copyright © 2017年 pxh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let dialView : CircleView = CircleView.init(frame: CGRect.init(x: 0, y: 0, width: 300, height: 300))
        self.view.addSubview(dialView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

