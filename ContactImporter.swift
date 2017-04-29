//
//  ContactImporter.swift
//  WhaleTalk
//
//  Created by KAI MING WONG on 2017/4/29.
//  Copyright © 2017年 WONGKAI MING. All rights reserved.
//

import Foundation
import CoreData
import Contacts

class ContactImporter{

    private var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetch() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts, completionHandler: {
            granted, error in
            
            if granted {
                do{
                    let req = CNContactFetchRequest(keysToFetch: [
                        CNContactGivenNameKey as CNKeyDescriptor,
                        CNContactFamilyNameKey as CNKeyDescriptor,
                        CNContactPhoneNumbersKey as CNKeyDescriptor])
                    try
                        store.enumerateContacts(with: req, usingBlock: {cnContact, stop in
                            guard let contact = NSEntityDescription.insertNewObject(forEntityName: "Contact", into: self.context) as? Contact else {return}
                    
                        contact.firstName = cnContact.givenName
                        contact.lastName = cnContact.familyName
                        contact.contactid = cnContact.identifier
                        print(contact)
                            
                        })
                } catch let error as NSError {
                    print(error)
                } catch {
                    print("Error with do-catch")
                }
            }
        })
    }
    
}
