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
        return NSFetchRequest<Contact>(entityName: "Contact");
    }

    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?

}
