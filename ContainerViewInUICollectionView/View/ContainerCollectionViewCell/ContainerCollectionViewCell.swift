//
//  ContainerCollectionViewCell.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/07/10.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import UIKit

class ContainerCollectionViewCell: UICollectionViewCell {

    private var storedTargetViewController: UIViewController!

    // MARK: - Override

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {

        // Reuse実行時に表示対象のViewControllerから削除し、子として登録を解除する
        storedTargetViewController.view.removeFromSuperview()
        storedTargetViewController.willMove(toParent: nil)
    }

    // MARK: - Function

    func setCell(targetViewController: UIViewController, parentViewController: UIViewController) {

        // 表示対象のViewControllerを.contentViewへ追加する
        storedTargetViewController = targetViewController
        storedTargetViewController.view.frame = contentView.frame
        self.contentView.addSubview(storedTargetViewController.view)

        // 表示対象のViewControllerをparentViewControllerの子として登録する
        parentViewController.addChild(storedTargetViewController)
        storedTargetViewController.didMove(toParent: parentViewController)
    }
}
