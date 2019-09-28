//
//  DetailViewController.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/09/21.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import UIKit

final class DetailViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!

    // MARK: - Override

    override func viewDidLoad() {
        super.viewDidLoad()

        // NavigationBar分のスクロール位置がずれてしまうのでその考慮を行う
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
    }

    @IBAction func testAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - StoryboardInstantiatable

extension DetailViewController: StoryboardInstantiatable {

    // このViewControllerに対応するStoryboard名
    static var storyboardName: String {
        return "Detail"
    }

    // このViewControllerに対応するViewControllerのIdentifier名
    static var viewControllerIdentifier: String? {
        return nil
    }
}
