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
            // 添加 捏合手势识别器，更改画面的缩放比例（不通过数据模型，直接控制视图）
            let handler = #selector(FaceView.changeScale(byReactingTo:))
            let pinchRecognizer = UIPinchGestureRecognizer(target: faceView, action: handler)
            faceView.addGestureRecognizer(pinchRecognizer)
            
            // 关联出口后，也立即更新一次UI
            updateUI()
        }
    }
    
    /// 面部表情模型
    var expression = FacialExpression(eyes: .open, mouth: .grin) {
        // 每当模型改变，都执行一次更新UI的操作
        didSet { updateUI() }
    }
    
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
