//
//  DetailSubContentsTabViewController.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/10/19.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import UIKit

final class DetailSubContentsTabViewController: UIViewController {

    // MARK: -  Override

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

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
