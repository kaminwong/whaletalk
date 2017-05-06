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
    
    //lec 20, can use addToParticipants in swift 3
    //func add(participant contact: Contact) {
    //mutableSetValue(forKey: "participants").add(contact)
    //let chat = Chat(context: managedcontext)
    //chat.addToParticipants(contact)
    //}
    
    static func existing(directWith contact: Contact, inContext context: NSManagedObjectContext?) -> Chat? {
        
        let request = NSFetchRequest<Chat>(entityName: "Chat")
        request.predicate = NSPredicate(format: "ANY participants = %@ AND participants.@count = 1", contact)
        do {
            guard let results = try context?.fetch(request) else {return nil}
            return results.first
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
        return nil
    }
    
    static func new(directWith contact: Contact, inContext context: NSManagedObjectContext) -> Chat? {
        let chat = NSEntityDescription.insertNewObject(forEntityName: "Chat", into: context) as! Chat
        chat.addToParticipants(contact)
        return chat
    }
    
    
}
