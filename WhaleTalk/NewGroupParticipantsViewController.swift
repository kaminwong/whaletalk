//
//  NewGroupParticipantsViewController.swift
//  WhaleTalk
//
//  Created by KAI MING WONG on 2017/4/28.
//  Copyright © 2017年 WONGKAI MING. All rights reserved.
//

import UIKit
import CoreData

class NewGroupParticipantsViewController: UIViewController {
    
    var context: NSManagedObjectContext?
    var chat: Chat?
    var chatCreationDelegate: ChatCreationDelegate?
    
    fileprivate var searchField: UITextField!
    fileprivate let tableView = UITableView(frame: CGRect.zero, style: .plain)
    fileprivate let cellIdentifier = "ContactCell"
    fileprivate var displayedContacts = [Contact]()
    fileprivate var allContacts = [Contact]()
    fileprivate var selectedContacts = [Contact]()
    fileprivate var isSearching = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add Participants"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(self.createChat))
        showCreateButton(show: false)
        
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        searchField = createSearchField()
        searchField.delegate = self
        tableView.tableHeaderView = searchField
        
        fillViewWith(subview: tableView)
        
        let request = NSFetchRequest<Contact>(entityName: "Contact")
        request.predicate = NSPredicate(format: "storageid != nil")
        request.sortDescriptors  = [NSSortDescriptor(key: "firstName", ascending: true)]
        
        do {
            if let result = try context?.fetch(request)
            { allContacts = result } else { return }
        }
        catch let error as NSError{
            print("Fetching error: \(error), \(error.userInfo)")
        }
    }

        // Do any additional setup after loading the view.

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func createSearchField()->UITextField {
        let searchField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
        searchField.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        searchField.placeholder = "Type contact name"
        let holderView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        searchField.leftView = holderView
        searchField.leftViewMode = .always
        
        let image = UIImage(named: "contact_icon")?.withRenderingMode(.alwaysTemplate)
        let contactImage = UIImageView(image: image)
        contactImage.tintColor = UIColor.darkGray
        holderView.addSubview(contactImage)
        contactImage.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints: [NSLayoutConstraint] = [
            contactImage.widthAnchor.constraint(equalTo: holderView.widthAnchor, constant: -20),
            contactImage.heightAnchor.constraint(equalTo: holderView.heightAnchor, constant: -20),
            contactImage.centerXAnchor.constraint(equalTo: holderView.centerXAnchor),
            contactImage.centerYAnchor.constraint(equalTo: holderView.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        return searchField
    }
    
    fileprivate func showCreateButton(show: Bool) {
        if show {
            navigationItem.rightBarButtonItem?.tintColor = view.tintColor
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.tintColor = UIColor.lightGray
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }

    func createChat() {
        guard let chat = chat, let context = context else { return }
        chat.participants = NSSet(array: selectedContacts)
        chatCreationDelegate?.created(chat: chat, context: context)
        dismiss(animated: false, completion: nil)
    
    }
    
    fileprivate func endSearch() {
        displayedContacts = selectedContacts
        tableView.reloadData()
    }


}

extension NewGroupParticipantsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedContacts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let contact = displayedContacts[indexPath.row]
        cell.textLabel?.text = contact.fullName
        cell.selectionStyle = .none
        return cell
    }
    
}

extension NewGroupParticipantsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard isSearching else {return}
        let contact = displayedContacts[indexPath.row]
        guard !selectedContacts.contains(contact) else {return}
        selectedContacts.append(contact)
        allContacts.remove(at: allContacts.index(of: contact)!)
        searchField.text = ""
        endSearch()
        showCreateButton(show: true)
    }
}

extension NewGroupParticipantsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        isSearching = true
        guard let currentText = textField.text else {
            endSearch()
            return true
        }
        let text = NSString(string: currentText).replacingCharacters(in: range, with: string)
        if text.characters.count == 0 {
            endSearch()
            return true
        }
        displayedContacts = allContacts.filter {
            contact in
            let match = contact.fullName.range(of: text) != nil
            return match
        }
        tableView.reloadData()
        return true
    }
}
