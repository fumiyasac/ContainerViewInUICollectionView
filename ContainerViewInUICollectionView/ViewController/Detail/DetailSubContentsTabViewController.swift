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

        setupNotificationCenter()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // ナビゲーション用のスクロールビューに関する設定をする
        setContentsTabScrollView?()
    }

    // MARK: - deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Private Function (for NotificationCenter)

    // MEMO: Notification名「UpdateSliderNotification」にて実行される処理
    @objc private func updatebottomLineViewPosition(_ notification: Notification) {
        if let targetIndex = notification.userInfo?["targetIndex"] as? Int {

            // UIScrollView内に配置したUIButtonの色とボタン下部でスライドするBar用Viewの位置調整
            setButtonsColorBy(targetIndex: targetIndex)
            setSliderPositionBy(targetIndex: targetIndex)
        }
    }

    // MARK: - Private Function (for addTarget)

    // 配置したUIScrollView内に配置したUIButton押下時のアクション設定
    @objc private func tabButtonTapped(button: UIButton) {

        // 押されたボタンのタグを取得
        let targetIndex: Int = button.tag

        // UIScrollView内に配置したUIButtonの色とボタン下部でスライドするBar用Viewの位置調整
        setButtonsColorBy(targetIndex: targetIndex)
        setSliderPositionBy(targetIndex: targetIndex)

        // Notification名「MoveToSelectedSubContentsNotification」を送信する
        NotificationCenter.default.post(name: Notification.Name(rawValue: SynchronizeScreenNotification.MoveToSelectedSubContentsNotification.rawValue), object: self, userInfo: ["targetIndex" : targetIndex])
    }

    // MARK: -  Private Function

    // 監視対象NotificationCenterの設定
    private func setupNotificationCenter() {

        // Notification名「UpdateSliderNotification」を監視対象に登録する
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatebottomLineViewPosition(_:)), name: Notification.Name(rawValue: SynchronizeScreenNotification.UpdateSliderNotification.rawValue), object: nil)
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
    private func setButtonsColorBy(targetIndex: Int) {
        tabButtons.enumerated().forEach{ (i, button) in
            let selectedColor = (i == targetIndex) ? UIColor(code: "#ffaa00") : .lightGray
            button.setTitleColor(selectedColor, for: UIControl.State())
        }
    }

    // ボタン下部でスライドするBar用Viewの設定
    private func setSliderPositionBy(targetIndex: Int) {
        let afterFrame = CGRect(
            x: tabWidth * CGFloat(targetIndex),
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
        return DetailSubContentsTabViewController.className
    }
}
