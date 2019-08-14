//
//  UITextViewExtension.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/08/13.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import Foundation
import UIKit

// テキストの表示範囲の調整に関連する処理を施すために追加した拡張
// MEMO: UITextViewを拡張したReadMoreTextViewで利用 → ポイントはGlyph(グリフ) ＆ HitTest（タッチイベント動作）の調整

extension UITextView {

    // UITextView(ここではReadMoreTextView)のテキスト部分にヒットテストが当たっているかを判断する
    public func hitTest(pointInGliphRange aPoint: CGPoint, event: UIEvent?, test: (Int) -> UIView?) -> UIView? {
        guard let charIndex = charIndexForPointInGlyphRect(point: aPoint) else {
            return super.hitTest(aPoint, with: event)
        }
        guard textStorage.attribute(NSAttributedString.Key.link, at: charIndex, effectiveRange: nil) == nil else {
            return super.hitTest(aPoint, with: event)
        }
        return test(charIndex)
    }

    // テキストのBounting Rect（バウンティングレクト）がテキストの範囲内に収まっているかを判定する
    public func pointIsInTextRange(point aPoint: CGPoint, range: NSRange, padding: UIEdgeInsets) -> Bool {
        var boundingRect = layoutManager.boundingRectForCharacterRange(range: range, inTextContainer: textContainer)
        boundingRect = boundingRect.offsetBy(dx: textContainerInset.left, dy: textContainerInset.top)
        boundingRect = boundingRect.insetBy(dx: -(padding.left + padding.right), dy: -(padding.top + padding.bottom))
        return boundingRect.contains(aPoint)
    }

    // タッチイベントの範囲がUIextViewのグリフの範囲であるかを判定する（nilの場合は範囲外とする）
    public func charIndexForPointInGlyphRect(point aPoint: CGPoint) -> Int? {
        let point = CGPoint(x: aPoint.x, y: aPoint.y - textContainerInset.top)
        let glyphIndex = layoutManager.glyphIndex(for: point, in: textContainer)
        let glyphRect = layoutManager.boundingRect(forGlyphRange: NSMakeRange(glyphIndex, 1), in: textContainer)
        if glyphRect.contains(point) {
            return layoutManager.characterIndexForGlyph(at: glyphIndex)
        } else {
            return nil
        }
    }
}
