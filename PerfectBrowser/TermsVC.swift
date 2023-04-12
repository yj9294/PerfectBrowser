//
//  TermsVC.swift
//  PerfectBrowser
//
//  Created by yangjian on 2023/4/11.
//

import UIKit

class TermsVC: UIViewController {

    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    @IBAction func back() {
        self.dismiss(animated: true)
    }
    
}
