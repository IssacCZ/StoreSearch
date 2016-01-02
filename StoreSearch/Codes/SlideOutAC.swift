//
//  SlideOutAC.swift
//  StoreSearch
//
//  Created by IssacCZ on 1/2/16.
//  Copyright © 2016 Issac. All rights reserved.
//

import Foundation
import UIKit

class SlideOutAC: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey), let containerView = transitionContext.containerView() {
            let duration = transitionDuration(transitionContext)
            
            UIView.animateWithDuration(duration, animations: { () -> Void in
                fromView.center.y += containerView.bounds.size.height
                fromView.transform = CGAffineTransformMakeScale(0.5, 0.5)
                }, completion: { (finished) -> Void in
                    transitionContext.completeTransition(finished)
            })
        }
    }
}
