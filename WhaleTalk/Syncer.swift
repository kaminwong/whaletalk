//
//  Syncer.swift
//  WhaleTalk
//
//  Created by WONGKAI MING on 5/5/17.
//  Copyright © 2017年 WONGKAI MING. All rights reserved.
//

import UIKit
import CoreData

class Syncer: NSObject {

    private var mainContext: NSManagedObjectContext
    private var backgroundContext: NSManagedObjectContext
    
    var remoteStore: RemoteStore?
    
    init(mainContext: NSManagedObjectContext, backgroundContext: NSManagedObjectContext) {
        self.mainContext = mainContext
        self.backgroundContext = backgroundContext
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.mainContextSaved(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: mainContext)
        NotificationCenter.default.addObserver(self, selector: #selector(self.backgroundContextSaved(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: backgroundContext)
    }
    
    
    func mainContextSaved(notification: NSNotification) {
        backgroundContext.perform {
            
            //73
            let inserted = self.objectsForKey(key: NSInsertedObjectsKey, dictionary: notification.userInfo! as NSDictionary, context: self.backgroundContext)
            let updated = self.objectsForKey(key: NSUpdatedObjectsKey, dictionary: notification.userInfo! as NSDictionary, context: self.backgroundContext)
            let deleted = self.objectsForKey(key: NSDeletedObjectsKey, dictionary: notification.userInfo! as NSDictionary, context: self.backgroundContext)
            
            self.backgroundContext.mergeChanges(fromContextDidSave: notification as Notification)
            self.remoteStore?.store(inserted: inserted, updated: updated, deleted: deleted)
        }
    }
    
    func backgroundContextSaved(notification: NSNotification) {
        mainContext.perform {
            //73
            self.objectsForKey(key: NSUpdatedObjectsKey, dictionary: notification.userInfo! as NSDictionary, context: self.mainContext).forEach{$0.willAccessValue(forKey: nil)}
            self.mainContext.mergeChanges(fromContextDidSave: notification as Notification)
        }
    }
    
    //72
    private func objectsForKey(key: String, dictionary: NSDictionary, context: NSManagedObjectContext) -> [NSManagedObject] {
        guard let set = (dictionary[key] as? NSSet) else {return []}
        guard let objects = set.allObjects as? [NSManagedObject] else {return []}
        return objects.map{context.object(with: $0.objectID)}
    }
}
