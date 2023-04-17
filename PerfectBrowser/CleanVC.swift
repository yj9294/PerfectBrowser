//
//  CleanVC.swift
//  PerfectBrowser
//
//  Created by yangjian on 2023/4/11.
//

import UIKit

class CleanVC: UIViewController {
    
    lazy var timer: DispatchSourceTimer = {
        let timer = DispatchSource.makeTimerSource()
        return timer
    }()
    
    @IBOutlet weak var animationView: UIImageView!
    
    var completionHandle:(()->Void)? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        starAnimation()
        BrowserUtil.shared.clean(from: self)
        launching()
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
    
    func launching() {
        var progress = 0.0
        var duration = 16.0
        let adTime = 2.5
        timer.schedule(deadline: .now(), repeating: 0.01)
        timer.setEventHandler {
            DispatchQueue.main.async {
                debugPrint(progress)
                progress += 0.01 / duration
                
                if progress > (adTime / duration), GADUtil.share.isLoaded(.interstitial) {
                    duration = 0.1
                }
                if progress > 1.0 {
                    self.timer.cancel()
                    GADUtil.share.show(.interstitial, from: self) { _ in
                        Task {
                            if !Task.isCancelled {
                                try await Task.sleep(nanoseconds: 500_000_000)
                                self.dismiss(animated: true) {
                                    self.completionHandle?()
                                }
                                self.stopAnimation()
                            }
                        }
                        
                    }
                }
            }
        }
        timer.resume()
        GADUtil.share.load(.interstitial)
        GADUtil.share.load(.native)
    }
    

}
