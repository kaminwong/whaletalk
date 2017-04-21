//
//  Message+CoreDataProperties.swift
//  WhaleTalk
//
//  Created by WONGKAI MING on 21/4/17.
//  Copyright © 2017年 WONGKAI MING. All rights reserved.
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }

    @NSManaged public var text: String?
    @NSManaged public var timestamp: NSDate?
    @NSManaged public var chat: Chat?
    @NSManaged public var sender: Contact?

}
