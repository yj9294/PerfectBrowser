//
//  ListCell.swift
//  PerfectBrowser
//
//  Created by yangjian on 2023/4/11.
//

import UIKit

class ListCell: UICollectionViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    var closeHandle: (()->Void)? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func closeAction() {
        closeHandle?()
    }

    var item: BrowserItem? = nil {
        didSet {
            title.text = item?.webView.url?.absoluteString.replacingOccurrences(of: "www.", with: "")
            closeButton.isHidden = BrowserUtil.shared.count == 1
        
            self.borderColor = UIColor(named: "#0053FD")!
            
            if BrowserUtil.shared.item == item {
                self.borderWidth = 2
            } else {
                self.borderWidth = 0
            }
        }
    }
}
