//
//  FirebaseModel.swift
//  WhaleTalk
//
//  Created by WONGKAI MING on 12/5/17.
//  Copyright © 2017年 WONGKAI MING. All rights reserved.
//

import Foundation
import CoreData
import FirebaseDatabase
import FirebaseAuth

protocol FirebaseModel {
    func upload(rootRef: FIRDatabaseReference, context: NSManagedObjectContext)
}









