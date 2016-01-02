//
//  DimmingPresentationController.swift
//  StoreSearch
//
//  Created by IssacCZ on 1/2/16.
//  Copyright © 2016 Issac. All rights reserved.
//

import Foundation
import UIKit

class DimmingPresentationController: UIPresentationController {
    
    lazy var dimmingView = GradientView(frame: CGRect.zero)
    
    override func presentationTransitionWillBegin() {
        dimmingView.frame = containerView!.bounds
        containerView!.insertSubview(dimmingView, atIndex: 0)
    }
    
    override func shouldRemovePresentersView() -> Bool {
        return false
    }
}