//
// TransitionController.swift
// ZoomAnimation
//
// Copyright (c) 2016 Kazuki Yusa
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

class TransitionController: NSObject, UIViewControllerAnimatedTransitioning {

    // pushなら forward == true
    var forward = false
    
    // アニメーションの時間
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        
        return 0.4
    }
    
    // アニメーションの定義
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if self.forward {
            // Push時のアニメーション
            forwardTransition(transitionContext: transitionContext)
        } else {
            // Pop時のアニメーション
            backwardTransition(transitionContext: transitionContext)
        }
    }
    
    // Push時のアニメーション
    private func forwardTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else {
            return
        }
        guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
            return
        }
        
        // 遷移先のviewをaddSubviewする（fromVC.viewは最初からcontainerViewがsubviewとして持っている）
        transitionContext.containerView.addSubview(toVC.view)
        
        // addSubviewでレイアウトが崩れるため再レイアウトする
        toVC.view.layoutIfNeeded()
        
        // アニメーション用のimageViewを新しく作成する
        guard let sourceImageView = (fromVC as? ViewController)?.createImageView() else {
            return
        }
        guard let destinationImageView = (toVC as? DetailViewController)?.createImageView() else {
            return
        }
        
        // 遷移先のimageViewをaddSubviewする
        transitionContext.containerView.addSubview(sourceImageView)
        
        toVC.view.alpha = 0.0
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.05, options: .curveEaseInOut, animations: { () -> Void in
            
            // アニメーション開始
            // 遷移先のimageViewのframeとcontetModeを遷移元のimageViewに代入
            sourceImageView.frame = destinationImageView.frame
            sourceImageView.contentMode = destinationImageView.contentMode

            // cellのimageViewを非表示にする
            (fromVC as? ViewController)?.selectedImageView?.isHidden = true
            
            toVC.view.alpha = 1.0
            
            }) { (finished) -> Void in

                // アニメーション終了
                transitionContext.completeTransition(true)
        }
    }
    
    // Pop時のアニメーション
    private func backwardTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        // Pushと逆のアニメーションを書く

        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else {
            return
        }
        guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
            return
        }
     

        // 最初からcontainerViewがsubviewとして持っているfromVC.viewを削除
        fromVC.view.removeFromSuperview()
        
        // toView -> fromViewの順にaddSubview
        transitionContext.containerView.addSubview(toVC.view)
        transitionContext.containerView.addSubview(fromVC.view)
        
        guard let sourceImageView = (fromVC as? DetailViewController)?.createImageView() else {
            return
        }
        guard let destinationImageView = (toVC as? ViewController)?.createImageView() else {
            return
        }

        transitionContext.containerView.addSubview(sourceImageView)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.05, options: .curveEaseInOut, animations: { () -> Void in

            sourceImageView.frame = destinationImageView.frame
            fromVC.view.alpha = 0.0
            
            }) { (finished) -> Void in
                
                sourceImageView.isHidden = true
                
                (toVC as? ViewController)?.selectedImageView?.isHidden = false

                transitionContext.completeTransition(true)
        }
    }
}
