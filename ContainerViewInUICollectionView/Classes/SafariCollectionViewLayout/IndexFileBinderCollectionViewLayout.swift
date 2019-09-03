//
//  IndexFileBinderCollectionViewLayout.swift
//  ContainerViewInUICollectionView
//
//  Created by 酒井文也 on 2019/08/25.
//  Copyright © 2019 酒井文也. All rights reserved.
//

import Foundation
import UIKit

class IndexFileBinderCollectionViewLayout: UICollectionViewLayout {
    
    var attributes  = Array<UICollectionViewLayoutAttributes>()
    var contentSize: CGSize = CGSize(width: 0, height: 0)
    @IBInspectable var itemGap: CGFloat = 50
    @IBInspectable var height : CGFloat = 0
    @IBInspectable var angleOfRotation : CGFloat = -30
    
    
    override func prepare() {
        super.prepare()
        
        if collectionView?.numberOfSections != 1 {
            return
        }
        //itemGap = CGFloat(roundf(Float(self.collectionView!.frame.size.height * 0.06)))
        
        var top = CGFloat(0.0)
        let left = CGFloat(0.0)
        let width = collectionView?.frame.size.width
        self.contentSize = CGSize(width: width!, height: height)
        guard let limit = collectionView?.numberOfItems(inSection: 0) else {
            return
        }
        
        for item in 0..<limit {
            let indexPath = IndexPath(item: item, section: 0)
            let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            let frame = CGRect(x: left, y: top, width: width!, height: height)
            
            attribute.frame = frame
            attribute.zIndex = item
            
            angleOfRotation = CGFloat(-45.0)
            
            var frameOffset = Float((self.collectionView?.contentOffset.y)! - frame.origin.y) - floorf(Float(self.collectionView!.frame.size.height/10.0))
            
            if frameOffset > 0 {
                frameOffset = frameOffset/5.0
                frameOffset = min(frameOffset, 45.0)
                angleOfRotation += CGFloat(frameOffset)
            }
            
            let rotation = CATransform3DMakeRotation((CGFloat.pi*angleOfRotation/180.0), 1.0, 0.0, 0.0)
            
            let depth = CGFloat(360.0)
            let translateDown = CATransform3DMakeTranslation(0.0, 0.0, -depth)
            let translateUp = CATransform3DMakeTranslation(0.0, 0.0, depth)
            var scale = CATransform3DIdentity
            scale.m34 = -1.0/900.0
            let perspective =  CATransform3DConcat(CATransform3DConcat(translateDown, scale), translateUp)
            let  transform = CATransform3DConcat(rotation, perspective)
            
            
            let gap = self.itemGap
            attribute.transform3D = transform
            self.attributes.append(attribute)
            
            top += gap
            
        }
        if self.attributes.count > 0 {
            let lastItemAttributes = self.attributes.last
            let newHeight = (lastItemAttributes?.frame.origin.y)! + (lastItemAttributes?.frame.size.height)! + 20
            let newWidth = (self.collectionView?.frame.size.width)!
            
            self.contentSize = CGSize(width: newWidth, height: newHeight)
        }
    }
    
    override var collectionViewContentSize: CGSize {
        return self.contentSize
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        super.layoutAttributesForElements(in: rect)
 
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in self.attributes {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        return self.attributes[indexPath.item]
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.attributes[itemIndexPath.item]
    }
    
}
