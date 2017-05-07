//
//  FirebaseStore.swift
//  WhaleTalk
//
//  Created by WONGKAI MING on 6/5/17.
//  Copyright © 2017年 WONGKAI MING. All rights reserved.
//
//{
//    "rules": {
//        ".read": "auth != null",
//        ".write": "auth != null"
//    }
//}
import Foundation
import Firebase
import CoreData
import FirebaseDatabase
import FirebaseAuth

class FirebaseStore {
    private let context: NSManagedObjectContext
    private var tag: Bool
    
    let rootRef = FIRDatabase.database().reference()
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.tag = true
    }
    
    func hasAuth() -> Bool {
        FIRAuth.auth()?.addStateDidChangeListener() { auth, user in
            if user != nil {
                self.tag = true
            } else {
                self.tag = false
            }
        }
        debugPrint(self.tag)
        return self.tag
        //return FIRAuth.auth()?.currentUser != nil
    }
}
