//
//  FoodCategoryViewController.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/07/30.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import UIKit

final class FoodCategoryViewController: UIViewController {

    static let titleName: String = "お食事・グルメ"

    // MARK: - Static Function

    static func make() -> ArticleViewController.DisplayViewControllerSet {
        
        // MEMO: ArticleViewControllerに定義したTypealiasに適合した形にする
        return (
            title: FoodCategoryViewController.titleName,
            viewController: FoodCategoryViewController.instantiate()
        )
    }

    // MARK: - Override

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - StoryboardInstantiatable

extension FoodCategoryViewController: StoryboardInstantiatable {

    // このViewControllerに対応するStoryboard名
    static var storyboardName: String {
        return "Category"
    }

    // このViewControllerに対応するViewControllerのIdentifier名
    static var viewControllerIdentifier: String? {
        return FoodCategoryViewController.className
    }
}
