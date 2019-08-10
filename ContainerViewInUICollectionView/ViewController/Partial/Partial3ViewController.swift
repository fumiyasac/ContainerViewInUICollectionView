//
//  Partial3ViewController.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/07/10.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import UIKit

class Partial3ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - StoryboardInstantiatable

extension Partial3ViewController: StoryboardInstantiatable {

    // このViewControllerに対応するStoryboard名
    static var storyboardName: String {
        return "Article"
    }

    // このViewControllerに対応するViewControllerのIdentifier名
    static var viewControllerIdentifier: String? {
        return Partial3ViewController.className
    }
}
