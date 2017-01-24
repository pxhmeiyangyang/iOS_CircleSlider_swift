//
//  CircleSlider.swift
//  Circle_Slider
//
//  Created by pxh on 2017/1/24.
//  Copyright © 2017年 pxh. All rights reserved.
//

import UIKit

class CircleSlider: UIControl {

    public
    var lineWidth : Int = 0
    var _angle : Int?
    var angle : Int?{
        set{
            _angle = newValue
        }
        get{
            return _angle
        }
    }
    private
    var radius : Float = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.lineWidth = 5
        self.angle = 280
        self.radius = Float(self.frame.width * 0.5 - CGFloat(Double(self.lineWidth) * 0.5) - CGFloat(self.lineWidth * 2))
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
