//
//  Message+CoreDataClass.swift
//  WhaleTalk
//
//  Created by WONGKAI MING on 21/4/17.
//  Copyright © 2017年 WONGKAI MING. All rights reserved.
//

import Foundation
import CoreData


public class Message: NSManagedObject {

    var isIncoming: Bool {
        return sender != nil
    }
}
