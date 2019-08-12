//
//  TabBarController.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/08/10.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import UIKit
import ESTabBarController_swift

final class TabBarController: ESTabBarController {

    // MARK: - Override

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabBarInitialSetting()
        setupTabBarContents()
    }

    // MARK: - Private Function

    // UITabBarControllerの初期設定に関する調整
    private func setupTabBarInitialSetting() {

        // UITabBarControllerDelegateの宣言
        self.delegate = self

        // 初期設定として空のUIViewControllerのインスタンスを追加する
        self.viewControllers = [UIViewController(), UIViewController(), UIViewController(), UIViewController()]
    }

    // TabBarControllerで表示したい画面に関する設定処理
    private func setupTabBarContents() {

        // TabBarに表示する画面を決める
        let _ = TabBarItemType.allCases.enumerated().map { (index, item) in
            
            // 該当ViewControllerの設置
            guard let vc = item.getViewController() else {
                fatalError()
            }
            self.viewControllers?[index] = vc

            // 該当ViewControllerのタイトル設置
            self.viewControllers?[index].tabBarItem = item.getTabBarItem()
        }
    }
}

// MARK: - UITabBarControllerDelegate

extension TabBarController: UITabBarControllerDelegate {}
