
//
//  MainNavigationTitleView.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/08/03.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import Foundation
import UIKit

final class MainNavigationTitleView: CustomViewBase {
    
    private let maxPageCount: Int = 4
    private var currentPageCount: Int = 0

    @IBOutlet weak private var mainNavigationTitleLabel: UILabel!
    @IBOutlet weak private var mainNavigationPageControl: UIPageControl!

    // MARK: - Typealias

    // MEMO: 実際はタプルではあるが独自の型を与えて用途を明確にする
    typealias MainNavigationTitleInformation = (title: String, cellIndex: Int)

    // MARK: - Initializer

    required init(frame: CGRect) {
        super.init(frame: frame)

        setupMainNavigationTitleView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupMainNavigationTitleView()
    }

    // MARK: - Function

    // 配置されているViewControllerから引き渡された情報を反映する
    func setCurrentDisplayTitleInformation(_ info: MainNavigationTitleInformation) {

        // MainViewControllerから渡された値を反映する
        mainNavigationTitleLabel.text = info.title
        mainNavigationPageControl.currentPage = info.cellIndex

        // MEMO: 現在選択されているインデックス値と引数から渡されたインデックス値の差分を計算してアニメーションの方向を決める
        if currentPageCount == info.cellIndex {
            return
        }
        let result = (info.cellIndex - currentPageCount > 0)
        executeSlideAnimation(shouldMoveFromTop: result)

        // 現在選択されているインデックス時を変数に格納する
        currentPageCount = info.cellIndex
    }

    // MARK: - Private Function

    // 上下にタイトル名を表示している部分がスライドするアニメーションを実行する
    private func executeSlideAnimation(shouldMoveFromTop: Bool) {

        // MEMO: アニメーション対象のViewの親にあたるViewをマスクにする
        mainNavigationTitleLabel.superview?.layer.masksToBounds = true

        // MEMO: ラベル表示要素に対して上下にスライドするCoreAnimationの設定を行う
        let transition = CATransition()
        transition.type = CATransitionType.push
        transition.duration = 0.16
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

        var key: String
        if shouldMoveFromTop {
            transition.subtype = CATransitionSubtype.fromTop
            key = "next"
        } else {
            transition.subtype = CATransitionSubtype.fromBottom
            key = "previous"
        }
        mainNavigationTitleLabel.layer.removeAllAnimations()
        mainNavigationTitleLabel.layer.add(transition, forKey: key)
    }

    // NavigationTitleにはめ込むView要素の初期設定を行う
    private func setupMainNavigationTitleView() {
        
        // MEMO: UIPageControl及びUILabelのデザイン調整はInterfaceBuilderで行う
        mainNavigationPageControl.numberOfPages = maxPageCount
    }
}
