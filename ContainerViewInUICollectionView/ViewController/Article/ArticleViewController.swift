//
//  ArticleViewController.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/07/10.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import UIKit
import AnimatedCollectionViewLayout

final class ArticleViewController: UIViewController {

    // タイトル表示用のView
    private let titleView = ArticleNavigationTitleView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))

    // MEMO: UICollectionViewCell内に表示させる要素を格納するための変数
    private var displayViewControllers: [UIViewController] = []

    // MEMO: UICollectionViewCell内にContainerViewとして他のViewControllerを配置する
    @IBOutlet weak private var collectionView: UICollectionView!

    // MARK: - Override

    override func viewDidLoad() {
        super.viewDidLoad()

        setupMainNavigationTitleView()
        setupDisplayViewControllers()
        setupGalleryCollectionView()
    }
    
    // MARK: - Private Function

    private func setupMainNavigationTitleView() {
        self.navigationController?.navigationBar.addSubview(titleView)
    }

    private func setupDisplayViewControllers() {

        // UICollectionViewCell内に表示するUIViewControllerの設定
        let viewControllers = [
            //FoodCategoryViewController.instantiate(),
            Partial1ViewController.instantiate(),
            Partial2ViewController.instantiate(),
            Partial3ViewController.instantiate(),
            Partial4ViewController.instantiate()
        ]
        let _ = viewControllers.map{ displayViewControllers.append($0) }
    }

    private func setupGalleryCollectionView() {

        // UICollectionViewに関する初期設定
        collectionView.isPagingEnabled = true
        collectionView.isScrollEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false

        // UICollectionViewDelegate & UICollectionViewDataSourceに関する初期設定
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.decelerationRate = .normal
        collectionView.registerCustomCell(ContainerCollectionViewCell.self)

        // UICollectionViewに付与するアニメーションに関する設定
        let layout = AnimatedCollectionViewLayout()
        layout.animator = PageAttributesAnimator()
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
    }
}

// MARK: - UIScrollViewDelegate

extension ArticleViewController: UIScrollViewDelegate {

    // オフセット時の変更を検知した（スクロールが実行されている）場合の処理
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        // 画面内に見えているセルの中央値を基準としてIndexPath.rowを取得してタイトルへ反映する
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint) {
            let info: ArticleNavigationTitleView.ArticleNavigationTitleInformation = (
                title: "サンプルタイトル\(visibleIndexPath.row)",
                cellIndex: visibleIndexPath.row
            )
            titleView.setCurrentDisplayTitleInformation(info)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension ArticleViewController: UICollectionViewDelegate {

    // MEMO: 利用しないかもしれませんが一応準備をしておく

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {}

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {}
}

// MARK: - UICollectionViewDataSource

extension ArticleViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayViewControllers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        // MEMO: Containerとして表示したいViewControllerと親要素のViewControllerを渡す
        let cell = collectionView.dequeueReusableCustomCell(with: ContainerCollectionViewCell.self, indexPath: indexPath)
        let selectedViewController = displayViewControllers[indexPath.row]
        cell.setCell(targetViewController: selectedViewController, parentViewController: self)

        // MEMO: セルへ適用した後に再び詰め直しを図る
        displayViewControllers[indexPath.row] = selectedViewController

        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ArticleViewController: UICollectionViewDelegateFlowLayout {
    
    // セルのサイズを設定する
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        // MEMO: コンテンツを表示するためのセル幅 = 画面の幅
        let cellWidth = UIScreen.main.bounds.width
        
        // MEMO: コンテンツを表示するためのセル高さ = 画面の高さ - ステータスバーの高さ
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let navigationBarHeight = self.navigationController?.navigationBar.frame.height ?? 0
        let cellHeight = UIScreen.main.bounds.height - statusBarHeight - navigationBarHeight

        return CGSize(width: cellWidth, height: cellHeight)
    }

    // セルの垂直方向の余白(margin)を設定する
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }

    // セルの水平方向の余白(margin)を設定する
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }

    // セル内のアイテム間の余白(margin)調整を行う
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
}
