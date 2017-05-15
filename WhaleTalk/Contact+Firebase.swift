//
//  Contact+Firebase.swift
//  WhaleTalk
//
//  Created by WONGKAI MING on 15/5/17.
//  Copyright © 2017年 WONGKAI MING. All rights reserved.
//

import Foundation
import CoreData
import FirebaseDatabase
import FirebaseAuth

extension Contact: FirebaseModel {
    
    static func new(forPhoneNumber phoneNumberVal: String, rootRef: FIRDatabaseReference, inContext context: NSManagedObjectContext) -> Contact {
        let contact = NSEntityDescription.insertNewObject(forEntityName: "Contact", into: context) as! Contact
        let phoneNumber = NSEntityDescription.insertNewObject(forEntityName: "PhoneNumber", into: context) as! PhoneNumber
        phoneNumber.contact = contact
        phoneNumber.registered = true
        phoneNumber.value = phoneNumberVal
        contact.getContactId(context: context, phoneNumber: phoneNumberVal, rootRef: rootRef)
        return contact
    }
    
    static func existing(withPhoneNumber phoneNumber: String,
                         rootRef: FIRDatabaseReference, inContext context: NSManagedObjectContext?)-> Contact?
    {
        let request = NSFetchRequest<PhoneNumber>(entityName: "PhoneNumber")
        request.predicate = NSPredicate(format: "value=%@", phoneNumber)
        do {
            if let results = try context?.fetch(request), results.count > 0
            {
                let contact = results.first!.contact!
                if contact.storageid == nil {
                    contact.getContactId(context: context!, phoneNumber: phoneNumber, rootRef: rootRef)
                }
                return contact
            }
        } catch {print("Error fetching")}
        return nil
    }
    
    func getContactId(context: NSManagedObjectContext, phoneNumber: String, rootRef: FIRDatabaseReference)
    {
        rootRef.child("users").queryOrdered(byChild: "phoneNumbers").queryEqual(toValue: phoneNumber)
            .observeSingleEvent(of: .value, with: { snapshot in
                guard let user = snapshot.value as? NSDictionary else {return}
                let uid = user.allKeys.first as? String
                context.perform {
                    self.storageid = uid
                    do {
                        try context.save()
                    } catch {
                        print("Error saving")
                    }
                }
            })
    }
    
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
                        self.observeStatus(rootRef: rootRef, context: context)
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
