//
//  AllChatsViewController.swift
//  WhaleTalk
//
//  Created by WONGKAI MING on 3/4/17.
//  Copyright © 2017年 WONGKAI MING. All rights reserved.
//

import UIKit
import CoreData

class AllChatsViewController: UIViewController {

    
    var context: NSManagedObjectContext?
    
    fileprivate var fetchedResultsController: NSFetchedResultsController<Chat>?
    fileprivate let tableView = UITableView(frame: CGRect.zero, style: .plain)
    fileprivate let cellIdentifier = "MessageCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Chats"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "new_chat"), style: .plain, target: self, action: #selector(self.newChat))
        
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.register(ChatCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        
        let tableViewConstraints: [NSLayoutConstraint] = [
            tableView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor)
        ]
        NSLayoutConstraint.activate(tableViewConstraints)
        
        if let context = context {
            let request = NSFetchRequest<Chat>(entityName: "Chat")
            request.sortDescriptors = [NSSortDescriptor(key: "lastMessageTime", ascending: false)]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController?.delegate = self
            do {
                try fetchedResultsController?.performFetch()
            } catch {
                print("There was a problem fetching.")
            }
            }
        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func newChat() {
    }
    
    func fakeData() {
        guard let context = context else {return}
        let chat  = NSEntityDescription.insertNewObject(forEntityName: "Chat", into: context) as? Chat
    }
    
    func configureCell(cell: UITableViewCell, for indexPath: IndexPath) {
        guard let cell = cell as? ChatCell else {return}
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
        return fetchedResultsController?.sections?.count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections
            else {return 0}
        
        let currentSection = sections[section]
        return currentSection.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

extension AllChatsViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
            case .delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
            default:
                break
            }
    }
}


