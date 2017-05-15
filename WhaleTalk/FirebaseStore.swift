//
//  FirebaseStore.swift
//  WhaleTalk
//
//  Created by WONGKAI MING on 6/5/17.
//  Copyright © 2017年 WONGKAI MING. All rights reserved.
//
//{
//    "rules": {
//        ".read": "auth != null",
//        ".write": "auth != null"
//    }
//}
import Foundation
import Firebase
import CoreData
import FirebaseDatabase
import FirebaseAuth

class FirebaseStore {
    fileprivate let context: NSManagedObjectContext
    //private var tag: Bool
    fileprivate let rootRef = FIRDatabase.database().reference()
    fileprivate(set) static var currentPhoneNumber: String? {
        set(phoneNumber) {
            UserDefaults.standard.set(phoneNumber, forKey: "phoneNumber")
        }
        get {
            return UserDefaults.standard.object(forKey: "phoneNumber") as? String
        }
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
//        self.tag = false
    }
    
    func hasAuth() -> Bool {
//        FIRAuth.auth()?.addStateDidChangeListener() { auth, user in
//            if user != nil {
//                self.tag = true
//            } else {
//                self.tag = false
//            }
//        }
//        debugPrint(self.tag)
//        return self.tag
        return FIRAuth.auth()?.currentUser != nil
    }
    
    
    fileprivate func upload(model: NSManagedObject) {
        guard let model = model as? FirebaseModel else {return}
        model.upload(rootRef: rootRef, context: context)
    }
    
    fileprivate func listenForNewMessages(chat: Chat){
        chat.observeMessages(rootRef: rootRef, context: context)
        
    }
    
    
    fileprivate func fetchAppContacts()->[Contact]{
        do {
            let request = NSFetchRequest<Contact>(entityName: "Contact")
            request.predicate = NSPredicate(format: "storageid != nil")
            let results = try self.context.fetch(request)
            return results
        } catch {
            print("Error fetching Contacts")
            return[]
        }
    }
    
    fileprivate func observeUserStatus(contact:Contact) {
        contact.observeStatus(rootRef: rootRef, context: context)
    }
    
    fileprivate func observeStatuses() {
        let contacts = fetchAppContacts()
        contacts.forEach(observeUserStatus)
    }
    
    fileprivate func observeChats() {
        let user = FIRAuth.auth()?.currentUser
        if (user != nil){
        //debugPrint(user?.uid)
        self.rootRef.child("users/"+(user?.uid)!+"/chats").observe(.childAdded, with: {
            snapshot in
            let uid = snapshot.key
            let chat = Chat.existing(storageid: uid, inContext: self.context) ?? Chat.new(forStorageId: uid, rootRef: self.rootRef, inContext: self.context)
            if chat.isInserted {
                do {
                    try self.context.save()
                } catch {}
            }
            self.listenForNewMessages(chat: chat)
        })
        } else {return}
    }
}

extension FirebaseStore: RemoteStore {
    func startSyncing() {
        context.perform {
            self.observeStatuses()
            self.observeChats()
        }
    }
    
    func store(inserted: [NSManagedObject], updated: [NSManagedObject], deleted: [NSManagedObject]) {
        inserted.forEach(upload)
        do {
            try context.save()
        } catch {
            print("Error Saving")
        }
    }
    
    func signUp(phoneNumber: String, email: String, password: String, success: () -> (), error: (String) -> ()) {
        FIRAuth.auth()!.createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
            if let err: Error = error {
                print(err.localizedDescription)
                return
            }
            } else {
                let newUser = [
                "phoneNumber": phoneNumber,
                "password": password
                ]
                //let uid = user["uid"] as! String
                FirebaseStore.currentPhoneNumber = phoneNumber
                let usersRef = self.rootRef.child("users")
                let uidRef = usersRef.child((user?.uid)!)
                uidRef.setValue(newUser)
                
                
                FIRAuth.auth()!.signIn(withEmail: email, password: password, completion: { (user, error) in
                    if error != nil {
                        if let err: Error = error {
                            print(err.localizedDescription)
                            return
                        }
                        else  { debugPrint("success") }
                    }
                    
                })
            }
        })
        success()
    }
    
    
//    func signUp(phoneNumber: String, email: String, password: String, success: () -> (), error: (_ errorMessage: String) -> ()) {
//        
//        FIRAuth.auth()!.createUser(withEmail: email, password: password, completion:{
//            error, result in
//            if error != nil {
//                error(errorMessage: error.description)
//            } else {
//            let newUser = [
//                "phoneNumber" : phoneNumber
//            ]
//            self.currentPhoneNumber = phoneNumber
//            let uid = result["uid"] as! String
//            self.rootRef.child("users").child(uid).setValue[newUser]
//            FIRAuth.auth()!.signIn(withEmail: email, password: password, completion:
//                {error, authData in
//                if error != nil {
//                error(errorMessage: error.description)
//                } else {
//                success()
//                }
//            })
//        }
//        })
}
