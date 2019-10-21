//
//  DetailSubContentsTabViewController.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/10/19.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import UIKit

final class DetailSubContentsTabViewController: UIViewController {

    private let tabWidth: CGFloat = UIScreen.main.bounds.width / 3
    private let tabHeight: CGFloat = 44.0
    private let barHeight: CGFloat = 2.0

    private let tabTitles: [String] = [
        "最新情報一覧",
        "関連するおすすめ",
        "みんなのコメント"
    ]

    private var tabButtons: [UIButton] = []
    private var bottomLineView: UIView = UIView()

    // MARK: -  Property

    // UIScrollView内のレイアウト決定に関する処理
    // MEMO: viewDidLayoutSubviewsで行うUI部品の初期配置に関する処理となるのでこの形にしています
    private lazy var setContentsTabScrollView: (() -> ())? = {
        setupTabScrollView()
        setupTabButtonsInTabScrollView()
        setupTabBottomLineView()
        return nil
    }()

    // MARK: - @IBOutlet

    @IBOutlet weak private var tabScrollView: UIScrollView!

    // MARK: -  Override

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // ナビゲーション用のスクロールビューに関する設定をする
        setContentsTabScrollView?()
    }

    // MARK: -  Private Function

    // 配置したUIScrollView内に配置したUIButton押下時のアクション設定
    @objc private func tabButtonTapped(button: UIButton) {

        // 押されたボタンのタグを取得
        let page: Int = button.tag

        // UIScrollView内に配置したUIButtonの色とボタン下部でスライドするBar用Viewの位置調整
        setButtonsColorBy(page: page)
        setSliderPositionBy(page: page)
    }

    // コンテンツ表示用のUIScrollViewの設定
    private func setupTabScrollView() {
        tabScrollView.delegate = self
        tabScrollView.showsHorizontalScrollIndicator = false
    }

    // ボタン表示用のUIScrollViewの設定
    // MEMO: private lazy var setContentsTabScrollView: (() -> ())? 内に設定
    private func setupTabButtonsInTabScrollView() {

        // 配置したUIScrollView内のサイズを決定する
        tabScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: tabHeight)

        // UIScrollView内にUIButtonを配置する
        for i in 0..<tabTitles.count {
            let button = UIButton()
            let selectedColor = (i == 0) ? UIColor(code: "#ffaa00") : .lightGray
            button.frame = CGRect(
                x: tabWidth * CGFloat(i),
                y: 0,
                width: tabWidth,
                height: tabHeight
            )
            button.titleLabel!.font = UIFont(name: "HiraKakuProN-W3", size: 11)!
            button.setTitle(tabTitles[i], for: UIControl.State())
            button.tag = i
            button.addTarget(self, action: #selector(self.tabButtonTapped(button:)), for: .touchUpInside)
            button.setTitleColor(selectedColor, for: UIControl.State())
            tabButtons.append(button)
            tabScrollView.addSubview(button)
        }
    }

    // ボタン下部でスライドするBar用Viewの設定
    // MEMO: private lazy var setContentsTabScrollView: (() -> ())? 内に設定
    private func setupTabBottomLineView() {
        bottomLineView.frame = CGRect(
            x: 0,
            y: tabHeight - barHeight,
            width: tabWidth,
            height: barHeight
        )
        bottomLineView.backgroundColor = UIColor(code: "#ffaa00")
        tabScrollView.addSubview(bottomLineView)
        tabScrollView.bringSubviewToFront(bottomLineView)
    }

    // UIScrollView内に配置したUIButtonの色設定
    private func setButtonsColorBy(page: Int) {
        tabButtons.enumerated().forEach{ (i, button) in
            let selectedColor = (i == page) ? UIColor(code: "#ffaa00") : .lightGray
            button.setTitleColor(selectedColor, for: UIControl.State())
        }
    }

    // ボタン下部でスライドするBar用Viewの設定
    private func setSliderPositionBy(page: Int) {
        let afterFrame = CGRect(
            x: tabWidth * CGFloat(page),
            y: tabHeight - barHeight,
            width: tabWidth,
            height: tabHeight
        )
        UIView.animate(withDuration: 0.26, animations: {
            self.bottomLineView.frame = afterFrame
        })
    }
}

// MARK: - UIScrollViewDelegate

extension DetailSubContentsTabViewController: UIScrollViewDelegate {}

// MARK: - StoryboardInstantiatable

extension DetailSubContentsTabViewController: StoryboardInstantiatable {

    // このViewControllerに対応するStoryboard名
    static var storyboardName: String {
        return "Detail"
    }

    // このViewControllerに対応するViewControllerのIdentifier名
    static var viewControllerIdentifier: String? {
        return "DetailSubContentsTab"
    }
}
