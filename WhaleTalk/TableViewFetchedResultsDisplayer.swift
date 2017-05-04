//
//  TableViewFetchedResultsDisplayer.swift
//  WhaleTalk
//
//  Created by WONGKAI MING on 4/5/17.
//  Copyright © 2017年 WONGKAI MING. All rights reserved.
//

import Foundation
import UIKit

protocol TableViewFetchedResultsDisplayer {
    func configureCell(cell:UITableViewCell, for indexPath: IndexPath)
}
