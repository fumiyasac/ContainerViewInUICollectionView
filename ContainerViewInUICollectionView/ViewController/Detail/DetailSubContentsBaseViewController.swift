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

        setupPageViewController()
    }

    // MARK: -  Private Function

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

            for view in targetPageViewController.view.subviews {
                if let scrollView = view as? UIScrollView {
                    scrollView.delegate = self
                }
            }

            // 最初に表示する画面として配列の先頭のViewControllerを設定する
            targetPageViewController.setViewControllers([targetViewControllerLists[0]], direction: .forward, animated: false, completion: nil)
        }
    }

    // 該当のIndex値と動かす方向に合わせて表示対象のUIViewControllerを表示させる
    private func moveToPageViewControllerFor(beforeIndex: Int, targetIndex: Int) {

        //
        if beforeIndex == targetIndex {
            return
        }

        //
        let targetDirection: UIPageViewController.NavigationDirection = (beforeIndex < targetIndex) ? .reverse : .forward
        if let targetPageViewController = pageViewController {
            targetPageViewController.setViewControllers([targetViewControllerLists[targetIndex]], direction: targetDirection, animated: true, completion: nil)
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
                let targetIndex = targetViewController.view.tag

                //
                moveToPageViewControllerFor(beforeIndex: beforeIndex, targetIndex: targetIndex)

                //
                currentIndex = targetViewController.view.tag

                //
                NotificationCenter.default.post(name: Notification.Name(rawValue: SynchronizeScreenNotification.UpdateSliderNotification.rawValue), object: self, userInfo: ["page" : currentIndex])
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

