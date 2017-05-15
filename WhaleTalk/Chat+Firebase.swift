//
//  Chat+Firebase.swift
//  WhaleTalk
//
//  Created by WONGKAI MING on 15/5/17.
//  Copyright © 2017年 WONGKAI MING. All rights reserved.
//

import Foundation
import CoreData
import FirebaseDatabase
import FirebaseAuth

//80
extension Chat: FirebaseModel {
    
    func observeMessages(rootRef: FIRDatabaseReference, context: NSManagedObjectContext) {
        guard let storageid = storageid else {return}
        let lastFetch = lastMessage?.timestamp?.timeIntervalSince1970 ?? 0
        rootRef.child("chats/"+storageid+"/messages").queryOrderedByKey().queryStarting(atValue: String(lastFetch*100000)).observe(.childAdded, with: {
            snapshot in
            context.perform {
                let snapvalue = snapshot.value as? NSDictionary
                guard let phoneNumber = snapvalue?["sender"] as? String, phoneNumber != FirebaseStore.currentPhoneNumber else {return}
                guard let text = snapvalue?["message"] as? String else {return}
                guard let timeInterval = Double(snapshot.key) else {return}
                let date = NSDate(timeIntervalSince1970: timeInterval/100000)
                
                guard let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as? Message else {return}
                message.text = text
                message.timestamp = date
                message.sender = Contact.existing(withPhoneNumber: phoneNumber, rootRef: rootRef, inContext: context) ?? Contact.new(forPhoneNumber: phoneNumber, rootRef: rootRef, inContext: context)
                message.chat = self
                self.lastMessageTime = message.timestamp
                do {
                    try context.save()
                } catch {}
            }
        })
    }
    
    //83
    static func new(forStorageId storageid: String, rootRef: FIRDatabaseReference, inContext context: NSManagedObjectContext) -> Chat {
        let chat = NSEntityDescription.insertNewObject(forEntityName: "Chat", into: context) as! Chat
        chat.storageid = storageid
        
        rootRef.child("chats/"+storageid+"/meta").observeSingleEvent(of: .value, with: {
            snapshot in
            guard let data = snapshot.value as? NSDictionary else {return}
            guard let participantsDict = data["participants"] as? NSMutableDictionary else {return}
            
            participantsDict.removeObject(forKey: FirebaseStore.currentPhoneNumber!)
            let participants = participantsDict.allKeys.map{ (phoneNumber) -> Contact in
                let phoneNumber = phoneNumber as! String
                return Contact.existing(withPhoneNumber: phoneNumber, rootRef: rootRef, inContext: context) ??
                    Contact.new(forPhoneNumber: phoneNumber, rootRef: rootRef, inContext: context)
                
            }
            let name = data["name"] as? String
            context.perform {
                chat.participants = NSSet(array: participants)
                chat.name = name
                do {
                    try context.save()
                } catch {}
                chat.observeMessages(rootRef: rootRef, context: context)
            }
        })
        return chat
    }
    
    static func existing(storageid: String, inContext context: NSManagedObjectContext?) -> Chat? {
        let request = NSFetchRequest<Chat>(entityName: "Chat")
        request.predicate = NSPredicate(format: "storageid = %@", storageid)
        do {
            if let results = try context?.fetch(request), results.count > 0 {
                if let chat = results.first {
                    return chat
                }
            }
        } catch {print("Error Fetching")}
        return nil
    }
    
    
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
