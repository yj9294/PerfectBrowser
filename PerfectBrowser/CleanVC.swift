//
//  CleanVC.swift
//  PerfectBrowser
//
//  Created by yangjian on 2023/4/11.
//

import UIKit

class CleanVC: UIViewController {
    
    @IBOutlet weak var animationView: UIImageView!
    
    var completionHandle:(()->Void)? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        starAnimation()
        BrowserUtil.shared.clean(from: self)
        Task {
            if !Task.isCancelled {
                try await Task.sleep(nanoseconds: 2_000_000_000)
                self.dismiss(animated: true) {
                    self.completionHandle?()
                }
                stopAnimation()
            }
        }
    }
    
    func starAnimation() {
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        anim.toValue = 2 * Double.pi
        anim.repeatCount = MAXFLOAT
        anim.duration = 1
        anim.isRemovedOnCompletion = false
        animationView.layer.add(anim, forKey: "rot")
    }
    
    func stopAnimation() {
        animationView.layer.removeAllAnimations()
    }
    

}
