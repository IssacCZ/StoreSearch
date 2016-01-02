//
//  FadeOutAC.swift
//  StoreSearch
//
//  Created by IssacCZ on 1/2/16.
//  Copyright © 2016 Issac. All rights reserved.
//

import Foundation
import UIKit

class FadeOutAC: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.4
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if let fromview = transitionContext.viewForKey(UITransitionContextFromViewKey) {
            let duration = transitionDuration(transitionContext)
            
            UIView .animateWithDuration(duration, animations: { () -> Void in
                fromview.alpha = 0
                }, completion: { (finished) -> Void in
                    transitionContext.completeTransition(finished)
            })
        }
    }
}
