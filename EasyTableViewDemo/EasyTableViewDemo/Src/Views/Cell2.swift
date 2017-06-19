//
//  Cell2.swift
//  FormatTableView
//
//  Created by Apple on 2017/6/7.
//  Copyright © 2017年 goluk. All rights reserved.
//

import UIKit

class Cell2Item: UITableViewCellItem {
    
    dynamic var text: String?
    
}

class Cell2: UITableViewCell {
    
    @IBOutlet weak var label: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    override func kvo(cellItem: UITableViewCellItem) {
        guard let item = cellItem as? Cell2Item else {
            return
        }
        
        self.kvoController.unobserveAll()
        self.kvoController.observe(item,
                                   keyPath: "text",
                                   options:  [.new, .initial]) { [weak self](observer:Any?, object: Any, change: [String : Any]) in
                                    guard let strongSelf = self else {
                                        return
                                    }
                                    if let text = change["new"] as? String {
                                        strongSelf.label?.text = text
                                    }
        }
        
    }
    
}
