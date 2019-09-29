
//
//  ArticleNavigationTitleView.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/08/03.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import Foundation
import UIKit

final class ArticleNavigationTitleView: CustomViewBase {
    
    private let maxPageCount: Int = 4

    // 表示画面切り替え時の軽微な振動(Haptic Feedback)を追加する
    private let feedbackGenerator: UIImpactFeedbackGenerator = {
        let generator: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        return generator
    }()

    private var currentPageCount: Int = 0

    @IBOutlet weak private var articleNavigationTitleLabel: UILabel!
    @IBOutlet weak private var articleNavigationPageControl: UIPageControl!

    // MARK: - Typealias

    typealias ArticleNavigationTitleInformation = (title: String, cellIndex: Int)

    // MARK: - Initializer

    required init(frame: CGRect) {
        super.init(frame: frame)

        setupArticleNavigationTitleView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupArticleNavigationTitleView()
    }

    // MARK: - Function

    // 配置されているViewControllerから引き渡された情報を反映する
    func setCurrentDisplayTitleInformation(_ info: ArticleNavigationTitleInformation) {

        // MainViewControllerから渡された値を反映する
        articleNavigationTitleLabel.text = info.title
        articleNavigationPageControl.currentPage = info.cellIndex

        // MEMO: 現在選択されているインデックス値と引数から渡されたインデックス値の差分を計算してアニメーションの方向を決める
        if currentPageCount == info.cellIndex {
            return
        }
        let result = (info.cellIndex - currentPageCount > 0)
        executeSlideAnimation(shouldMoveFromTop: result)

        // 現在選択されているインデックス時を変数に格納する
        currentPageCount = info.cellIndex

        // HapticFeedbackを発火する
        feedbackGenerator.impactOccurred()
    }

    // MARK: - Private Function

    // 上下にタイトル名を表示している部分がスライドするアニメーションを実行する
    private func executeSlideAnimation(shouldMoveFromTop: Bool) {

        // MEMO: アニメーション対象のViewの親にあたるViewをマスクにする
        articleNavigationTitleLabel.superview?.layer.masksToBounds = true

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
        articleNavigationTitleLabel.layer.removeAllAnimations()
        articleNavigationTitleLabel.layer.add(transition, forKey: key)
    }

    // NavigationTitleにはめ込むView要素の初期設定を行う
    private func setupArticleNavigationTitleView() {

        // MEMO: UIPageControl及びUILabelのデザイン調整はInterfaceBuilderで行う
        articleNavigationPageControl.numberOfPages = maxPageCount
        articleNavigationPageControl.isEnabled = false
    }
}
