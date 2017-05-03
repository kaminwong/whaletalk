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
    
    func formatPhoneNumber(number: CNPhoneNumber) -> String {
        return number.stringValue
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
    }
    
    func fetch() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts, completionHandler: {
            granted, error in
            
            self.context.perform {
                
            
                if granted {
                do{
                let req = CNContactFetchRequest(keysToFetch: [
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactPhoneNumbersKey as CNKeyDescriptor])
                try
                store.enumerateContacts(with: req, usingBlock: {cnContact, stop in
                //print(cnContact)
                guard let contact = NSEntityDescription.insertNewObject(forEntityName: "Contact", into: self.context) as? Contact else {return}
                
                contact.firstName = cnContact.givenName
                contact.lastName = cnContact.familyName
                contact.contactid = cnContact.identifier
                for cnVal in cnContact.phoneNumbers{
                let cnPhoneNumber = cnVal.value
                guard let phoneNumber = NSEntityDescription.insertNewObject(forEntityName: "PhoneNumber", into: self.context) as? PhoneNumber else {continue}
                phoneNumber.value = self.formatPhoneNumber(number: cnPhoneNumber)
                phoneNumber.contact = contact
                }
                
                
                })
                try self.context.save()
                    
                } catch let error as NSError {
                print(error)
                } catch {
                print("Error with do-catch")
                }
                }
            
            
            }
            
        })
    }
    
}
