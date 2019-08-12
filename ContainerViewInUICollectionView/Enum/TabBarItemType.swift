//
//  TabBarItemType.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/08/12.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import Foundation
import UIKit
import FontAwesome_swift
import ESTabBarController_swift

// MainTabBarControllerへ配置するものに関する設定

enum TabBarItemType: CaseIterable {

    // UITabBar部分に配置するコンテンツ
    case main
    case article
    case essay
    case stock

    // MARK: - Function

    // 該当のViewControllerを取得する
    func getViewController() -> UIViewController? {
        var storyboardName: String
        switch self {
        case .main:
            storyboardName = "Main"
        case .article:
            storyboardName = "Article"
        case .essay:
            storyboardName = "Essay"
        case .stock:
            storyboardName = "Stock"
        }
        return UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController()
    }

    // TabBarControllerのインデックス番号を取得する
    func getTabIndex() -> Int {
        switch self {
        case .main:
            return 0
        case .article:
            return 1
        case .essay:
            return 2
        case .stock:
            return 3
        }
    }

    // MainTabBarのタイトルを取得する
    func getTitle() -> String {
        switch self {
        case .main:
            return "好きなものリスト"
        case .article:
            return "記事サンプル一覧"
        case .essay:
            return "エッセイサンプル一覧"
        case .stock:
            return "お気に入り一覧"
        }
    }

    // MainTabBarに使うIconを取得する
    func getTabBarItem() -> ESTabBarItem {

        let itemSize = CGSize(width: 28.0, height: 28.0)
        let normalColor = UIColor.init(code: "#cccccc")

        switch self {
        case .main:
            let icon = UIImage.fontAwesomeIcon(name: .home, style: .solid, textColor: normalColor, size: itemSize)
            return ESTabBarItem.init(BouncesTabContentView(), title: "MAIN", image: icon, selectedImage: icon)
        case .article:
            let icon = UIImage.fontAwesomeIcon(name: .newspaper, style: .solid, textColor: normalColor, size: itemSize)
            return ESTabBarItem.init(BouncesTabContentView(), title: "ARTICLE", image: icon, selectedImage: icon)
        case .essay:
            let icon = UIImage.fontAwesomeIcon(name: .bookOpen, style: .solid, textColor: normalColor, size: itemSize)
            return ESTabBarItem.init(BouncesTabContentView(), title: "ESSAY", image: icon, selectedImage: icon)
        case .stock:
            let icon = UIImage.fontAwesomeIcon(name: .boxOpen, style: .solid, textColor: normalColor, size: itemSize)
            return ESTabBarItem.init(BouncesTabContentView(), title: "STOCK", image: icon, selectedImage: icon)
        }
    }
}
