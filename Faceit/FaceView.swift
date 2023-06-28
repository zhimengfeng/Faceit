//
//  FaceView.swift
//  Faceit
//
//  Created by 朱文杰 on 2023/6/26.
//

import UIKit

@IBDesignable
class FaceView: UIView {
    
    @IBInspectable
    /// 缩放比率，setNeedsDisplay(): 在值发生变更时，调用draw()进行重绘
    var scale: CGFloat = 0.9 { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    /// 是否睁开眼睛
    var eyesOpen: Bool = true { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    /// 绘制线宽
    var lineWidth: CGFloat = 5.0 { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    /// 绘制颜色
    var color: UIColor = UIColor.blue { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    /// 嘴巴曲率：1.0:笑满，-1.0:苦脸满
    var mouthCurvature: Double = -0.5 { didSet { setNeedsDisplay() } }
    
    /// 改变缩放比率
    /// - Parameter pinchRecognizer: 捏合手势识别器
    @objc // @objc: 用于解决在 ViewController 中采用 #selector 关联手势识别器时报错的问题
    func changeScale(byReactingTo pinchRecognizer: UIPinchGestureRecognizer) {
        switch pinchRecognizer.state {
        case .changed: fallthrough
        case .ended:
            // print("changeScale is called: \(pinchRecognizer.scale)")
            scale *= pinchRecognizer.scale
            // 重置[识别器]的缩放比率，从而每次可以获得增量
            pinchRecognizer.scale = 1
        default:
            break
        }
    }
    
    // 头骨半径
    private var skullRadius: CGFloat {
        return min(bounds.size.width, bounds.size.height) / 2 * scale
    }
    
    // 头骨中心点
    private var skullCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }

    // 眼睛枚举
    private enum Eye {
        case left
        case right
    }
    
    override func draw(_ rect: CGRect) {
        // 头骨绘制：描边
        pathForSkull().stroke()
        // 左眼绘制：描边
        pathForEye(.left).stroke()
        // 右眼绘制：描边
        pathForEye(.right).stroke()
        // 嘴巴绘制：描边
        pathForMouth().stroke()
    }

    
    /// 头骨绘制路径
    /// - Returns: 头骨绘制的路径
    private func pathForSkull() -> UIBezierPath {
        // 路径：画圆弧，规定中心点，半径，起始角度，结束角度，是否顺时针
        let path = UIBezierPath(arcCenter: skullCenter, radius: skullRadius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: false)
        // 线宽
        path.lineWidth = lineWidth
        // 设置颜色
        color.set()
        return path
    }
    
    
    /// 眼睛绘制路径
    /// - Parameter eye: 左眼或右眼
    /// - Returns: 眼睛绘制的路径
    private func pathForEye(_ eye: Eye) -> UIBezierPath {
        
        /// 计算眼睛的圆心
        /// - Parameter eye: 左眼或右眼
        /// - Returns: 眼睛的圆心点
        func centerOfEye(_ eye: Eye) -> CGPoint {
            let eyeOffset = skullRadius / Ratios.skullRadiusToEyeOffset
            var eyeCenter = skullCenter
            eyeCenter.y -= eyeOffset
            eyeCenter.x += ((eye == .left) ? -1 : 1) * eyeOffset
            return eyeCenter
        }
        
        // 眼睛半径
        let eyeRadius = skullRadius / Ratios.skullRadiusToEyeRdius
        // 眼睛圆心
        let eyeCenter = centerOfEye(eye)
        
        let path: UIBezierPath
        if (eyesOpen) {
            // 路径：画圆弧，规定中心点，半径，起始角度，结束角度，是否顺时针
            path = UIBezierPath(arcCenter: eyeCenter, radius: eyeRadius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: false)
        }
        else {
            path = UIBezierPath()
            path.move(to: CGPoint(x: eyeCenter.x - eyeRadius, y: eyeCenter.y))
            path.addLine(to: CGPoint(x: eyeCenter.x + eyeRadius, y: eyeCenter.y))
        }
        
        // 线宽
        path.lineWidth = lineWidth
        // 设置颜色
        color.set()
        return path
    }
    
    /// 嘴巴绘制路径
    /// - Returns: 嘴巴绘制的路径
    private func pathForMouth() -> UIBezierPath {
        let mouthWidth = skullRadius / Ratios.skullRadiusToMouthWidth
        let mouthHeight = skullRadius / Ratios.skullRadiusToMouthHeigth
        let mouthOffset = skullRadius / Ratios.skullRadiusToMouthOffset
        
        let mouthRect = CGRect(x: skullCenter.x - mouthWidth / 2,
                               y: skullCenter.y + mouthOffset,
                               width: mouthWidth,
                               height: mouthHeight)
        
        // 嘴巴曲线的起始位置
        let start = CGPoint(x: mouthRect.minX, y: mouthRect.midY)
        // 嘴巴曲线的结束位置
        let end = CGPoint(x: mouthRect.maxX, y: mouthRect.midY)
        // 微笑偏移量: 保证在 -1 ～ 1 之间
        let smileOffset = CGFloat(max(-1, min(mouthCurvature, 1))) * mouthRect.height
        
        // 控制点1
        let cp1 = CGPoint(x: start.x + mouthRect.width / 3, y: start.y + smileOffset)
        // 控制点2
        let cp2 = CGPoint(x: end.x - mouthRect.width / 3, y: end.y + smileOffset)
        
        
        // 嘴巴线条
        let path = UIBezierPath()
        path.move(to: start)
        path.addCurve(to: end, controlPoint1: cp1, controlPoint2: cp2)
        path.lineWidth = lineWidth
        return path
    }
    
    
    /// 比率：头骨半径和对应属性的比率
    private struct Ratios {
        // 和 眼睛偏移的比率
        static let skullRadiusToEyeOffset: CGFloat = 3
        // 和 眼睛半径的比率
        static let skullRadiusToEyeRdius: CGFloat = 10
        // 和 嘴巴宽度的比率
        static let skullRadiusToMouthWidth: CGFloat = 1
        // 和 嘴巴高度的比率
        static let skullRadiusToMouthHeigth: CGFloat = 3
        // 和 嘴巴偏移的比率
        static let skullRadiusToMouthOffset: CGFloat = 3
    }
}
