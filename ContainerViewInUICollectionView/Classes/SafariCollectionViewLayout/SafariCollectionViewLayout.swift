//
//  SafariCollectionViewLayout.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/08/19.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import Foundation
import UIKit



final class SafariCollectionViewLayout: UICollectionViewLayout {

    private var storedLayoutAttributes: [UICollectionViewLayoutAttributes] = []
    private var storedContentSize: CGSize = CGSize.zero

    //
    private var itemGap: CGFloat = 50
    private var height: CGFloat = 0
    private var angleOfRotation: CGFloat = -30

    // MARK: - Override

    //
    override var collectionViewContentSize: CGSize {
        return storedContentSize
    }

    // MARK: - Override

    override func prepare() {
        super.prepare()

        //
        guard let collectionView = collectionView, collectionView.numberOfSections == 0 else {
            return
        }

        //itemGap = CGFloat(roundf(Float(self.collectionView!.frame.size.height*0.1)))
        
        var top: CGFloat = 0.0

        let left: CGFloat = 0.0
        let width = collectionView.frame.size.width
        storedContentSize = CGSize(width: width, height: height)

        let limit = collectionView.numberOfItems(inSection: 0)
        
        for item in 0..<limit {
            let indexPath = IndexPath(item: item, section: 0)
            let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            let frame = CGRect(x: left, y: top, width: width, height: height)
            
            attribute.frame = frame
            attribute.zIndex = item
            
            angleOfRotation = CGFloat(-30.0)
            
            var frameOffset = Float((self.collectionView?.contentOffset.y)! - frame.origin.y) - floorf(Float(self.collectionView!.frame.size.height/10.0))
            
            if frameOffset > 0 {
                frameOffset = frameOffset / 5.0
                frameOffset = min(frameOffset, 30.0)
                angleOfRotation += CGFloat(frameOffset)
            }
            
            let calculatedAngle = CGFloat.pi * angleOfRotation / 180.0
            let rotation = CATransform3DMakeRotation(calculatedAngle, 1.0, 0.0, 0.0)
            
            let depth = CGFloat(250.0)
            let translateDown = CATransform3DMakeTranslation(0.0, 0.0, -depth)
            let translateUp = CATransform3DMakeTranslation(0.0, 0.0, depth)
            var scale = CATransform3DIdentity
            scale.m34 = -1.0/1500.0
            let perspective = CATransform3DConcat(CATransform3DConcat(translateDown, scale), translateUp)
            let transform = CATransform3DConcat(rotation, perspective)
            
            
            let gap = self.itemGap
            attribute.transform3D = transform
            storedLayoutAttributes.append(attribute)
            
            top += gap
            
        }

        if storedLayoutAttributes.count > 0 {
            if let lastItemAttributes = storedLayoutAttributes.last {
                let newHeight = lastItemAttributes.frame.origin.y + lastItemAttributes.frame.size.height + 20.0
                let newWidth = collectionView.frame.size.width
                storedContentSize = CGSize(width: newWidth, height: newHeight)
            }
        }
    }

    //
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in storedLayoutAttributes {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }

    //
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return storedLayoutAttributes[indexPath.item]
    }

    //
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    //
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return storedLayoutAttributes[itemIndexPath.item]
    }
}
