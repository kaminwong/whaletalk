//
//  PhoneNumber+CoreDataProperties.swift
//  WhaleTalk
//
//  Created by WONGKAI MING on 3/5/17.
//  Copyright © 2017年 WONGKAI MING. All rights reserved.
//

import Foundation
import CoreData


extension PhoneNumber {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhoneNumber> {
        return NSFetchRequest<PhoneNumber>(entityName: "PhoneNumber");
    }

    @NSManaged public var value: String?
    @NSManaged public var contact: Contact?

}
