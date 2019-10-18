//
//  DetailViewController.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/09/21.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import UIKit

final class DetailViewController: UIViewController {

    // NavigationBarもどきのヘッダー部分の高さ
    private var fakeNavigationBarHeight: CGFloat = CGFloat.zero

    // サムネイル画像の幅と高さ
    private let originalImageWidth: CGFloat = UIScreen.main.bounds.size.width
    private let originalImageHeight: CGFloat = UIScreen.main.bounds.size.width * 1.2

    // 下方向のスクロールを実施した際に画面を閉じる処理をするためのY軸方向のオフセット値のしきい値
    private let dismissOffsetLimit: CGFloat = -100.0

    // カスタムトランジション時に利用する、スクロール位置を考慮した戻る遷移時の矩形サイズ
    private (set)var dismissImageFrame: CGRect = CGRect.zero
    // カスタムトランジション時に利用する、遷移先の初期状態時の矩形サイズ
    private (set)var presentedImageFrame: CGRect = CGRect.zero

    // スクロールで変化する上方向のサムネイル画像の制約最大値
    private var stickyOffsetLimit: CGFloat = CGFloat.zero

    // --- ↓ Storyboardで配置した部品類でDutlet接続を伴うもの(Start)

    //
    @IBOutlet weak private var detailScrollView: UIScrollView!

    //
    @IBOutlet weak private var detailImageView: UIImageView!
    @IBOutlet weak private var detailImageViewTopConstraint: NSLayoutConstraint!

    //
    @IBOutlet weak private var detailImageMaskView: UIView!
    @IBOutlet weak private var detailImageMaskViewTopConstraint: NSLayoutConstraint!

    //
    @IBOutlet weak private var detailEffectiveHeaderView: DetailEffectiveHeaderView!
    @IBOutlet weak private var detailEffectiveHeaderHeightConstraint: NSLayoutConstraint!

    //
    @IBOutlet weak private var detailTitleLabel: UILabel!
    @IBOutlet weak private var detailDescriptionLabel: UILabel!
    @IBOutlet weak private var detailParagraphView: UIView!
    
    //
    @IBOutlet weak private var detailSubContentsTabViewTopConstraint: NSLayoutConstraint!

    //
    @IBOutlet weak private var detailSubContentsViewHeightConstraint: NSLayoutConstraint!

    // --- ↑ Storyboardで配置した部品類でDutlet接続を伴うもの(End)
    
    
    
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var testConstraint: NSLayoutConstraint!

    
    private var detailSubContentsTabViewInitialPositionY: CGFloat!
    
    // MARK: - Override

    override func viewDidLoad() {
        super.viewDidLoad()

        let sampleTitle = "僕の超絶大嫌いな天声人語です〜。新聞に掲載してあったら切り抜いて保存しないで速攻捨てましょう。"
        let attrForTitle: UILabelDecorator.KeysForDecoration = (lineSpacing: 6.0, font: UIFont(name: "HiraKakuProN-W6", size: 15.0)!, foregroundColor: UIColor.black)
        detailTitleLabel.attributedText = NSAttributedString(string: sampleTitle, attributes: UILabelDecorator.getLabelAttributesBy(keys: attrForTitle))
        
        let sampleDescription = "天声人語（てんせいじんご）は、朝日新聞の朝刊に長期連載中の1面コラムである。1904年1月5日付の『大阪朝日新聞』2面に初めて掲載され（初期は必ずしも1面に掲載されるとは限らなかった）、以後、別の題名となった時期を挟みながら1世紀以上にわたって継続して掲載されている。最近のニュース、話題を題材にして朝日新聞の論説委員が執筆し、社説とは異なる角度から分析を加えている。特定の論説委員が一定期間「天声人語子」として匿名で執筆している。朝日新聞本紙では見出しは付けられていないが、朝日新聞デジタルでは見出しが付けられている。また、書籍化される際には標題が付けられる。"
        let attrForDescription: UILabelDecorator.KeysForDecoration = (lineSpacing: 7.0, font: UIFont(name: "HiraKakuProN-W3", size: 12.0)!, foregroundColor: UIColor.darkGray)
        detailDescriptionLabel.attributedText = NSAttributedString(string: sampleDescription, attributes: UILabelDecorator.getLabelAttributesBy(keys: attrForDescription))
        
        detailParagraphView.layoutIfNeeded()
        detailSubContentsTabViewInitialPositionY = detailParagraphView.frame.height + originalImageHeight

        detailSubContentsTabViewTopConstraint.constant = detailSubContentsTabViewInitialPositionY

        // MEMO: プロパティを反映させる順番に注意しないとクラッシュしてしまう...
        setupFakeNavigationBarHeight()
        setupScrollView()
        setupDetailSubContentsViewHeight()
        setupDetailImageViewAndMask()
        setupDetailEffectiveHeaderView()
        setupPresentedImageFrameForTransition()
        setupStickyOffsetLimit()
    }

    // MARK: - Private Function (for Initial Settings)

    private func setupFakeNavigationBarHeight() {
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
        let navigationBarHeight: CGFloat = 44.0
        fakeNavigationBarHeight = statusBarHeight + navigationBarHeight
    }

    private func setupScrollView() {
        // MEMO: NavigationBar分のスクロール位置がずれてしまうのでその考慮を行う
        if #available(iOS 11.0, *) {
            detailScrollView.contentInsetAdjustmentBehavior = .never
        }
        detailScrollView.delegate = self
    }
    
    private func setupDetailSubContentsViewHeight() {
        // MEMO: NavigationBar相当分を差し引いたUITableViewで展開するコンテンツ表示部分の高さを確保する
        detailSubContentsViewHeightConstraint.constant = UIScreen.main.bounds.height - fakeNavigationBarHeight
    }

    private func setupDetailImageViewAndMask() {
        detailImageViewTopConstraint.constant = 0
        detailImageMaskViewTopConstraint.constant = 0
        detailImageMaskView.alpha = 0
    }

    private func setupDetailEffectiveHeaderView() {
        // MEMO: ダミーのNavigationBarの相当となるエリアの高さを設定する
        // → StatusBarの高さ + NavigationBar相当の高さ = fakeNavigationBarHeight
        detailEffectiveHeaderHeightConstraint.constant = fakeNavigationBarHeight

        // MEMO: ダミーのNavigationBarの相当の初期設定
        detailEffectiveHeaderView.setTitle("Sample of Meal Detail")
        detailEffectiveHeaderView.changeAlpha(0)
        detailEffectiveHeaderView.headerBackButtonTappedHandler = {
            self.dismissScreenDependOnVertialPosition()
        }
    }

    private func setupPresentedImageFrameForTransition() {
        presentedImageFrame = CGRect(
            x: 0,
            y: 0,
            width: originalImageWidth,
            height: originalImageHeight
        )
    }

    private func setupStickyOffsetLimit() {
        // MEMO: スクロールで変化する上方向のサムネイル画像の制約最大値を下記のように算出する
        // → 画像最大値画像の高さ - (StatusBarの高さ + NavigationBar相当の高さ = fakeNavigationBarHeight)
        stickyOffsetLimit = originalImageHeight - fakeNavigationBarHeight
    }

    // MARK: - Private Function (for Adjust Layout)

    // 配置したScrollViewのY軸方向のオフセット値のしきい値を超えた際に画面を閉じる
    private func dismissScreenDependOnVertialPosition() {
        // MEMO: カスタムトランジションに必要なFrame値を更新する
        dismissImageFrame = CGRect(
            x: 0,
            y: -detailScrollView.contentOffset.y,
            width: originalImageWidth,
            height: originalImageHeight
        )
        self.dismiss(animated: true, completion: nil)
    }

    private func changeAlphaDetailImageMaskView(_ targetAlpha: CGFloat) {
        let maxAlpha: CGFloat = 0.64
        if targetAlpha > maxAlpha {
            detailImageMaskView.alpha = maxAlpha
        } else if 0...maxAlpha ~= targetAlpha {
            detailImageMaskView.alpha = targetAlpha
        } else {
            detailImageMaskView.alpha = 0
        }
    }
}

// MARK: - UIScrollViewDelegate

extension DetailViewController: UIScrollViewDelegate {

    // スクロールが検知された時に実行される処理
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y

        // スクロールで変化する上方向のサムネイル画像の制約を更新する
        let targetConstant = -min(stickyOffsetLimit, yOffset)
        detailImageViewTopConstraint.constant = targetConstant
        detailImageMaskViewTopConstraint.constant = targetConstant

        // サムネイル画像に被せているマスク用Viewとダミータイトル表示用Viewのアルファ値を更新する
        let targetAlpha = yOffset / stickyOffsetLimit
        changeAlphaDetailImageMaskView(targetAlpha)
        detailEffectiveHeaderView.changeAlpha(targetAlpha)

        // Y軸方向のオフセット値がしきい値を超えていれば画面を閉じる
        if yOffset <= dismissOffsetLimit {
            dismissScreenDependOnVertialPosition()
        }

        //
        detailSubContentsTabViewTopConstraint.constant = max(detailSubContentsTabViewInitialPositionY - yOffset, fakeNavigationBarHeight)
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
