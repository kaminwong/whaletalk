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
    
    init(mainContext: NSManagedObjectContext, backgroundContext: NSManagedObjectContext) {
        self.mainContext = mainContext
        self.backgroundContext = backgroundContext
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.mainContextSaved(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: mainContext)
        NotificationCenter.default.addObserver(self, selector: #selector(self.backgroundContextSaved(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: backgroundContext)
    }
    
    func mainContextSaved(notification: NSNotification) {
        backgroundContext.perform {
            self.backgroundContext.mergeChanges(fromContextDidSave: notification as Notification)
        }
    }
    
    func backgroundContextSaved(notification: NSNotification) {
        mainContext.perform {
            self.mainContext.mergeChanges(fromContextDidSave: notification as Notification)
        }
    }
    
}
