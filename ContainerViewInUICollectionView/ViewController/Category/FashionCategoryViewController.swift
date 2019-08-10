//
//  FashionCategoryViewController.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/08/10.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import UIKit

final class FashionCategoryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - StoryboardInstantiatable

extension FashionCategoryViewController: StoryboardInstantiatable {

    // このViewControllerに対応するStoryboard名
    static var storyboardName: String {
        return "Category"
    }

    // このViewControllerに対応するViewControllerのIdentifier名
    static var viewControllerIdentifier: String? {
        return FashionCategoryViewController.className
    }
}
