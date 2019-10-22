//
//  DetailSubContentsBaseViewController.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/10/19.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import UIKit

final class DetailSubContentsBaseViewController: UIViewController {

    // ページングして表示させるViewControllerを保持する配列
    private var targetViewControllerLists: [UIViewController] = []

    // ContainerViewにEmbedしたUIPageViewControllerのインスタンスを保持する
    private var pageViewController: UIPageViewController?

    // 現在UIPageViewControllerで表示しているViewControllerのインデックス番号
    private var currentIndex: Int = 0

    // MARK: - Override

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNotificationCenter()
        setupPageViewController()
    }

    // MARK: - deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private Function (for NotificationCenter)

    // MEMO: Notification名「MoveToSelectedSubContentsNotification」にて実行される処理
    @objc private func updateSelectedContents(_ notification: Notification) {
        if let targetIndex = notification.userInfo?["targetIndex"] as? Int {

            let beforeIndex = currentIndex
            let afterIndex = targetIndex

            // UIPageViewControllerの移動処理とインデックス値の更新を実行する
            moveToTargetPageViewControllerFor(beforeIndex: beforeIndex, afterIndex: afterIndex, byTabTapped: true)
            currentIndex = afterIndex
        }
    }

    // MARK: -  Private Function
    
    // 監視対象NotificationCenterの設定
    private func setupNotificationCenter() {

        // Notification名「MoveToSelectedSubContentsNotification」を監視対象に登録する
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateSelectedContents(_:)), name: Notification.Name(rawValue: SynchronizeScreenNotification.MoveToSelectedSubContentsNotification.rawValue), object: nil)
    }

    // UIPageViewControllerの設定
    private func setupPageViewController() {

        // UIPageViewControllerで表示したいViewControllerの一覧を取得する
        for index in (0...2) {
            let vc = DetailSubContentsListViewController.instantiate()
            vc.view.tag = index
            targetViewControllerLists.append(vc)
        }

        // ContainerViewと接続しているUIPageViewControllerを取得する
        for childViewController in children {
            if let targetPageViewController = childViewController as? UIPageViewController {
                pageViewController = targetPageViewController
            }
        }
        
        // UIPageViewControllerにおける初期設定をする
        if let targetPageViewController = pageViewController {
            
            // MEMO: Storyboardを利用する場合はTransitionStyleはInterfaceBuilderで設定する
            // UIPageViewControllerDelegate & UIPageViewControllerDataSourceの宣言
            targetPageViewController.delegate = self
            targetPageViewController.dataSource = self

            // 最初に表示する画面として配列の先頭のViewControllerを設定する
            targetPageViewController.setViewControllers([targetViewControllerLists[0]], direction: .forward, animated: false, completion: nil)
        }
    }

    // 該当のIndex値と動かす方向に合わせて表示対象のUIViewControllerを表示させる
    private func moveToTargetPageViewControllerFor(beforeIndex: Int, afterIndex: Int, byTabTapped: Bool = false) {

        // 変更前と変更後のインデックス値が等しい場合は以降の処理を行わない
        if beforeIndex == afterIndex {
            return
        }

        // 変更前と変更後のインデックス値の差分および処理の実行先を判断してPageViewControllerを動かす方向を決める
        var targetDirection: UIPageViewController.NavigationDirection
        if byTabTapped {
            targetDirection = (beforeIndex < afterIndex) ? .forward : .reverse
        } else {
            targetDirection = (beforeIndex < afterIndex) ? .reverse : .forward
        }

        if let targetPageViewController = pageViewController {
            targetPageViewController.setViewControllers([targetViewControllerLists[afterIndex]], direction: targetDirection, animated: true, completion: nil)
        }
    }
}

// MARK: - UIScrollViewDelegate

extension DetailSubContentsBaseViewController: UIScrollViewDelegate {}

// MARK: - UIPageViewControllerDelegate, UIPageViewControllerDataSource

extension DetailSubContentsBaseViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    // スワイプアニメーションでページが動いたタイミングで実行される
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        // スワイプアニメーションが完了していない場合は以降の処理を実行しない
        if !completed {
            return
        }

        // ここから先はUIPageViewControllerのスワイプアニメーション完了時に発動する
        if let targetViewControllers = pageViewController.viewControllers {
            if let targetViewController = targetViewControllers.last {

                // 受け取ったインデックス値を元にコンテンツ表示を更新する
                let beforeIndex = currentIndex
                let afterIndex = targetViewController.view.tag

                // UIPageViewControllerの移動処理とインデックス値の更新を実行する
                moveToTargetPageViewControllerFor(beforeIndex: beforeIndex, afterIndex: afterIndex, byTabTapped: false)
                currentIndex = afterIndex

                // Notification名「UpdateSliderNotification」を送信する
                NotificationCenter.default.post(name: Notification.Name(rawValue: SynchronizeScreenNotification.UpdateSliderNotification.rawValue), object: self, userInfo: ["targetIndex" : currentIndex])
            }
        }
    }

    // 逆方向にページ送りしたタイミングで実行される
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        // インデックスを取得してその値に応じてコンテンツを移動する
        guard let index = targetViewControllerLists.firstIndex(of: viewController) else {
            return nil
        }
        if index <= 0 {
            return nil
        }
        return targetViewControllerLists[index - 1]
    }
    
    // 順方向にページ送りしたタイミングで実行される
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        // インデックスを取得してその値に応じてコンテンツを移動する
        guard let index = targetViewControllerLists.firstIndex(of: viewController) else {
            return nil
        }
        if index >= targetViewControllerLists.count - 1 {
            return nil
        }
        return targetViewControllerLists[index + 1]
    }
}

