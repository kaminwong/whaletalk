//
//  Message+Firebase.swift
//  WhaleTalk
//
//  Created by WONGKAI MING on 15/5/17.
//  Copyright © 2017年 WONGKAI MING. All rights reserved.
//

import Foundation
import CoreData
import FirebaseDatabase
import FirebaseAuth

extension Message: FirebaseModel {
    func upload(rootRef: FIRDatabaseReference, context: NSManagedObjectContext) {
        if chat?.storageid == nil {
            chat?.upload(rootRef: rootRef, context: context)
        }
        let data = [
            "message": text!,
            "sender": FirebaseStore.currentPhoneNumber!
        ]
        guard let chat = chat, let timestamp = timestamp, let storageid = chat.storageid else {return}
        let timeInterval = String(Int(timestamp.timeIntervalSince1970*100000))
        rootRef.child("chats/"+storageid+"/messages/"+timeInterval).setValue(data)
    }
}
