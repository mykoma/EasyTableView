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

// MARK:- UITableViewCellModel
class UITableViewCellModel: NSObject{
    
    var cellHeight: CGFloat
    var identifier: String
    
    init(identifier: String, with cellHeight: CGFloat = 44.0) {
        self.identifier = identifier
        self.cellHeight = cellHeight
    }
    
    func generateCell(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        cell.cellModel = self
        return cell
    }
    
}

// MARK:- UITableViewCell KVO protocol
protocol UITableViewCellKVO {
    func kvo(cellModel: UITableViewCellModel)
}

// MARK:- UITableViewCell Extension
var UITableViewCell_CellModel_Key: UInt8 = 0
extension UITableViewCell {
    
    var cellModel: UITableViewCellModel {
        get {
            return objc_getAssociatedObject(self,
                                            &UITableViewCell_CellModel_Key) as! UITableViewCellModel
        }
        set {
            objc_setAssociatedObject(self,
                                     &UITableViewCell_CellModel_Key,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            (self as? UITableViewCellKVO)?.kvo(cellModel: newValue)
        }
    }
    
}

// MARK: - UITableView Extension
var UITableView_dataSourceArray_Key: UInt8 = 0
extension UITableView {
    
    // MARK: Properties
    var dataSourceArray: [UITableViewCellModel] {
        get {
            return objc_getAssociatedObject(self,
                                            &UITableView_dataSourceArray_Key) as! [UITableViewCellModel]
        }
        set {
            objc_setAssociatedObject(self,
                                     &UITableView_dataSourceArray_Key,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: Insert
    func insert(cellModel: UITableViewCellModel, atIndexPath indexPath: IndexPath) {
        dataSourceArray.insert(cellModel, at: indexPath.row)
        self.beginUpdates()
        self.insertRows(at: [indexPath], with: .automatic)
        self.endUpdates()
    }
    
    func insert(cellModels: [UITableViewCellModel], atIndexPath indexPath: IndexPath) {
        guard cellModels.count > 0 else {
            return
        }
        
        var indexPaths: [IndexPath] = []
        var index = indexPath.row
        for cellModel in cellModels {
            dataSourceArray.insert(cellModel, at: index)
            indexPaths.append(IndexPath.init(row: index, section: 0))
            index = index + 1
        }
        
        self.beginUpdates()
        self.insertRows(at: indexPaths as [IndexPath], with: .automatic)
        self.endUpdates()
    }
    
    // MARK: Append
    func append(cellModel: UITableViewCellModel) {
        let indexPath = IndexPath.init(row: dataSourceArray.count, section: 0)
        dataSourceArray.append(cellModel)
        
        self.beginUpdates()
        self.insertRows(at: [indexPath], with: .automatic)
        self.endUpdates()
    }
    
    func append(cellModels: [UITableViewCellModel]) {
        guard cellModels.count > 0 else {
            return
        }
        var indexPaths: [IndexPath] = []
        let dataSourceArrayCount = dataSourceArray.count
        for index in dataSourceArrayCount ... dataSourceArrayCount + cellModels.count - 1 {
            let indexPath = IndexPath.init(row: index, section: 0)
            indexPaths.append(indexPath)
        }
        
        for cellModel in cellModels {
            dataSourceArray.append(cellModel)
        }
        
        self.beginUpdates()
        self.insertRows(at: NSArray.init(array: indexPaths) as! [IndexPath], with: .automatic)
        self.endUpdates()
    }
    
    // MARK: Replace
    func replace(cellModel: UITableViewCellModel, atIndexPath indexPath: IndexPath) {
        let mArray = NSMutableArray.init(array: self.dataSourceArray)
        mArray.replaceObject(at: indexPath.row, with: cellModel)
        self.dataSourceArray = Array.init(mArray) as! [UITableViewCellModel]
        
        self.beginUpdates()
        self.reloadRows(at: [indexPath], with: .automatic)
        self.endUpdates()
    }
    
    func replace(new newCellModels: [UITableViewCellModel],
                 old oldCellModels: [UITableViewCellModel]) {
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
        self.dataSourceArray = Array.init(mArray) as! [UITableViewCellModel]
        
        self.beginUpdates()
        self.reloadRows(at: indexPaths, with: .automatic)
        self.endUpdates()
    }
    
    // MARK: Cell Remove
    func remove(cellModel: UITableViewCellModel) {
        if dataSourceArray.contains(cellModel) {
            guard let index = dataSourceArray.index(of: cellModel) else {
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
    
    func remove(cellModels: [UITableViewCellModel]) {
        guard cellModels.count > 0 else {
            return
        }
        var mIndexPaths: [IndexPath] = []
        for cellModel in cellModels {
            if dataSourceArray.contains(cellModel) {
                guard let index = dataSourceArray.index(of: cellModel) else {
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
        self.dataSourceArray = Array.init(mArray) as! [UITableViewCellModel]
        
        self.beginUpdates()
        self.deleteRows(at: mIndexPaths, with: .automatic)
        self.endUpdates()
    }
    
}

// MARK:- UIViewController Extension
var UIViewController_tableView_Key: UInt8 = 0
extension UIViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Properties
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
    
    // MARK: UITableViewDelegate
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.dataSourceArray[indexPath.row].cellHeight
    }
    // MARK: UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView.dataSourceArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dataSourceArray[indexPath.row].generateCell(tableView, for:indexPath)
    }
    
}

