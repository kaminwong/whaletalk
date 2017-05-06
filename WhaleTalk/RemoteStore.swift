//
//  RemoteStore.swift
//  WhaleTalk
//
//  Created by WONGKAI MING on 6/5/17.
//  Copyright © 2017年 WONGKAI MING. All rights reserved.
//

import Foundation
import CoreData

protocol RemoteStore {
    func signUp(phoneNumber: String, email: String, password: String, success: ()->(), error:(_ errorMessage:String)->())
    
    func startSyncing()
    
    func store(inserted: [NSManagedObject], updated: [NSManagedObject], deleted: [NSManagedObject])
}

