//
//  ViewController.swift
//  YHSlider
//
//  Created by 郭月辉 on 16/7/11.
//  Copyright © 2016年 Theshy. All rights reserved.
//

import UIKit

class ViewController: UIViewController, YHSliderDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let sil = YHSlider.init(frame: CGRect(x: 30, y: 100, width: 300, height: 80), minNum: 10, maxNum: 60, rule: 10, unit: nil)
        view.addSubview(sil)
        sil.delegate = self
    }
    
    func yhSliderValueChange(slider: YHSlider) {
        print(slider.value)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print(#function)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

