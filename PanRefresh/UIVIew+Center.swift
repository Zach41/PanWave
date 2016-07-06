//
//  UIVIew+Center.swift
//  PanRefresh
//
//  Created by ZachZhang on 16/7/6.
//  Copyright © 2016年 ZachZhang. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func dg_center(usePresentationLayerIfPossible: Bool) -> CGPoint {
        if usePresentationLayerIfPossible, let presentationLayer = self.layer.presentationLayer() as? CALayer {
            return presentationLayer.position
        } else {
            return center
        }
    }
}