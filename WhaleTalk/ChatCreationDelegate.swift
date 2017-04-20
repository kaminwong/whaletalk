//
//  ChatCreationDelegate.swift
//  WhaleTalk
//
//  Created by WONGKAI MING on 20/4/17.
//  Copyright © 2017年 WONGKAI MING. All rights reserved.
//

import Foundation
import CoreData

protocol ChatCreationDelegate {
    func created(chat: Chat, context: NSManagedObjectContext)
}
