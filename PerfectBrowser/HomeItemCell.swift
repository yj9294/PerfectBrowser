//
//  HomeItemCell.swift
//  PerfectBrowser
//
//  Created by yangjian on 2023/4/10.
//

import UIKit

class HomeItemCell: UICollectionViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var item: HomeItem = .facebook {
        didSet {
            self.icon.image = item.icon
            self.title.text = item.title
        }
    }
}
