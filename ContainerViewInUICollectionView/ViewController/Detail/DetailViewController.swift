//
//  DetailViewController.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/09/21.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import UIKit

final class DetailViewController: UIViewController {

    // 下方向のスクロールを実施した際に画面を閉じる処理をするためのY軸方向のオフセット値のしきい値
    private let yOffsetLimit: CGFloat = -100.0

    // カスタムトランジション時に利用する、スクロール位置を考慮した戻る遷移時の矩形サイズ
    private (set)var dismissImageFrame: CGRect = CGRect.zero
    // カスタムトランジション時に利用する、遷移先の初期状態時の矩形サイズ
    private (set)var presentedImageFrame: CGRect = CGRect(
        x: 0,
        y: 0,
        width: UIScreen.main.bounds.size.width,
        height: UIScreen.main.bounds.size.width * 1.2
    )

    @IBOutlet weak private var detailScrollView: UIScrollView!
    @IBOutlet weak private var detailImageView: UIImageView!

    // MARK: - Override

    override func viewDidLoad() {
        super.viewDidLoad()

        setupScrollView()
    }

    // MARK: - Private Function

    private func setupScrollView() {

        // NavigationBar分のスクロール位置がずれてしまうのでその考慮を行う
        if #available(iOS 11.0, *) {
            detailScrollView.contentInsetAdjustmentBehavior = .never
        }
        detailScrollView.delegate = self
    }

    // 配置したScrollViewのY軸方向のオフセット値のしきい値を超えた際に画面を閉じる
    private func dismissScreenDependOnVertialPosition(_ yOffset: CGFloat) {
        if yOffset <= yOffsetLimit {

            // MEMO: カスタムトランジションに必要なFrame値を更新する
            dismissImageFrame = CGRect(
                x: 0,
                y: -detailScrollView.contentOffset.y,
                width: UIScreen.main.bounds.size.width,
                height: UIScreen.main.bounds.size.width * 1.2
            )
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - UIScrollViewDelegate

extension DetailViewController: UIScrollViewDelegate {

    // スクロールが検知された時に実行される処理
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dismissScreenDependOnVertialPosition(scrollView.contentOffset.y)
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
