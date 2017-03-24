//
//  UITableView+Scroll.swift
//  whaletalk
//
//  Created by WONGKAI MING on 23/3/17.
//  Copyright © 2017年 WONGKAI MING. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    func scrolltoBottom() {
        if self.numberOfSections > 1{
            let lastSection = self.numberOfSections - 1
            self.scrollToRow(at: NSIndexPath(row: self.numberOfRows(inSection: lastSection)-1, section: lastSection) as IndexPath, at: .bottom, animated: true)
        }
        else if numberOfRows(inSection: 0) > 0 && self.numberOfSections == 1 {
        self.scrollToRow(at: NSIndexPath(row: self.numberOfRows(inSection: 0)-1, section: 0) as IndexPath, at: .bottom, animated: true)
        }
    }
}
