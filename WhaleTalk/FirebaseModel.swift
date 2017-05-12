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

extension Contact: FirebaseModel {
    
    func upload(rootRef: FIRDatabaseReference, context: NSManagedObjectContext)
    {
        guard let phoneNumbers = phoneNumbers?.allObjects as? [PhoneNumber] else {return}
        for number in phoneNumbers
        {
            rootRef.child("users").queryOrdered(byChild: "phoneNumber").queryEqual(toValue: number.value)
            .observeSingleEvent(of: .value, with: { snapshot in
            guard let user = snapshot.value as? NSDictionary else {return}
            let uid = user.allKeys.first as? String
                context.perform {
                    self.storageid = uid
                    number.registered = true
                    do {
                        try context.save()
                    } catch {
                        print("Error saving")
                    }
                }
            })
        }
    }
    
    func observeStatus(rootRef: FIRDatabaseReference, context: NSManagedObjectContext) {
        rootRef.child("users/"+storageid!+"/status").observe(.value, with: { snapshot in
            guard let status = snapshot.value as? String else {return}
            context.perform {
                self.status = status
                do {
                    try context.save()
                } catch {
                    print("Error saving")
                }
            }
        })
    }
}

//80
extension Chat: FirebaseModel {
    func upload(rootRef: FIRDatabaseReference, context: NSManagedObjectContext) {
        guard storageid == nil else {return}
        let ref = rootRef.child("chats").childByAutoId()
        storageid = ref.key
        var data: [String: AnyObject] = ["id": ref.key as AnyObject]
        guard let participants = participants?.allObjects as? [Contact] else {return}
        var numbers = [FirebaseStore.currentPhoneNumber!: true]
        var userids = [FIRAuth.auth()?.currentUser?.uid]
        
        for participant in participants {
            guard let phoneNumbers = participant.phoneNumbers?.allObjects as? [PhoneNumber] else {continue}
            guard let number = phoneNumbers.filter({$0.registered}).first else {continue}
            numbers[number.value!] = true
            userids.append(participant.storageid!)
        }
        data["participants"] = numbers as AnyObject?
        if let name = name {
            data["name"] = name as AnyObject?
        }
        ref.setValue(["meta": data])
        for id in userids {
            rootRef.child("users/"+id!+"/chats/"+ref.key).setValue(true)
        }
    }
}

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
        rootRef.child(byAppendingPath: "chats/"+storageid+"/messages/"+timeInterval).setValue(data)
    }
}

