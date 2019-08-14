//
//  NSLayoutManager.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/08/13.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import Foundation
import UIKit

// Apple公式ドキュメント「Using Text Kit to Draw and Manage Text」
// https://apple.co/2N1iQXC

// TextKitにるついてはこちら記事がとても参考になりました！
// https://academy.realm.io/jp/posts/tryswift-katsumi-kishikawa-mastering-textkit-swift-ios/

// テキストの表示範囲の調整に関連する処理を施すために追加した拡張
// MEMO: UITextViewを拡張したReadMoreTextViewで利用 → ポイントはGlyph(グリフ) ＆ BountingRect（バウンティングレクト）の調整

extension NSLayoutManager {

    // MARK: - Function

    // グリフを利用してテキスト文字列の範囲を取得する
    // 参考: https://cocoaapi.hatenablog.com/entry/00000508/recID8709
    func characterRangeThatFits(textContainer: NSTextContainer) -> NSRange {
        var rangeThatFits = self.glyphRange(for: textContainer)
        rangeThatFits = self.characterRange(forGlyphRange: rangeThatFits, actualGlyphRange: nil)
        return rangeThatFits
    }

    // テキスト表示部分の矩形サイズを取得する
    func boundingRectForCharacterRange(range: NSRange, inTextContainer textContainer: NSTextContainer) -> CGRect {
        let glyphRange = self.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
        let boundingRect = self.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        return boundingRect
    }
}
