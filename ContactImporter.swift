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

class ContactImporter: NSObject {

    fileprivate var context: NSManagedObjectContext!
    fileprivate var lastCNNotificationTime: Date?
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func listenForChanges() {
        
        CNContactStore.authorizationStatus(for: .contacts)
        NotificationCenter.default.addObserver(self, selector: #selector(self.addressBookDidChange), name: NSNotification.Name.CNContactStoreDidChange, object: nil)
    }
    
    func addressBookDidChange(notification: NSNotification) {
        print(notification)
        let now = Date()
        guard lastCNNotificationTime == nil || now.timeIntervalSince(lastCNNotificationTime!) > 1 else {return}
        lastCNNotificationTime = now
    }

    func formatPhoneNumber(number: CNPhoneNumber) -> String {
        return number.stringValue
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
    }
    
    fileprivate func fetchExisting() -> (contacts: [String: Contact], phoneNumbers: [String: PhoneNumber]) {
        var contacts = [String: Contact]()
        var phoneNumbers = [String: PhoneNumber]()
        do {
            let request = NSFetchRequest<Contact>(entityName: "Contact")
            request.relationshipKeyPathsForPrefetching = ["phoneNumbers"]
            if let contactsResult = try self.context?.fetch(request) {
                for contact in contactsResult {
                    contacts[contact.contactid!] = contact
                    for phoneNumber in contact.phoneNumbers!
                    {
                        phoneNumbers[(phoneNumber as AnyObject).value] = phoneNumber as? PhoneNumber
                    }
                }
            }
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
        return(contacts, phoneNumbers)
    }
    
    
    func fetch() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts, completionHandler: {
            granted, error in
            
            self.context.perform {
                
            
                if granted {
                do{
                    
                let (contacts, phoneNumbers) = self.fetchExisting()
                    
                let req = CNContactFetchRequest(keysToFetch: [
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactPhoneNumbersKey as CNKeyDescriptor])
                try
                store.enumerateContacts(with: req, usingBlock: {cnContact, stop in
                //print(cnContact)
                guard let contact = contacts[cnContact.identifier] ?? NSEntityDescription.insertNewObject(forEntityName: "Contact", into: self.context) as? Contact else {return}
                
                contact.firstName = cnContact.givenName
                contact.lastName = cnContact.familyName
                contact.contactid = cnContact.identifier
                for cnVal in cnContact.phoneNumbers{
                let cnPhoneNumber = cnVal.value
                guard let phoneNumber = phoneNumbers[cnPhoneNumber.stringValue] ?? NSEntityDescription.insertNewObject(forEntityName: "PhoneNumber", into: self.context) as? PhoneNumber else {continue}
                phoneNumber.kind = CNLabeledValue<NSString>.localizedString(forLabel: cnVal.label ?? "")
                phoneNumber.value = self.formatPhoneNumber(number: cnPhoneNumber)
                phoneNumber.contact = contact
                }
                
                    if contact.isInserted{
                        contact.favorite = true
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
