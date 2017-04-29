//
//  Chat+CoreDataProperties.swift
//  WhaleTalk
//
//  Created by KAI MING WONG on 2017/4/28.
//  Copyright © 2017年 WONGKAI MING. All rights reserved.
//

import Foundation
import CoreData


extension Chat {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Chat> {
        return NSFetchRequest<Chat>(entityName: "Chat")
    }

    @NSManaged public var lastMessageTime: NSDate?
    @NSManaged public var name: String?
    @NSManaged public var messages: NSSet?
    @NSManaged public var participants: NSSet?

}

// MARK: Generated accessors for messages
extension Chat {

    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: Message)

    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: Message)

    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)

    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)

}

// MARK: Generated accessors for participants
extension Chat {

    @objc(addParticipantsObject:)
    @NSManaged public func addToParticipants(_ value: Contact)

    @objc(removeParticipantsObject:)
    @NSManaged public func removeFromParticipants(_ value: Contact)

    @objc(addParticipants:)
    @NSManaged public func addToParticipants(_ values: NSSet)

    @objc(removeParticipants:)
    @NSManaged public func removeFromParticipants(_ values: NSSet)

}
