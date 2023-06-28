//
//  ViewController.swift
//  Faceit
//
//  Created by 朱文杰 on 2023/6/26.
//

import UIKit

class ViewController: UIViewController {
    
    /// 面部表情视图引用。
    /// 注意事项：引用时尽量保持 faceView?.eyes 的方式，防止初始化加载时未关联导致程序崩溃
    @IBOutlet weak var faceView: FaceView! {
        // 仅在关联出口时，执行一次
        didSet {
            // 添加 捏合 手势识别器，更改画面的缩放比例（不通过数据模型，直接控制视图）
            let pinchRecognizer = UIPinchGestureRecognizer(target: faceView, action: #selector(FaceView.changeScale(byReactingTo:)))
            faceView.addGestureRecognizer(pinchRecognizer)
            
            // 添加 轻触 手势识别器，切换：睁眼/闭眼
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleEyes(byReactingTo:)))
            tapRecognizer.numberOfTapsRequired = 1 // 轻触次数。虽然默认是1，此处为了演示，同时赋值为1
            tapRecognizer.numberOfTouchesRequired = 1 // 手指数量。虽然默认是1，此处为了演示，同时赋值为1
            faceView.addGestureRecognizer(tapRecognizer)
            
            // 添加 向上轻扫 手势识别器，让表情高兴一些
            let swipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(increaseHappiness))
            swipeUpRecognizer.direction = .up
            faceView.addGestureRecognizer(swipeUpRecognizer)
            
            // 添加 向下轻扫 手势识别器，让表情沮丧一些
            let swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(decreaseHappiness))
            swipeDownRecognizer.direction = .down
            faceView.addGestureRecognizer(swipeDownRecognizer)
            
            // 关联出口后，也立即更新一次UI
            updateUI()
        }
    }
    
    /// 面部表情模型
    var expression = FacialExpression(eyes: .open, mouth: .grin) {
        // 每当模型改变，都执行一次更新UI的操作
        didSet { updateUI() }
    }
    
    /// 轻触手势响应函数，轻触时切换眼睛的状态: 睁眼/闭眼
    /// - Parameter tapRecognizer: 轻触手势识别器
    @objc func toggleEyes(byReactingTo tapRecognizer: UITapGestureRecognizer) {
        if tapRecognizer.state == .ended {
            let eyes: FacialExpression.Eyes = (expression.eyes == .closed) ? .open : .closed
            expression = FacialExpression(eyes: eyes, mouth: expression.mouth)
        }
    }
    
    /// 向上轻扫手势响应函数，表情高兴一些
    @objc func increaseHappiness() { expression = expression.happier }
    
    /// 向下轻扫手势响应函数，表情沮丧一些
    @objc func decreaseHappiness() { expression = expression.sadder }
    
    /// 根据模型数据更新视图
    private func updateUI() {
        switch expression.eyes {
        case .open:
            faceView?.eyesOpen = true
        case .closed, .squinting:
            faceView?.eyesOpen = false
        }
        faceView?.mouthCurvature = mouthCurvatures[expression.mouth] ?? 0.0
    }
    
    /// 面部表情模型的[嘴巴状态] -> 脸部视图的[嘴巴曲率] 对应关系
    private let mouthCurvatures = [
        FacialExpression.Mouth.frown: -1.0,
        FacialExpression.Mouth.smirk: -0.5,
        FacialExpression.Mouth.neutral: 0.0,
        FacialExpression.Mouth.grin: 0.5,
        FacialExpression.Mouth.smile: 1.0
    ]
}
