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
    fileprivate var currentPhoneNumber: String? {
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
}

extension FirebaseStore: RemoteStore {
    func startSyncing() {
    }
    
    func store(inserted: [NSManagedObject], updated: [NSManagedObject], deleted: [NSManagedObject]) {
        return
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
                "phoneNumber": phoneNumber
                ]
                //let uid = user["uid"] as! String
                self.currentPhoneNumber = phoneNumber
                let usersRef = self.rootRef.child("users")
                let uidRef = usersRef.child("uid")
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
