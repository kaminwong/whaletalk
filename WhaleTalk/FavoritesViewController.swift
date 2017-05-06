//
//  FavoritesViewController.swift
//  WhaleTalk
//
//  Created by WONGKAI MING on 5/5/17.
//  Copyright © 2017年 WONGKAI MING. All rights reserved.
//

import UIKit
import CoreData
import Contacts
import ContactsUI

class FavoritesViewController: UIViewController, TableViewFetchedResultsDisplayer, ContextViewController {

    var context: NSManagedObjectContext?
    
    fileprivate var fetchedResultsController: NSFetchedResultsController<Contact>?
    fileprivate var fetchedResultsDelegate: NSFetchedResultsControllerDelegate?
    
    fileprivate let tableView = UITableView(frame: CGRect.zero, style: .plain)
    fileprivate let cellIdentifier = "FavoriteCell"
    fileprivate let store = CNContactStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Favorites"
        navigationItem.leftBarButtonItem = editButtonItem
        
        automaticallyAdjustsScrollViewInsets = false
        tableView.register(FavoriteCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.dataSource = self
        tableView.delegate = self
        
        fillViewWith(subview: tableView)
        
        if let context = context {
            let request = NSFetchRequest<Contact>(entityName: "Contact")
            request.sortDescriptors = [NSSortDescriptor(key: "lastName", ascending: true),
                                       NSSortDescriptor(key: "firstName", ascending: true)]
            request.predicate = NSPredicate(format: "favorite = true")
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsDelegate = TableViewFetchedResultsDelegate(tableView: tableView, displayer: self)
            fetchedResultsController?.delegate = fetchedResultsDelegate
            
            
            do {
                try fetchedResultsController?.performFetch()
            } catch let error as NSError {
                print("Fetching error: \(error), \(error.userInfo)")
            }
        }
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            tableView.setEditing(true, animated: true)
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete All", style: .plain, target: self, action: #selector(self.deleteAll))
        } else {
            tableView.setEditing(false, animated: true)
            navigationItem.rightBarButtonItem = nil
            guard let context = context, context.hasChanges else {return}
            do {
                try context.save()
            } catch {
            }
        }
    }
    
    func deleteAll() {
        guard let contacts = fetchedResultsController?.fetchedObjects else {return}
        for contact in contacts {
            context?.delete(contact)
        }
    }
    
    func configureCell(cell: UITableViewCell, for indexPath: IndexPath) {
        let contact = fetchedResultsController?.object(at: indexPath)
        guard let cell = cell as? FavoriteCell else {return}
        cell.textLabel?.text = contact?.fullName
        cell.detailTextLabel?.text = contact?.status ?? "***no status***"
        let tmpLabel = contact?.phoneNumbers?.filter({
            number in
            guard let number = number as? PhoneNumber else {return false}
            return number.registered}).first as? PhoneNumber
        cell.phoneTypeLabel.text = tmpLabel?.kind
//        let tmpLabel = contact?.phoneNumbers?.allObjects.first as? PhoneNumber
//        cell.phoneTypeLabel.text = tmpLabel?.kind
        
        cell.accessoryType = .detailButton
    }
    

}

extension FavoritesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections else {return 0}
        let currentSection = sections[section]
        return currentSection.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        configureCell(cell: cell, for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let sections = fetchedResultsController?.sections else {return nil}
        let currentSection = sections[section]
        return currentSection.name
    }
}

extension FavoritesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let contact = fetchedResultsController?.object(at: indexPath) else {return}
        let chatContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        chatContext.parent = context
        
        let chat = Chat.existing(directWith: contact, inContext: chatContext) ?? Chat.new(directWith: contact, inContext: chatContext)
        
        let vc = ChatViewController()
        vc.context = chatContext
        vc.chat = chat
        vc.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let contact = fetchedResultsController?.object(at: indexPath)
        guard let id = contact?.contactid else {return}
        
        let cncontact: CNContact
        do {
            cncontact = try store.unifiedContact(withIdentifier: id, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
        } catch {
            return
        }
        let vc = CNContactViewController(for: cncontact)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard let contact = fetchedResultsController?.object(at: indexPath) else {return}
        contact.favorite = false
        tableView.reloadData()
    }
}
