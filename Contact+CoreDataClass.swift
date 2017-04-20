//
//  Contact+CoreDataClass.swift
//  WhaleTalk
//
//  Created by WONGKAI MING on 19/4/17.
//  Copyright © 2017年 WONGKAI MING. All rights reserved.
//

import Foundation
import CoreData

//@objc(Contact)
public class Contact: NSManagedObject {
    
    var sortLetter: String {
        let letter = lastName?.characters.first ?? firstName?.characters.first
        let s = String(letter!)
        return s
    }
    
    var fullName: String {
        var fullName = ""
        if let firstName = firstName {
            fullName += firstName
        }
        if let lastName = lastName {
            if fullName.characters.count > 0 {
                fullName += " "
            }
            fullName += lastName
        }
        return fullName
    }
    
}
