//
//  YHSlider.swift
//  Slider
//
//  Created by 郭月辉 on 16/7/7.
//  Copyright © 2016年 Theshy. All rights reserved.
//

import UIKit

/**
 数据显示类型
 
 - integer: 整数
 - decimal: 小数
 */
enum SliderVlaueType: Int {
    case yHInteger = 0
    case yHDecimal = 1
}

protocol YHSliderDelegate: NSObjectProtocol {
    
    func yhSliderValueChange(slider: YHSlider)
}

class YHSlider: UIControl {
    
    // 刻度顶部间距
    private let ruleTopMagin: CGFloat = 5
    // 长刻度长度
    private let longRuleHeight: CGFloat = 20
    // 短刻度长度
    private let shortRuleHeight: CGFloat = 10
    // 刻度数值宽度
    private let rulerLbWidth: CGFloat = 20
    // 刻度数值高度
    private let rulerLbHeight: CGFloat = 12
    // animScale
    private let animScale: CGFloat = 1.4
    // 额外点击区域
    private let HANDLE_TOUCH_AREA: CGFloat = -15
    // 顶部数据与拖动view间距
    private let  topMargin: CGFloat = 5
    // 拖动view超出尺子的高度
    private let dragViewMargin: CGFloat = 5
    // 拖动view宽度
    private let dragViewWidth: CGFloat = 10
    // 显示Label高度
    private let topLbHeight: CGFloat = 20
    // 显示label的长度
    private let topLbWidth: CGFloat = 60
    

    var delegate: YHSliderDelegate?
    // sliderValue
    private var _value: CGFloat = 0
    // MARK: - value  getOnly
    var value: CGFloat {
        return _value
    }
    // 数据类型
    var disValueType: SliderVlaueType = .yHInteger
    // 拖动view的颜色
    var dragViewColor: UIColor? {
        didSet {
            dragView.backgroundColor = dragViewColor
        }
    }
    // ruler 颜色
    var backColor: UIColor? {
        didSet {
            rulerView.backgroundColor = backColor
        }
    }
    // 显示区域颜色
    var forGroundColor: UIColor = UIColor.cyanColor() {
        didSet {
            forGroundView.backgroundColor = forGroundColor
        }
    }
    // 最小值
    private var minNum: CGFloat = 0.0
    // 最大值
    private var maxNum: CGFloat = 0.0
    // 显示刻度
    private var rule: CGFloat = 0
    // 单位
    private var unit: String?
    // slider的整体frame
    private var sliderFrame: CGRect = CGRect.zero
    // 尺子view Frame
    private var rulerFrame: CGRect = CGRect.zero
    // 左右边界
    private var margin: CGFloat = 0.0
    // sliderValue
//    private var sliderValue: CGFloat = 0.0

    
    /**
     构造方法
     
     - parameter frame:  frame
     - parameter minNum: 最小值
     - parameter maxNum: 最大值
     - parameter rule:   刻度
     - parameter unit:   单位
     
     - returns: YHSlider
     */
    init(frame: CGRect, minNum: CGFloat, maxNum: CGFloat, rule: CGFloat, unit: String?) {
        super.init(frame: frame)
        if maxNum < minNum {
            print("最大值 < 最小值")
            return
        }
        self.minNum = minNum
        self.maxNum = maxNum
        self.rule = rule
        self.unit = unit
        self.sliderFrame = frame
        self.rulerView.backgroundColor = UIColor.orangeColor()
        self.userInteractionEnabled = true
        
        setupContent()
    }
    
    // MARK: - 设置内容
    private func setupContent() {
        self.backgroundColor = UIColor.clearColor()
        setupTopLabel()
        setupRulerView()
        setupForGroundView()
        setupDragView()

    }
    
    // MARK: - 显示label
    private func setupTopLabel() {
        
        rulerFrame = CGRect(x: 0, y: topLbHeight + topMargin + dragViewMargin, width: sliderFrame.size.width, height: sliderFrame.size.height - topLbHeight - topMargin - 2 * dragViewMargin)
        margin = rulerFrame.size.height * 0.5
        topLabel.frame = CGRect(x: margin - topLbWidth * 0.5, y: 0, width: topLbWidth, height: topLbHeight)
        displayLabelValue(topLabel, value: minNum)
        addSubview(topLabel)
    }
    
    // MARK: - 尺子view
    private func setupRulerView() {
        
        rulerView.frame = rulerFrame
        rulerView.layer.cornerRadius = rulerFrame.size.height * 0.5
        rulerView.layer.masksToBounds = true
        rulerView.userInteractionEnabled = false
        addSubview(rulerView)
        
        drawRule()
    }
    
    // MARK: - 显示区域
    private func setupForGroundView() {
        
        forGroundView.frame = CGRect(x: 0, y: 0, width: 0, height: rulerFrame.size.height)
//        forGroundView.layer.cornerRadius = rulerFrame.size.height * 0.5
        forGroundView.layer.masksToBounds = true
        forGroundView.backgroundColor = forGroundColor
        forGroundView.alpha = 0.3
        rulerView.addSubview(forGroundView)
    }
    
    // MARK: - 拖拽view
    private func setupDragView() {
        
        let dragFrame = CGRectMake(margin - dragViewWidth * 0.5, topLbHeight + topMargin, dragViewWidth, rulerFrame.size.height + 2 * dragViewMargin)
        dragView.frame = dragFrame
        dragView.layer.cornerRadius = dragViewWidth * 0.5
        dragView.layer.masksToBounds = true
        dragView.backgroundColor = UIColor.cyanColor()
        dragView.userInteractionEnabled = false
        addSubview(dragView)
    }
    
    // MARK: - 画刻度
    private func drawRule() {
        let count = Int((maxNum - minNum) / rule)
        if count < 1 {
            print("刻度数小于2个")
            return
        }
        
        //长刻度
        for i in 0...count {
            drawAction(CGFloat(i),count: count, isLong: true)
        }
        
        //短刻度
        for i in 0..<count {
            drawAction(CGFloat(i),count: count, isLong: false)
        }
        
    }
    
    /**
     划线
     
     - parameter index:  第几条
     - parameter index:  总共格子数
     - parameter isLong: 长短刻度
     */
    private func drawAction(index: CGFloat,count: Int, isLong: Bool) {
        let ruleH = isLong ? longRuleHeight : shortRuleHeight
        let cellW = (rulerFrame.size.width - 2 * margin) / CGFloat(count)
        let beginLoc = isLong ? index * cellW + margin : (index + 0.5) * cellW + margin
        let shapeLayer: CAShapeLayer = CAShapeLayer()
        let bezPath = UIBezierPath()
        bezPath.moveToPoint(CGPoint(x: beginLoc, y: ruleTopMagin))
        bezPath.addLineToPoint(CGPoint(x: beginLoc, y: ruleTopMagin + ruleH))
        bezPath.closePath()
        shapeLayer.path = bezPath.CGPath
        shapeLayer.strokeColor = UIColor.darkGrayColor().CGColor
        shapeLayer.fillColor = UIColor.darkGrayColor().CGColor
        shapeLayer.lineWidth = 1
        rulerView.layer.addSublayer(shapeLayer)
        
        if isLong {
            let rulerLb = UILabel()
            rulerLb.font = UIFont.systemFontOfSize(12)
            rulerLb.textColor = UIColor.darkGrayColor()
            rulerLb.textAlignment = .Center
            rulerLb.backgroundColor = UIColor.clearColor()
            rulerLb.frame = CGRectMake(index * cellW + margin - rulerLbWidth * 0.5, CGRectGetMaxY(rulerFrame) - rulerLbHeight, rulerLbWidth, rulerLbHeight)
            displayLabelValue(rulerLb, value: minNum + rule * index)
            addSubview(rulerLb)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        
        let touchPoint: CGPoint = touch.locationInView(self)
        if CGRectContainsPoint(CGRectInset(self.dragView.frame,HANDLE_TOUCH_AREA, 0), touchPoint) {
            
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.3)
            // kCAMediaTimingFunctionEaseInEaseOut
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: "easeInEaseOut"))
            self.topLabel.transform = CGAffineTransformMakeScale(animScale, animScale)
            CATransaction.commit()
            
            refreshSlider(touchPoint)
            return true
        }
        return false
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let touchPoint: CGPoint = touch.locationInView(self)
        if CGRectContainsPoint(CGRectInset(self.dragView.frame,HANDLE_TOUCH_AREA, 0), touchPoint) {
            refreshSlider(touchPoint)
            return true
        }
        return false

    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.3)
        // kCAMediaTimingFunctionEaseInEaseOut
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: "easeInEaseOut"))
        self.topLabel.transform = CGAffineTransformIdentity
        CATransaction.commit()
        
        guard let touchPoint: CGPoint = touch!.locationInView(self) else {
            return
        }
        if CGRectContainsPoint(CGRectInset(self.dragView.frame,HANDLE_TOUCH_AREA, 0), touchPoint) {
            refreshSlider(touchPoint)
        }
    }
    
    // MARK: - 更新label
    private func refreshSlider(point: CGPoint) {
        
        var touchPoint: CGPoint = point
        if touchPoint.x < margin {touchPoint.x = margin}
        if touchPoint.x > self.rulerView.frame.width - margin {
            touchPoint.x = self.rulerView.frame.width - margin
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        var newFrame: CGRect = self.dragView.frame
        newFrame.origin.x = touchPoint.x - dragViewWidth * 0.5
        self.dragView.frame = newFrame
        self.topLabel.center.x = CGRectGetMidX(newFrame)
        
        let sliderValue = minNum + ((touchPoint.x - margin)/(self.rulerView.frame.width - 2 * margin)) * (maxNum - minNum)
        self.displayLabelValue(topLabel, value: sliderValue)
        
        var newForGFrame = forGroundView.frame
        newForGFrame.size.width = touchPoint.x
        forGroundView.frame = newForGFrame
        
        CATransaction.commit()
    }
    
    // MARK: - 更新数值
    private func displayLabelValue(label: UILabel, value: CGFloat) {
        
        _value = value
        delegate?.yhSliderValueChange(self)
        
        var valueStr: String?
        switch self.disValueType {
        case .yHInteger:
            valueStr = String(format: "%d", Int(value))
        default:
            valueStr = String(format: "%.1f", value)
        }

        if label.tag == 123 {
            if unit != nil {
                valueStr = valueStr! + unit!
            }
        }
        label.text = valueStr
    }
    
    private lazy var rulerView: UIView = UIView()
    private lazy var dragView: UIView = UIView()
    private lazy var forGroundView: UIView = UIView()
    private lazy var topLabel: UILabel = {
       let lb = UILabel()
        lb.font = UIFont.systemFontOfSize(12)
        lb.textColor = UIColor.blueColor()
        lb.backgroundColor = UIColor.clearColor()
        lb.textAlignment = .Center
        lb.tag = 123
        return lb
    }()

}



