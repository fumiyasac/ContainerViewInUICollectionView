//
//  BouncesTabContentView.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/08/12.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import Foundation
import UIKit
import ESTabBarController_swift

final class BouncesTabContentView: ESTabBarItemContentView {

    public var duration = 0.3

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)

        // MEMO: 選択時・非選択時の配色を設定する
        textColor = UIColor.init(code: "#cccccc")
        iconColor = UIColor.init(code: "#cccccc")
        highlightTextColor = UIColor.init(code: "#ffae00")
        highlightIconColor = UIColor.init(code: "#ffae00")
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override

    override func selectAnimation(animated: Bool, completion: (() -> ())?) {
        bounceTabContentAnimation()
        completion?()
    }

    override func reselectAnimation(animated: Bool, completion: (() -> ())?) {
        bounceTabContentAnimation()
        completion?()
    }
    
    // MARK: - Function

    // CoreAnimationを利用してアイコン表示部分のバウンドを利用する
    func bounceTabContentAnimation() {
        let impliesAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        impliesAnimation.values = [1.00 ,1.37, 0.92, 1.15, 0.96, 1.03, 1.00]
        impliesAnimation.duration = duration * 2
        impliesAnimation.calculationMode = CAAnimationCalculationMode.cubic
        imageView.layer.add(impliesAnimation, forKey: nil)
    }
}
