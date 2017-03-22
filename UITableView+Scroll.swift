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
        self.scrollToRow(at: NSIndexPath(row: self.numberOfRows(inSection: 0)-1, section: 0) as IndexPath, at: .bottom, animated: true)
    }
}
