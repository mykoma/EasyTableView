//
//  ViewController.swift
//  FormatTableView
//
//  Created by Apple on 2017/6/6.
//  Copyright © 2017年 goluk. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    
    private var textItem: Cell2Item?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
            
        let item1 = Cell1Item.init(identifier: "cell1", with: 30)
        self.tableView.dataSourceArray.append(item1)
        
        let item2 = Cell2Item.init(identifier: "cell2", with: 50)
        self.tableView.dataSourceArray.append(item2)
        
        let item3 = Cell2Item.init(identifier: "cell3", with: UITableViewAutomaticDimension)
        item3.text = "文字文本"
        self.textItem = item3
        self.tableView.dataSourceArray.append(item3)
    }

    @IBAction func appendOne() {
        let item = Cell1Item.init(identifier: "cell1", with: 22)
        self.tableView.append(cellItem: item)
    }
    
    @IBAction func appendTwo() {
        let item = Cell1Item.init(identifier: "cell1", with: 22)
        let item2 = Cell2Item.init(identifier: "cell2", with: 42)
        self.tableView.append(cellItems: [item, item2])
    }
    
    @IBAction func removeOne1() {
        // 测试代码， 注意数据崩溃！！！！！
        self.tableView.remove(indexPath: IndexPath.init(row: 0, section: 0))
    }
    
    @IBAction func removeOne2() {
        // 测试代码， 注意数据崩溃！！！！！
        self.tableView.remove(cellItem: self.tableView.dataSourceArray.last!)
    }
    
    @IBAction func removeTwo1() {
        // 测试代码， 注意数据崩溃！！！！！
        self.tableView.remove(indexPaths: [IndexPath.init(row: 0, section: 0),
                                           IndexPath.init(row: 1, section: 0)])
    }
    
    @IBAction func removeTwo2() {
        // 测试代码， 注意数据崩溃！！！！！
        self.tableView.remove(cellItems: [self.tableView.dataSourceArray[self.tableView.dataSourceArray.count - 2],
                                          self.tableView.dataSourceArray.last!])
    }
    
    @IBAction func insertOne() {
        let item = Cell1Item.init(identifier: "cell1", with: 22)
        self.tableView.insert(cellItem: item, atIndexPath: IndexPath.init(row: 0, section: 0))
    }
    
    @IBAction func insertTwo() {
        let item = Cell1Item.init(identifier: "cell1", with: 22)
        let item2 = Cell2Item.init(identifier: "cell2", with: 42)
        self.tableView.insert(cellItems: [item, item2], atIndexPath: IndexPath.init(row: 0, section: 0))
    }
    
    @IBAction func replaceOne() {
        let item3 = Cell2Item.init(identifier: "cell3", with: UITableViewAutomaticDimension)
        item3.text = "替换长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长文本"
        // 测试代码， 注意数据崩溃！！！！！
        self.tableView.replace(cellItem: item3, atIndexPath: IndexPath.init(row: 0, section: 0))
    }
    
    @IBAction func replaceTwo() {
        let item1 = Cell2Item.init(identifier: "cell3", with: UITableViewAutomaticDimension)
        item1.text = "替换长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长长文本"
        let item2 = Cell2Item.init(identifier: "cell3", with: UITableViewAutomaticDimension)
        item2.text = "替换文本"
        // 测试代码， 注意数据崩溃！！！！！
        self.tableView.replace(new: [item1, item2],
                               old: [self.tableView.dataSourceArray[self.tableView.dataSourceArray.count - 2], self.tableView.dataSourceArray.last!])
    }
    
    @IBAction func changeText() {
        self.textItem?.text = String.init(arc4random() % 100)
    }
    
}
