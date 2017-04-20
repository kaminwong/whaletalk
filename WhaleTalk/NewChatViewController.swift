//
//  NewChatViewController.swift
//  WhaleTalk
//
//  Created by WONGKAI MING on 20/4/17.
//  Copyright © 2017年 WONGKAI MING. All rights reserved.
//

import UIKit
import CoreData

class NewChatViewController: UIViewController, TableViewFetchedResultsDisplayer {
    
    var context: NSManagedObjectContext?
    fileprivate var fetchedResultsController: NSFetchedResultsController<Contact>!
    fileprivate let tableView = UITableView(frame: CGRect.zero, style: .plain)
    fileprivate let cellIdentifier = "ContactCell"
    fileprivate var fetchedResultsDelegate: NSFetchedResultsControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        title  = "New Chat"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancel))
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        
        fillViewWith(subview: tableView)
        
        if let context = context {
            let request = NSFetchRequest<Contact>(entityName: "Contact")
            request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Contact.lastName), ascending: true),
                                       NSSortDescriptor(key: #keyPath(Contact.firstName), ascending: true)]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: #keyPath(Contact.sortLetter), cacheName: "NewChatViewController")
            
            fetchedResultsDelegate = TableViewFetchedResultsDelegate(tableView: tableView, displayer: self)
            fetchedResultsController.delegate = fetchedResultsDelegate
            
            do {
                try fetchedResultsController?.performFetch()
            } catch let error as NSError {
                print("Fetching error: \(error), \(error.userInfo)")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func configureCell(cell: UITableViewCell, for indexPath: IndexPath) {
        let contact = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = contact.fullName
        
    }
}

extension NewChatViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        configureCell(cell: cell, for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections?[section]
        return sectionInfo?.name
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension NewChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = fetchedResultsController.object(at: indexPath)
        
    }
}

