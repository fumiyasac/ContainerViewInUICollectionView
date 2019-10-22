//
//  DetailViewController.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/09/21.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import UIKit

final class DetailViewController: UIViewController {

    // MARK: - Property

    // NavigationBarもどきのヘッダー部分の高さ
    private let fakeNavigationBarHeight: CGFloat = {
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
        let navigationBarHeight: CGFloat = 44.0
        return statusBarHeight + navigationBarHeight
    }()

    private let detailSubContentsTabViewHeight: CGFloat = {
        return 44.0
    }()

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

    //
    private var detailSubContentsTabViewInitialPositionY: CGFloat!

    // MARK: - @IBOutlet

    // コンテンツ表示用のUIScrollView
    @IBOutlet weak private var detailScrollView: UIScrollView!

    // サムネイル画像のUIImageViewと制約値
    @IBOutlet weak private var detailImageView: UIImageView!
    @IBOutlet weak private var detailImageViewTopConstraint: NSLayoutConstraint!

    // サムネイル画像の上にかぶせているマスク用のUIViewと制約値
    @IBOutlet weak private var detailImageMaskView: UIView!
    @IBOutlet weak private var detailImageMaskViewTopConstraint: NSLayoutConstraint!

    // ダミーのNavigationBar表示をするDetailEffectiveHeaderViewと制約値
    @IBOutlet weak private var detailEffectiveHeaderView: DetailEffectiveHeaderView!
    @IBOutlet weak private var detailEffectiveHeaderHeightConstraint: NSLayoutConstraint!

    // タイトルと概要を表示しているUIView及び内部要素と制約値
    @IBOutlet weak private var detailTitleLabel: UILabel!
    @IBOutlet weak private var detailDescriptionLabel: UILabel!
    @IBOutlet weak private var detailParagraphView: UIView!
    
    // サブコンテンツを表示しているContainerViewの制約値
    @IBOutlet weak private var detailSubContentsTabViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak private var detailSubContentsViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Override

    override func viewDidLoad() {
        super.viewDidLoad()

        // REMARK: プロパティを反映させる順番を間違えるとクラッシュしうる点に注意する
        setupNotificationCenter()
        setupScrollView()
        setupDetailSubContentsViewHeight()
        setupDetailImageViewAndMask()
        setupDetailEffectiveHeaderView()
        setupPresentedImageFrameForTransition()
        setupStickyOffsetLimit()

        // REMARK: タイトルと概要表示の部分が定型文の場合で成り立つ処理に現状はしている点に注意する
        setDetailParagraphAndLayout()
    }

    // MARK: - deinit

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private Function (for NotificationCenter)

    // MEMO: Notification名「ActivateMainContentsScrollNotification」にて実行される処理
    @objc private func enableDetailScroll() {
        detailScrollView.isScrollEnabled = true
    }

    // MEMO: Notification名「ActivateSubContentsScrollNotification」にて実行される処理
    @objc private func disableDetailScroll() {
        detailScrollView.isScrollEnabled = false
    }

    // MARK: - Private Function (for Initial Settings)

    // 監視対象NotificationCenterの設定
    private func setupNotificationCenter() {

        // Notification名「ActivateMainContentsScrollNotification / ActivateSubContentsScrollNotification」を監視対象に登録する
        NotificationCenter.default.addObserver(self, selector: #selector(self.enableDetailScroll), name: Notification.Name(rawValue: SynchronizeScreenNotification.ActivateMainContentsScrollNotification.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.disableDetailScroll), name: Notification.Name(rawValue: SynchronizeScreenNotification.ActivateSubContentsScrollNotification.rawValue), object: nil)
    }

    private func setupScrollView() {
        // MEMO: NavigationBar分のスクロール位置がずれてしまうのでその考慮を行う
        if #available(iOS 11.0, *) {
            detailScrollView.contentInsetAdjustmentBehavior = .never
        }
        detailScrollView.showsVerticalScrollIndicator = false
        detailScrollView.delegate = self
    }
    
    private func setupDetailSubContentsViewHeight() {
        // MEMO: NavigationBar相当分を差し引いたUITableViewで展開するコンテンツ表示部分の高さを確保する
        detailSubContentsViewHeightConstraint.constant = UIScreen.main.bounds.height - fakeNavigationBarHeight - detailSubContentsTabViewHeight
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

    private func setDetailParagraphAndLayout() {

        // タイトル文言の反映
        let sampleTitle = "こちらはサンプル表示用のUI実装になります。処理としてはかなり強引かつ無理やりな手法である点に注意。"
        let attrForTitle: UILabelDecorator.KeysForDecoration = (lineSpacing: 6.0, font: UIFont(name: "HiraKakuProN-W6", size: 15.0)!, foregroundColor: UIColor.black)
        detailTitleLabel.attributedText = NSAttributedString(string: sampleTitle, attributes: UILabelDecorator.getLabelAttributesBy(keys: attrForTitle))

        // 概要文言の反映
        let sampleDescription = "なんとなく思い立ってTwitterのプロフィールページの様なUIを作ってみようと思ったのですが、なかなかどうしてこれが難しかった。まだこのサンプル実装はAPI処理を伴うことがないのでNotificationCenterを利用した処理を駆使して無理やりにお互いのViewControllerにおける処理を電動させる方式をとっているのだが、実際に利用する際には気をつけなければならない点が出てくる気もしています。特にReactiveなフレームワークを利用しない場合等においてはコードも煩雑化しやすい ＆ AutoLayout制約調整だけではまかないきれない部分がでるという点に注意するとよいのではないかと改めて感じている次第です。"
        let attrForDescription: UILabelDecorator.KeysForDecoration = (lineSpacing: 7.0, font: UIFont(name: "HiraKakuProN-W3", size: 12.0)!, foregroundColor: UIColor(code: "#777777"))
        detailDescriptionLabel.attributedText = NSAttributedString(string: sampleDescription, attributes: UILabelDecorator.getLabelAttributesBy(keys: attrForDescription))

        // MEMO: 文言を反映した状態でのdetailParagraphViewの高さを取得するための処理
        detailParagraphView.layoutIfNeeded()
        detailSubContentsTabViewInitialPositionY = detailParagraphView.frame.height + originalImageHeight

        // MEMO: サブコンテンツを表示しているContainerViewもここで決定させる
        detailSubContentsTabViewTopConstraint.constant = detailSubContentsTabViewInitialPositionY
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

        // スクロールで変化する上方向のサブコンテンツを表示しているContainerViewの制約を更新する
        detailSubContentsTabViewTopConstraint.constant = max(detailSubContentsTabViewInitialPositionY - yOffset, fakeNavigationBarHeight)

        // MEMO: サブコンテンツを画面全体に表示する状態まで到達したら、スクロール可否を切り替える処理を実施する
        if detailSubContentsTabViewInitialPositionY - yOffset < fakeNavigationBarHeight {

            // Notification名「ActivateSubContentsScrollNotification」を監視対象に登録する
            NotificationCenter.default.post(name: Notification.Name(rawValue: SynchronizeScreenNotification.ActivateSubContentsScrollNotification.rawValue), object: self, userInfo: nil)
        }
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
