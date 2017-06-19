//
//  UITableView+Extension.swift
//
//  Copyright © 2017 Gang Liu. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import ObjectiveC

class UITableViewCellItem: NSObject{
    
    var cellHeight: CGFloat
    var identifier: String
    
    init(identifier: String, with cellHeight: CGFloat = 44.0) {
        self.identifier = identifier
        self.cellHeight = cellHeight
    }
    
    func generateCell(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        cell.cellItem = self
        return cell
    }
    
}

var UITableViewCell_CellItem_Key: UInt8 = 0
extension UITableViewCell {
    
    var cellItem: UITableViewCellItem {
        get {
            return objc_getAssociatedObject(self,
                                            &UITableViewCell_CellItem_Key) as! UITableViewCellItem
        }
        set {
            objc_setAssociatedObject(self,
                                     &UITableViewCell_CellItem_Key,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.kvo(cellItem: newValue)
        }
    }
    
    func kvo(cellItem: UITableViewCellItem) {
        
    }
    
}

var UIViewController_tableView_Key: UInt8 = 0
extension UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        get {
            return objc_getAssociatedObject(self,
                                            &UIViewController_tableView_Key) as! UITableView
        }
        set {
            objc_setAssociatedObject(self,
                                     &UIViewController_tableView_Key,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            newValue.dataSourceArray = []
            newValue.estimatedRowHeight = 44.0
        }
    }

}

var UITableView_dataSourceArray_Key: UInt8 = 0
extension UITableView {
    
    var dataSourceArray: [UITableViewCellItem] {
        get {
            return objc_getAssociatedObject(self,
                                            &UITableView_dataSourceArray_Key) as! [UITableViewCellItem]
        }
        set {
            objc_setAssociatedObject(self,
                                     &UITableView_dataSourceArray_Key,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// MARK:- Insert

extension UITableView {

    func insert(cellItem: UITableViewCellItem, atIndexPath indexPath: IndexPath) {
        dataSourceArray.insert(cellItem, at: indexPath.row)
        self.beginUpdates()
        self.insertRows(at: [indexPath], with: .automatic)
        self.endUpdates()
    }
    
    func insert(cellItems: [UITableViewCellItem], atIndexPath indexPath: IndexPath) {
        guard cellItems.count > 0 else {
            return
        }

        var indexPaths: [IndexPath] = []
        var index = indexPath.row
        for cellItem in cellItems {
            dataSourceArray.insert(cellItem, at: index)
            indexPaths.append(IndexPath.init(row: index, section: 0))
            index = index + 1
        }
        
        self.beginUpdates()
        self.insertRows(at: indexPaths as [IndexPath], with: .automatic)
        self.endUpdates()
    }
}

// MARK:- Append

extension UITableView {
    
    func append(cellItem: UITableViewCellItem) {
        let indexPath = IndexPath.init(row: dataSourceArray.count, section: 0)
        dataSourceArray.append(cellItem)
        
        self.beginUpdates()
        self.insertRows(at: [indexPath], with: .automatic)
        self.endUpdates()
    }
    
    func append(cellItems: [UITableViewCellItem]) {
        guard cellItems.count > 0 else {
            return
        }
        
        var indexPaths: [IndexPath] = []
        let dataSourceArrayCount = dataSourceArray.count
        for index in dataSourceArrayCount ... dataSourceArrayCount + cellItems.count - 1 {
            let indexPath = IndexPath.init(row: index, section: 0)
            indexPaths.append(indexPath)
        }
        
        for cellItem in cellItems {
            dataSourceArray.append(cellItem)
        }
        
        self.beginUpdates()
        self.insertRows(at: NSArray.init(array: indexPaths) as! [IndexPath], with: .automatic)
        self.endUpdates()
    }
    
}

// MARK:- Replace

extension UITableView {
    
    func replace(cellItem: UITableViewCellItem, atIndexPath indexPath: IndexPath) {
        let mArray = NSMutableArray.init(array: self.dataSourceArray)
        mArray.replaceObject(at: indexPath.row, with: cellItem)
        self.dataSourceArray = Array.init(mArray) as! [UITableViewCellItem]

        self.beginUpdates()
        self.reloadRows(at: [indexPath], with: .automatic)
        self.endUpdates()
        
    }
    
    func replace(new newCellModels: [UITableViewCellItem],
                 old oldCellModels: [UITableViewCellItem]) {
        var indexPaths: [IndexPath] = []
        let mArray = NSMutableArray.init(array: self.dataSourceArray)
        for index in 0 ... newCellModels.count {
            guard index < oldCellModels.count else {
                break
            }

            guard let indexInDataSource = dataSourceArray.index(of: oldCellModels[index]) else {
                return
            }
            indexPaths.append(IndexPath.init(row:indexInDataSource, section: 0))
            mArray.replaceObject(at: indexInDataSource, with: newCellModels[index])
        }
        self.dataSourceArray = Array.init(mArray) as! [UITableViewCellItem]

        self.beginUpdates()
        self.reloadRows(at: indexPaths, with: .automatic)
        self.endUpdates()
    }
    
}


// MARK:- Remove

extension UITableView {
    
    func remove(cellItem: UITableViewCellItem) {
        if dataSourceArray.contains(cellItem) {
            guard let index = dataSourceArray.index(of: cellItem) else {
                return
            }
            remove(indexPath: IndexPath.init(row:index, section: 0))
        }
    }
    
    func remove(indexPath: IndexPath) {
        guard indexPath.row < dataSourceArray.count else {
            return
        }
        
        dataSourceArray.remove(at: indexPath.row)
        self.beginUpdates()
        self.deleteRows(at: [indexPath], with: .automatic)
        self.endUpdates()
    }
    
    func remove(cellItems: [UITableViewCellItem]) {
        guard cellItems.count > 0 else {
            return
        }
        
        var mIndexPaths: [IndexPath] = []
        for cellItem in cellItems {
            if dataSourceArray.contains(cellItem) {
                guard let index = dataSourceArray.index(of: cellItem) else {
                    return
                }
                mIndexPaths.append(IndexPath.init(row: index, section: 0))
            }
        }
        remove(indexPaths: mIndexPaths)

    }
    
    func remove(indexPaths: [IndexPath]) {
        guard indexPaths.count > 0 else {
            return
        }
        let count = dataSourceArray.count

        var mIndexPaths: [IndexPath] = []
        let indexSet = NSMutableIndexSet.init()
        for indexPath in indexPaths {
            if indexPath.row < count {
                mIndexPaths.append(indexPath)
                indexSet.add(indexPath.row)
            }
        }
        
        let mArray = NSMutableArray.init(array: self.dataSourceArray)
        mArray.removeObjects(at: indexSet as IndexSet)
        self.dataSourceArray = Array.init(mArray) as! [UITableViewCellItem]
        
        self.beginUpdates()
        self.deleteRows(at: mIndexPaths, with: .automatic)
        self.endUpdates()

    }
}

extension UIViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.dataSourceArray[indexPath.row].cellHeight
    }
}

extension UIViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView.dataSourceArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dataSourceArray[indexPath.row].generateCell(tableView, for:indexPath)
    }
}
