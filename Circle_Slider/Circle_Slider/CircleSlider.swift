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
            self.sendActions(for: UIControlEvents.valueChanged)
            self.setNeedsDisplay()
        }
        get{
            return _angle
        }
    }
    private
    var radius : CGFloat = 0
    
    var viewCenter : CGPoint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.lineWidth = 5
        self.angle = 280
        self.radius = self.frame.width * 0.5 - CGFloat(Double(self.lineWidth) * 0.5) - CGFloat(self.lineWidth * 2)
        self.backgroundColor = UIColor.red
        viewCenter = CGPoint.init(x: self.frame.width * 0.5, y: self.frame.height * 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //tool func
    func funcToRad(_ deg : CGFloat)->CGFloat{
        return CGFloat(M_PI) * deg / 180.0
    }
    func funcToDeg(_ rad : CGFloat)->CGFloat{
        return 180.0 * rad / CGFloat(M_PI)
    }
    func funcSQR(_ x : CGFloat)->CGFloat{
        return x * x
    }
    //draw
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let context = UIGraphicsGetCurrentContext()
        
//        let center : CGPoint = CGPoint.init(x: self.frame.width * 0.5, y: self.frame.height * 0.5)
        //1、绘制灰色的背景
        context?.addArc(center: viewCenter, radius: CGFloat(self.radius), startAngle: 0, endAngle: CGFloat(M_PI * 2.0), clockwise: false)
        UIColor.gray.setStroke()
        context?.setLineWidth(CGFloat(self.lineWidth))
        context?.setLineCap(CGLineCap.butt)
        context?.drawPath(using: CGPathDrawingMode.stroke)
        
        //2、绘制进度
        context?.addArc(center: center, radius: CGFloat(self.radius), startAngle: 0, endAngle: funcToRad(CGFloat(self.angle!)), clockwise: false)
        UIColor.green.setStroke()
        context?.setLineWidth(CGFloat(self.lineWidth))
        context?.setLineCap(CGLineCap.round)
        context?.drawPath(using: CGPathDrawingMode.stroke)
        
        //3.绘制拖动的小白块
        let handleCenter = pointFromAngle(CGFloat(self.angle!))
        context?.setShadow(offset: CGSize.zero, blur: 3, color: UIColor.blue.cgColor)
        UIColor.red.setStroke()
        context?.setLineWidth(CGFloat(self.lineWidth) * 2.0)
        context?.addEllipse(in: CGRect.init(x: handleCenter.x, y: handleCenter.y, width: CGFloat(self.lineWidth) * 2.0, height: CGFloat(self.lineWidth) * 2.0))
        context?.drawPath(using: CGPathDrawingMode.stroke)
    }
    func pointFromAngle(_ angleInt : CGFloat)->CGPoint{
        let center = CGPoint.init(x: viewCenter.x - CGFloat(self.lineWidth), y: viewCenter.y - CGFloat(self.lineWidth))
        //根据角度得到圆环上的坐标
        var result : CGPoint! = CGPoint.zero
        result.y = round(center.y + radius * sin(funcToRad(angleInt)))
        result.x = round(center.x + radius * cos(funcToRad(angleInt)))
        return result
    }
    //touch event
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        return true
    }
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)
        //获取触摸点
        let lastPoint = touch.location(in: self)
        //使用触摸点来移动小块
        self.moveHandle(lastPoint)
        //发送值改变事件
        self.sendActions(for: UIControlEvents.valueChanged)
        return true
    }
    func moveHandle(_ sender : CGPoint){
        //计算中心点到任意点的角度
        let currentAngle = AngleFromNorth(viewCenter, sender, false)
        let angleInt : Int = Int(floor(currentAngle))
        //保存新角度
        self.angle = angleInt
        //重新绘制
        self.setNeedsDisplay()
    }
    //计算中心点到任意点的角度
    func AngleFromNorth(_ p1 : CGPoint,_ p2 : CGPoint,_ flipped : Bool)->CGFloat{
        var v : CGPoint = CGPoint.init(x: p2.x - p1.x, y: p2.y - p1.y)
        let vmag : CGFloat = sqrt(funcSQR(v.x) + funcSQR(v.y))
        var result : CGFloat = 0
        v.x /= vmag
        v.y /= vmag
        let radians : Double = atan2(Double(v.y), Double(v.x))
        result = funcToDeg(CGFloat(radians))
        return result >= 0 ? result : result + 360.0
    }
}
