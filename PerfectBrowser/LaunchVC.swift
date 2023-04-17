//
//  LaunchVC.swift
//  PerfectBrowser
//
//  Created by yangjian on 2023/4/10.
//

import UIKit

class LaunchVC: UIViewController {
    
    @IBOutlet weak var progressView: UIProgressView!
    
    lazy var timer: DispatchSourceTimer = {
        let timer = DispatchSource.makeTimerSource()
        return timer
    }()
    
    var launchedHandle: (()->Void)? = nil
    
    var progress: Double = 0.0 {
        didSet {
            progressView.progress = Float(progress)
            if progress > 1.0 {
                progress = 1.0
                launched()
            }
        }
    }
    
    var duration = 16.5

    override func viewDidLoad() {
        super.viewDidLoad()
        
        FirebaseUtil.log(property: .local)
        FirebaseUtil.log(event: .open)
        FirebaseUtil.log(event: .openCold)
    }

}

extension LaunchVC {
    
    func launching() {
        progress = 0
        duration = 16
        let adTime = 2.5
        timer.schedule(deadline: .now(), repeating: 0.01)
        timer.setEventHandler {
            DispatchQueue.main.async {
                debugPrint(self.progress)
                self.progress += (0.01 / self.duration)
                
                if self.progress > (adTime / self.duration), GADUtil.share.isLoaded(.interstitial) {
                    self.duration = 0.1
                }
            }
        }
        timer.resume()
        GADUtil.share.load(.interstitial)
        GADUtil.share.load(.native)
    }
    
    func launched() {
        progress = 0.0
        timer.suspend()
        GADUtil.share.show(.interstitial) { _ in
            if self.progress == 0.0 {
                self.launchedHandle?()
            }
        }
    }
    
}
