//
//  Cell2.swift
//  FormatTableView
//
//  Created by Apple on 2017/6/7.
//  Copyright © 2017年 goluk. All rights reserved.
//

import UIKit

class Cell2Item: UITableViewCellModel {
    
    @objc dynamic var text: String?
    
}

class Cell2: UITableViewCell, UITableViewCellKVO {
    
    @IBOutlet weak var label: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func kvo(cellModel: UITableViewCellModel) {
        guard let item = cellModel as? Cell2Item else {
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
