//
//  AppDelegate.swift
//  WhaleTalk
//
//  Created by WONGKAI MING on 24/3/17.
//  Copyright © 2017年 WONGKAI MING. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseDatabase
import FirebaseAuth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    fileprivate var contactImporter: ContactImporter?
    fileprivate var contactsSyncer: Syncer?
    fileprivate var contactsUploadSyncer: Syncer?
    fileprivate var firebaseSyncer: Syncer?
    fileprivate var firebaseStore: FirebaseStore?
    
    lazy var coreDataStack = CoreDataStack(modelName: "WhaleTalk")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //configure firebase
        FIRApp.configure()
        

        
        let mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mainContext.persistentStoreCoordinator = coreDataStack.managedContext.persistentStoreCoordinator
        
//        // Override point for customization after application launch.
//        let context = coreDataStack.managedContext
//        //let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
//        let vc = AllChatsViewController()
//        let nav = UINavigationController(rootViewController: vc)
//        window!.rootViewController = nav
//        vc.context = context
        let contactsContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        contactsContext.persistentStoreCoordinator = coreDataStack.managedContext.persistentStoreCoordinator
        let firebaseContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        firebaseContext.persistentStoreCoordinator = coreDataStack.managedContext.persistentStoreCoordinator
        
        //73
        contactsSyncer = Syncer(mainContext: mainContext, backgroundContext: contactsContext)
        
        let firebaseStore = FirebaseStore(context: firebaseContext)
        self.firebaseStore = firebaseStore
        
        contactsUploadSyncer = Syncer(mainContext: contactsContext, backgroundContext: firebaseContext)
        contactsUploadSyncer?.remoteStore = firebaseStore
        
        firebaseSyncer = Syncer(mainContext: mainContext, backgroundContext: firebaseContext)
        firebaseSyncer?.remoteStore = firebaseStore
        contactImporter = ContactImporter(context: mainContext)
//75        importContacts(context: contactsContext)
        
        //75
        //try! FIRAuth.auth()!.signOut()
        
        // Tab Bar Controller
        let tabController = UITabBarController()
        let vcData:[(UIViewController, UIImage, String)] = [
            (ContactsViewController(), UIImage(named: "contact_icon")!, "Contacts"),
            (AllChatsViewController(), UIImage(named: "chat_icon")!, "Chats"),
            (FavoritesViewController(), UIImage(named: "favorites_icon")!, "Favorites")
            
            
        ]
        let vcs = vcData.map{
            (vc: UIViewController, image: UIImage, title: String)-> UINavigationController in
            if var vc = vc as? ContextViewController {
                vc.context = mainContext
            }
            let nav = UINavigationController(rootViewController: vc)
            nav.tabBarItem.image = image
            nav.title = title
            return nav
        }
        
        tabController.viewControllers = vcs
        if firebaseStore.hasAuth() {
        
            firebaseStore.startSyncing()
        //45
            contactImporter?.listenForChanges()
            window?.rootViewController = tabController
            
        } else {
        //window?.rootViewController = SignUpViewController()
        let vc = SignUpViewController()
            vc.remoteStore = firebaseStore
            vc.rootViewController = tabController
            vc.contactImporter = contactImporter
            window?.rootViewController = vc
        
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        coreDataStack.saveContext()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        coreDataStack.saveContext()
    }
    
    func importContacts(context: NSManagedObjectContext) {
        let dataSeeded = UserDefaults.standard.bool(forKey: "dataSeeded")
        guard !dataSeeded else {return}
        
        contactImporter?.fetch()
        
        UserDefaults.standard.object(forKey: "dataSeeded")
    }
    
}

