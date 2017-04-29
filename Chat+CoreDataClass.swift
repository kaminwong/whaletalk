//
//  Chat+CoreDataClass.swift
//  WhaleTalk
//
//  Created by WONGKAI MING on 3/4/17.
//  Copyright © 2017年 WONGKAI MING. All rights reserved.
//

import Foundation
import CoreData

//@objc(Chat)
public class Chat: NSManagedObject {
    
    var isGroupChat: Bool {
        return (participants?.count)! > 1
    }
    
    var lastMessage: Message? {
        let request = NSFetchRequest<Message>(entityName: "Message")
        request.predicate  = NSPredicate(format: "chat = %@", self)
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Message.timestamp), ascending: false)]
        request.fetchLimit = 1
        do {
            guard let results = try self.managedObjectContext?.fetch(request) else {return nil}
            //let results = try self.managedContext?.fetch(request)
            return results.first
        }
        catch {
            print("Error for Request")
        }
        return nil
    }
    
    //func add(participant contact: Contact) {
    //let chat = Chat(context: managedcontext)
    //chat.addToParticipants(contact)
    //}
}
