//
//  ContainerCollectionViewCell.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/07/10.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import UIKit

final class ContainerCollectionViewCell: UICollectionViewCell {

    // MEMO: このセルはリサイクルして利用する前提なので弱参照にしています。
    private weak var storedTargetViewController: UIViewController!

    // MARK: - Typealias

    typealias DisplayViewControllerInContainerViewInformation = (targetViewController: UIViewController, parentViewController: UIViewController)

    // MARK: - Override

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {

        // Reuse実行時に表示対象のViewControllerから削除し、子として登録を解除する
        storedTargetViewController.view.removeFromSuperview()
        storedTargetViewController.willMove(toParent: nil)
        storedTargetViewController.removeFromParent()
    }

    // MARK: - Function

    func setCell(_ info: DisplayViewControllerInContainerViewInformation) {

        storedTargetViewController = info.targetViewController

        // 表示対象のViewControllerを.contentViewへ追加する
        storedTargetViewController.view.frame = contentView.frame
        self.contentView.addSubview(storedTargetViewController.view)

        // 表示対象のViewControllerをparentViewControllerの子として登録する
        info.parentViewController.addChild(storedTargetViewController)
        storedTargetViewController.didMove(toParent: info.parentViewController)
    }
}
