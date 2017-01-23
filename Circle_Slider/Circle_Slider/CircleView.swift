//
//  CircleView.swift
//  Circle_Slider
//
//  Created by pxh on 2017/1/23.
//  Copyright © 2017年 pxh. All rights reserved.
//

import UIKit

class CircleView: UIView/*,UIGestureRecognizerState*/{
    
    typealias progressChange = (_ result : String,_ flag: Int)->()
    
    public
    var minNum : Int = 0
    var maxNum : Int = 0
    var units : NSString = ""
    var iconName : NSString = ""
    var _progress : CGFloat?
    var progress : CGFloat?{
        set{
            _progress = newValue
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseIn))
            CATransaction.setAnimationDuration(1)
            var pro : CGFloat = newValue!
            pro = pro < 0.0 ? 0.0 : pro
            pro = pro > 1.0 ? 1.0 : pro
            self.progressLayer.strokeEnd = pro
            
            var newCenter = self.trueCenter
            newCenter?.y += CGFloat(Double(self.arcRadius) * sin(M_PI/180.0 * Double((360.0 * pro - 90))))
            newCenter?.x += CGFloat(Double(self.arcRadius) * cos(M_PI/180.0 * Double((360.0 * pro - 90))))
            self.circle.center = newCenter!
            self.currentNum = self.minNum + Int(CGFloat(self.maxNum - self.minNum) * pro)
            self.numberLabel.text = "\(self.currentNum) \(self.units)"
            if let _ = progressSch{
                self.progressSch("\(self.currentNum)",self.flag)
            }
            CATransaction.commit()
        }
        get{
            return _progress
        }
    }
    var _enableCustom : Bool?
    var enableCustom : Bool?{
        set{
            _enableCustom = newValue
            if newValue! {
                
            }else{
            
            }
        }
        get{
            return _enableCustom
        }
    }
    var flag : Int = 0
    var progressSch : progressChange!
    
    private
    let CATProgressStartAngle = -90
    let CATProgressEndAngle = 270
    func DEGREES_TO_RADIANS(degrees : Double)->Double{
        return M_PI * degrees / 180
    }
    //dial appearance
    var dialRadius : CGFloat = 0
    //background circle appeareance
    var outerRadius : CGFloat = 0    //don't set this unless you want some squarish appearance
    var arcRadius : CGFloat = 0      //must be less than the outerRadius since view clips to bounds
    var arcThickness : CGFloat = 0
    var trueCenter : CGPoint!
    var numberLabel : UILabel!
    var iconImage : UIImageView!
    var startCircle : UIImageView!
    var currentNum : Int = 0
    var angle : Double = 0.0
    var circle : UIView!
    
    var trackLayer : CAShapeLayer!
    var progressLayer : CAShapeLayer!
    
    var panGesture : UIPanGestureRecognizer!
    
    //MARK: - pragma mark view appearance setup
    override init(frame: CGRect) {
        super.init(frame: frame)
        //overall view settings
        self.isUserInteractionEnabled = true
        self.clipsToBounds = true
        self.backgroundColor = UIColor.red
        
        //settings default values
        self.minNum = 0
        self.maxNum = 100
        self.currentNum = self.minNum
        self.units = ""
        self.iconName = ""
        
        //determine true center of view for calculating angle and setting up arcs
        let width : CGFloat = frame.width
        let height : CGFloat = frame.height
        self.trueCenter = CGPoint.init(x: width * 0.5, y: height * 0.5)
        
        //radii settings
        self.dialRadius = 10
        self.arcRadius = 80
        self.outerRadius = min(width, height * 0.5)
        self.arcThickness = 5.0
        
        //number label tracks progress around the circle
        self.numberLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 85, height: 25))
        self.numberLabel.text = "\(self.currentNum) \(self.units)"
        self.numberLabel.center = CGPoint.init(x: self.trueCenter.x, y: self.trueCenter.y + 20)
        self.numberLabel.textAlignment = NSTextAlignment.center
        self.numberLabel.font = UIFont.systemFont(ofSize: 14)
        self.numberLabel.textColor = UIColor.white
        self.addSubview(self.numberLabel)
        
        self.iconImage = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
        self.iconImage.center = CGPoint.init(x: self.trueCenter.x, y: self.trueCenter.y - 15)
        self.iconImage.image = UIImage.init(named: self.iconName as String)
        self.addSubview(self.iconImage)
        
        self.trackLayer = CAShapeLayer.init()
        self.trackLayer.frame = self.bounds
        self.trackLayer.fillColor = UIColor.clear.cgColor
        self.trackLayer.strokeColor = UIColor.white.cgColor
        self.trackLayer.opacity = 0.25 //背景圆环的背景透明度
        self.trackLayer.lineCap = kCALineCapRound
        self.layer.addSublayer(self.trackLayer)

        self.arcRadius = min(self.arcRadius, self.outerRadius - self.dialRadius)
        let path : UIBezierPath = UIBezierPath.init(arcCenter: self.trueCenter, radius: self.arcRadius, startAngle: CGFloat(DEGREES_TO_RADIANS(degrees: Double(CATProgressStartAngle))), endAngle: CGFloat(DEGREES_TO_RADIANS(degrees: Double(CATProgressEndAngle))), clockwise: true) //-210 到30的path
        self.trackLayer.path = path.cgPath
        self.trackLayer.lineWidth = self.arcThickness
        
        //2.进度轨迹
        self.progressLayer = CAShapeLayer.init()
        self.progressLayer.frame = self.bounds
        self.progressLayer.fillColor = UIColor.clear.cgColor
        self.progressLayer.strokeColor = UIColor.init(red: 210 / 255.0, green: 180 / 255.0, blue: 140 / 255.0, alpha: 1.0).cgColor  //不能用clearColor
        self.progressLayer.lineCap = kCALineCapRound
        self.progressLayer.strokeEnd = 0.0
        self.layer.addSublayer(self.progressLayer)
        
        let pathOne = UIBezierPath.init(arcCenter: self.trueCenter, radius: self.arcRadius, startAngle: CGFloat(DEGREES_TO_RADIANS(degrees: Double(CATProgressStartAngle))), endAngle: CGFloat(DEGREES_TO_RADIANS(degrees: Double(CATProgressEndAngle))), clockwise: true)
        self.progressLayer.path = pathOne.cgPath
        self.progressLayer.lineWidth = self.arcThickness
        
        var newCenter : CGPoint = self.trueCenter
        newCenter.y += CGFloat(Double(self.arcRadius) * sin(M_PI / 180 * (0 - 90)))
        newCenter.x += CGFloat(Double(self.arcRadius) * cos(M_PI / 180 * (0 - 90)))
        
        self.startCircle = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 14, height: 14))
        self.startCircle.center = newCenter
        self.startCircle.backgroundColor = UIColor.init(red: 210 / 255.0, green: 180 / 255.0, blue: 140 / 155.0, alpha: 1.0)
        self.startCircle.layer.cornerRadius = 7
        self.startCircle.layer.masksToBounds = true
        self.addSubview(self.startCircle)
        
        self.circle = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.dialRadius * 2, height: self.dialRadius * 2))
        self.circle.isUserInteractionEnabled = true
        self.circle.layer.cornerRadius = 10
        self.circle.backgroundColor = UIColor.white
        self.circle.center = self.trueCenter
        self.addSubview(self.circle)
        
        //pan gesture detects circle dragging
        panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(handlePan))
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        self.arcRadius = min(self.arcRadius, self.outerRadius - self.dialRadius)
        //label
        self.numberLabel.text = "\(self.currentNum) \(self.units)"
        self.iconImage.image = UIImage.init(named: self.iconName as String)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    
    //MARK:-pragma mark move circle in response to pan gesture
    func moveCircleToAngle(_ angle : Double){
        self.angle = angle
        var newCenter : CGPoint = self.trueCenter
        newCenter.y += CGFloat(Double(self.arcRadius) * sin(M_PI/180 * (angle - 90)))
        newCenter.x += CGFloat(Double(self.arcRadius) * cos(M_PI/180 * (angle - 90)))
        self.circle.center = newCenter
        self.currentNum = self.minNum + Int(Double(self.maxNum - self.minNum) * (angle / 360.0))
        self.numberLabel.text = "\(self.currentNum) \(self.units)"
        self.iconImage.image = UIImage.init(named: self.iconName as String)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseIn))
        CATransaction.setAnimationDuration(1)
        
        self.progressLayer.strokeEnd = CGFloat(angle / 360.0)
        if let _ = progressSch {
            self.progressSch("\(self.currentNum)",self.flag)
        }
        CATransaction.commit()
    }
    func createArcPathWithAngle(_ angle : Double,_ atPoint : CGPoint,_ radius : Float)->UIBezierPath{
        let endAngle : Float = Float((Int(angle) + 270 + 1) % 360)
        return UIBezierPath.init(arcCenter: atPoint, radius: CGFloat(radius), startAngle: CGFloat(DEGREES_TO_RADIANS(degrees: 270)), endAngle: CGFloat(DEGREES_TO_RADIANS(degrees: Double(endAngle))), clockwise: true)
    }
    //MARK: - pragma mark detect pan and determine angle of pan location vs. center of circular revolution
    func handlePan(_ sender : UIPanGestureRecognizer){
        let translation : CGPoint = sender.location(in: self)
        let x_displace : CGFloat = translation.x - self.trueCenter.x
        let y_displace : CGFloat = -1.0 * (translation.y - self.trueCenter.y)
        var radius : Double = Double(pow(x_displace, 2)) + Double(pow(y_displace, 2))
        radius = pow(radius, 0.5)
        var angle : Double = 180 / M_PI * asin(Double(x_displace) / radius)
        
        if x_displace > 0 && y_displace < 0 {
            angle = 180 - angle
        }else if(x_displace < 0){
            if (y_displace > 0){
                angle = 360.0 - angle
            }else if(y_displace <= 0){
                angle = 180 + -1.0 * angle
            }
        }
        self.moveCircleToAngle(angle)
    }
}
