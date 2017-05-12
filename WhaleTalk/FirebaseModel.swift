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
}

