//
//  LandscapeCategoryViewController.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/08/10.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import UIKit

final class LandscapeCategoryViewController: UIViewController {

    static let titleName: String = "風景・見どころ"

    // MARK: - Static Function

    static func make() -> ArticleViewController.DisplayViewControllerSet {

        // MEMO: ArticleViewControllerに定義したTypealiasに適合した形にする
        return (
            title: LandscapeCategoryViewController.titleName,
            viewController: LandscapeCategoryViewController.instantiate()
        )
    }

    // MARK: - Override

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - StoryboardInstantiatable

extension LandscapeCategoryViewController: StoryboardInstantiatable {

    // このViewControllerに対応するStoryboard名
    static var storyboardName: String {
        return "Category"
    }

    // このViewControllerに対応するViewControllerのIdentifier名
    static var viewControllerIdentifier: String? {
        return LandscapeCategoryViewController.className
    }
}
