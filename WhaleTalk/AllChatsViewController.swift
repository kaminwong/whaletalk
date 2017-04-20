//
//  AllChatsViewController.swift
//  WhaleTalk
//
//  Created by WONGKAI MING on 3/4/17.
//  Copyright © 2017年 WONGKAI MING. All rights reserved.
//

import UIKit
import CoreData

class AllChatsViewController: UIViewController, TableViewFetchedResultsDisplayer {
    
    
    var context: NSManagedObjectContext!
    var coreDataStack: CoreDataStack!
    
    fileprivate var fetchedResultsController: NSFetchedResultsController<Chat>!
    fileprivate let tableView = UITableView(frame: CGRect.zero, style: .plain)
    fileprivate let cellIdentifier = "MessageCell"
    fileprivate var fetchedResultsDelegate: NSFetchedResultsControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Chats"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "new_chat"), style: .plain, target: self, action: #selector(self.newChat))
        
        //For the Navigation Bar
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.register(ChatCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.dataSource = self
        tableView.delegate = self
        
        fillViewWith(subview: tableView)
        
        if let context = context {
            let request = NSFetchRequest<Chat>(entityName: "Chat")
            request.sortDescriptors  = [NSSortDescriptor(key: "lastMessageTime", ascending: false)]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            
            //monitor changes
            fetchedResultsDelegate = TableViewFetchedResultsDelegate(tableView: tableView, displayer: self)
            fetchedResultsController.delegate = fetchedResultsDelegate
            
            do {
                try fetchedResultsController?.performFetch()
            } catch let error as NSError {
                print("Fetching error: \(error), \(error.userInfo)")
            }
        }
        
        fakeData(context: context)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func newChat() {
        
        let vc = NewChatViewController()
        vc.context = context
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true, completion: nil)
        
    }
    
    func fakeData(context: NSManagedObjectContext) {
        //guard let context = context else {
        //    debugPrint("did not enter context")
        //    return
        //}
        let chat = NSEntityDescription.insertNewObject(forEntityName: "Chat", into: context) as! Chat
        
    }
    
    func configureCell(cell: UITableViewCell, for indexPath: IndexPath) {
        let cell = cell as! ChatCell
        let chat = fetchedResultsController?.object(at: indexPath)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/YY"
        cell.nameLabel.text = "Eliot"
        cell.dateLabel.text = formatter.string(from: Date())
        cell.messageLabel.text = "Hey!"
    }
}

extension AllChatsViewController: UITableViewDataSource {
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
        print("dequeue reached")
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        configureCell(cell: cell, for: indexPath)
        return cell
    }
}

extension AllChatsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chat = fetchedResultsController?.object(at: indexPath)
    }
}




