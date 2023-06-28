//
//  FacialExpression.swift
//  Faceit
//
//  Created by 朱文杰 on 2023/6/27.
//

import Foundation

/// 面部表情模型
struct FacialExpression {
    
    /// 眼睛状态
    let eyes: Eyes
    
    /// 嘴巴状态
    let mouth: Mouth
    
    /// 悲伤一些的表情
    var sadder: FacialExpression {
        return FacialExpression(eyes: self.eyes, mouth: self.mouth.sadder)
    }
    
    /// 高兴一些的表情
    var happier: FacialExpression {
        return FacialExpression(eyes: self.eyes, mouth: self.mouth.happier)
    }
    
    /// 眼睛状态
    enum Eyes: Int {
        case open // 睁眼
        case closed // 闭眼
        case squinting // 眯眼
    }
    
    /// 嘴巴状态
    enum Mouth: Int {
        case frown // 撅嘴
        case smirk // 讥笑
        case neutral // 中心
        case grin // 咧嘴笑
        case smile // 大笑
        
        /// 悲伤一些的嘴巴
        var sadder: Mouth {
            return Mouth(rawValue: rawValue - 1) ?? .frown
        }
        
        /// 高兴一些的嘴巴
        var happier: Mouth {
            return Mouth(rawValue: rawValue + 1) ?? .smile
        }
    }
}
