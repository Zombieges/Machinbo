//
//  PushAnimator.swift
//  Machinbo
//
//  Created by ExtYabecchi on 2015/09/01.
//  Copyright (c) 2015年 Zombieges. All rights reserved.
//

import UIKit

class PushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let kMovedDistance: CGFloat = 70.0 // 遷移元のviewのずれる分の距離
    let kDuration = 0.3
    var presenting = false // 遷移するときtrue（戻るときfalse）
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return kDuration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        
        // 遷移するときと戻るときとで処理を変える
        if presenting {
            presentTransition(transitionContext, toView: toVC!.view, fromView: fromVC!.view)
        } else {
            dismissTransition(transitionContext, toView: toVC!.view, fromView: fromVC!.view)
        }
    }
    
    // 遷移するときのアニメーション
    func presentTransition(transitionContext: UIViewControllerContextTransitioning, toView: UIView, fromView: UIView) {
        let containerView = transitionContext.containerView()
        containerView!.insertSubview(toView, aboveSubview: fromView) // toViewの下にfromView
        
        // 遷移先のviewを画面の右側に移動させておく。
        toView.frame = CGRectOffset(toView.frame, containerView!.frame.size.width, 0)
        
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0.05, options: .CurveEaseInOut, animations: { () -> Void in
            // 遷移元のviewを少し左へずらし、alpha値を下げて少し暗くする。
            fromView.frame = CGRectOffset(fromView.frame, -self.kMovedDistance, 0)
            fromView.alpha = 0.7
            
            // 遷移先のviewを画面全体にはまるように移動させる。
            toView.frame = containerView!.frame
            }) { (finished) -> Void in
                fromView.frame = CGRectOffset(fromView.frame, self.kMovedDistance, 0) // 元の位置に戻す
                transitionContext.completeTransition(true)
        }
    }
    
    // 戻るときのアニメーション
    func dismissTransition(transitionContext: UIViewControllerContextTransitioning, toView: UIView, fromView: UIView) {
        let containerView = transitionContext.containerView()
        containerView!.insertSubview(toView, belowSubview: fromView) // fromViewの下にtoView
        
        // 上と逆のことをする。
        toView.frame = CGRectOffset(toView.frame, -kMovedDistance, 0)
        
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
            fromView.frame = CGRectOffset(fromView.frame, containerView!.frame.size.width, 0)
            toView.frame = CGRectOffset(toView.frame, self.kMovedDistance, 0)
            toView.alpha = 1.0
            }) { (finished) -> Void in
                transitionContext.completeTransition(true)
        }
    }
}