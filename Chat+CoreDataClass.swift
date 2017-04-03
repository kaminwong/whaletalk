//
//  Chat+CoreDataClass.swift
//  WhaleTalk
//
//  Created by WONGKAI MING on 3/4/17.
//  Copyright © 2017年 WONGKAI MING. All rights reserved.
//

import Foundation
import CoreData

@objc(Chat)
public class Chat: NSManagedObject {

    var managedcontext: NSManagedObjectContext!
    var lastMessage: Message? {
        let request: NSFetchRequest<Message> = Message.fetchRequest()
        request.predicate  = NSPredicate(format: "chat = %@", self)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        request.fetchLimit = 1
        do {
            guard let results = try self.managedcontext.fetch(request) as? [Message] else {return nil}
            return results.first
        }
        catch {
            print("Error for Request")
        }
        return nil
    }
}
