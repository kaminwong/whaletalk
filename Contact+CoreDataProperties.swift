//
//  Contact+CoreDataProperties.swift
//  WhaleTalk
//
//  Created by WONGKAI MING on 20/4/17.
//  Copyright © 2017年 WONGKAI MING. All rights reserved.
//

import Foundation
import CoreData


extension Contact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contact> {
        return NSFetchRequest<Contact>(entityName: "Contact")
    }

    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var chats: NSSet?

}

// MARK: Generated accessors for chats
extension Contact {

    @objc(addChatsObject:)
    @NSManaged public func addToChats(_ value: Chat)

    @objc(removeChatsObject:)
    @NSManaged public func removeFromChats(_ value: Chat)

    @objc(addChats:)
    @NSManaged public func addToChats(_ values: NSSet)

    @objc(removeChats:)
    @NSManaged public func removeFromChats(_ values: NSSet)

}
