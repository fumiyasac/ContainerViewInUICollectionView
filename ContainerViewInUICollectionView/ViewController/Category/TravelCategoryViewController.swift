//
//  TravelCategoryViewController.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/08/10.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import UIKit
import Blueprints

final class TravelCategoryViewController: UIViewController {

    static let titleName: String = "旅行・レジャー"

    @IBOutlet weak private var collectionView: UICollectionView!

    // MARK: - Static Function

    static func make() -> ArticleViewController.DisplayViewControllerSet {

        // MEMO: ArticleViewControllerに定義したTypealiasに適合した形にする
        return (
            title: TravelCategoryViewController.titleName,
            viewController: TravelCategoryViewController.instantiate()
        )
    }

    // MARK: - Override

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
    }

    // MARK: - Private Function

    private func setupCollectionView() {
        // UICollectionViewDelegate & UICollectionViewDataSourceに関する初期設定
        collectionView.dataSource = self
        collectionView.registerCustomCell(CategoryPatternCollectionViewCell.self)

        // セルの行間とレイアウトパターンパターン分の高さを設定する
        let cellMargin: CGFloat = 6.0
        let basePatternHeight = UIScreen.main.bounds.width * 1.5

        // ライブラリ「Blueprints」で提供しているレイアウトパターンを適用する
        let mosaicLayout = VerticalMosaicBlueprintLayout(
            patternHeight: basePatternHeight,
            minimumInteritemSpacing: cellMargin,
            minimumLineSpacing: cellMargin,
            sectionInset: EdgeInsets(top: cellMargin, left: cellMargin, bottom: cellMargin, right: cellMargin),
            patterns: [
                // MEMO: 下記4つのパターンで10件分のセルレイアウトになるのでこれを1セットとみなして適用する
                MosaicPattern(alignment: .left, direction: .vertical, amount: 2, multiplier: 0.67),
                MosaicPattern(alignment: .right, direction: .vertical, amount: 2, multiplier: 0.67),
                MosaicPattern(alignment: .left, direction: .vertical, amount: 1, multiplier: 0.5),
                MosaicPattern(alignment: .left, direction: .vertical, amount: 1, multiplier: 0.5)
            ])
        collectionView.collectionViewLayout = mosaicLayout
    }
}

// MARK: - UICollectionViewDataSource

extension TravelCategoryViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCustomCell(with: CategoryPatternCollectionViewCell.self, indexPath: indexPath)
        return cell
    }
}

// MARK: - StoryboardInstantiatable

extension TravelCategoryViewController: StoryboardInstantiatable {

    // このViewControllerに対応するStoryboard名
    static var storyboardName: String {
        return "Category"
    }

    // このViewControllerに対応するViewControllerのIdentifier名
    static var viewControllerIdentifier: String? {
        return TravelCategoryViewController.className
    }
}