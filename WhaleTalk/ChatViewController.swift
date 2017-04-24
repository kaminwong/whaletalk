//
//  ViewController.swift
//  whaletalk
//
//  Created by WONGKAI MING on 17/3/17.
//  Copyright © 2017年 WONGKAI MING. All rights reserved.
//

import UIKit
import CoreData

class ChatViewController: UIViewController {
    

    private let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    private let newMessageField = UITextView()
    
    fileprivate var sections = [Date: [Message]]()
    fileprivate var dates = [Date]()
    fileprivate var messages: [Message] = []
    //public var messages = [Message]()
    fileprivate var bottomConstraint: NSLayoutConstraint!
    fileprivate let cellIdentifier = "Cell"
    
    var context: NSManagedObjectContext?
    var coreDataStack: CoreDataStack!
    
    var chat: Chat?
    
    private enum DataError: Error {
        case NoChat
        case NoContext
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        //let managedContext = coreDataStack.managedContext
        
        do {
            guard let chat = chat else {throw DataError.NoChat}
            guard let context = context else {throw DataError.NoContext}
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Message")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            fetchRequest.predicate = NSPredicate(format: "chat=%@", chat)
            let result = try context.fetch(fetchRequest)
            for message in result {
                addMessage(message: message as! Message)
            }
        }
        catch {
            print ("we couldn't fetch")
        }
        automaticallyAdjustsScrollViewInsets = false
        
        //Message Area for typing new messages
        
        let newMessageArea = UIView()
        newMessageArea.backgroundColor = UIColor.lightGray
        newMessageArea.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newMessageArea)
        
        newMessageField.translatesAutoresizingMaskIntoConstraints = false
        newMessageArea.addSubview(newMessageField)
        newMessageField.isScrollEnabled = false
        
        let sendButton = UIButton()
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        newMessageArea.addSubview(sendButton)
        
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(self.pressedSend), for: .touchUpInside)
        sendButton.setContentHuggingPriority(251, for: .horizontal)
        sendButton.setContentCompressionResistancePriority(751, for: .horizontal)
        
        bottomConstraint = newMessageArea.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomConstraint.isActive = true
        
        let messageAreaConstraints: [NSLayoutConstraint] = [
        
            newMessageArea.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newMessageArea.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            //newMessageArea.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            

            newMessageField.leadingAnchor.constraint(equalTo: newMessageArea.leadingAnchor, constant: 10),
            newMessageField.centerYAnchor.constraint(equalTo: newMessageArea.centerYAnchor),
            
            sendButton.trailingAnchor.constraint(equalTo: newMessageArea.trailingAnchor, constant: -10),
            newMessageField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            sendButton.centerYAnchor.constraint(equalTo: newMessageField.centerYAnchor),
            
            newMessageArea.heightAnchor.constraint(equalTo: newMessageField.heightAnchor, constant: 20)
            
        ]
        
        NSLayoutConstraint.activate(messageAreaConstraints)
        
        tableView.register(MessageCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.estimatedRowHeight = 44
        tableView.backgroundView = UIImageView(image: UIImage(named: "MessageBubble"))
        tableView.separatorColor = UIColor.clear
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 25
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        let tableViewConstraints: [NSLayoutConstraint] = [
            tableView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: newMessageArea.topAnchor)
        ]
        
        NSLayoutConstraint.activate(tableViewConstraints)
        
        //keyboard observer
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        if let mainContext = context?.parent ?? context{
            NotificationCenter.default.addObserver(self, selector: #selector(self.contextUpdated(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: mainContext)
        }
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapRecognizer)
    }
//END viewdidload
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.scrolltoBottom()
    }
    
    //keyboard oberserver func
    func keyboardWillShow(_ notification: NSNotification) {
    //    if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
    //        let window = self.view.window?.frame {
            // We're not just minusing the kb height from the view height because
            // the view could already have been resized for the keyboard before
    //        self.view.frame = CGRect(x: self.view.frame.origin.x,
    //                                 y: self.view.frame.origin.y,
    //                                 width: self.view.frame.width,
    //                                 height: window.origin.y + window.height - keyboardSize.height)
    //    }
    //    else {
        //    debugPrint("We're showing the keyboard and either the keyboard size or window is nil: panic widely.")
    //    }
        
        updateBottomConstraint(_:notification)
    }
    
    
    func keyboardWillHide(notification: NSNotification) {
        
        //if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
        //    if self.view.frame.origin.y != 0{
        //        self.view.frame.origin.y += keyboardSize.height
        
        //}
        
        updateBottomConstraint(_:notification)

        }




    
    //

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleSingleTap(_ recognizer: UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    //for keyboard show hide and animations
    func updateBottomConstraint(_ notification: NSNotification){
        if let userInfo = notification.userInfo,
            let animationduration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double,
            let frame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect {
            //let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            //NOTE: the order of code matters
            let newFrame = view.convert(frame, from: (UIApplication.shared.delegate?.window)!)
            bottomConstraint.constant = newFrame.origin.y - view.frame.height
            UIView.animate(withDuration: animationduration, animations: {self.view.layoutIfNeeded()})
            
            //bottomConstraint.constant = self.view.frame.origin.y - keyboardSize.height
            
            
            /*
            if bottomConstraint.constant == 0{
                bottomConstraint.constant = self.view.frame.origin.y - keyboardSize.height
                //self.view.frame.origin.y = bottomConstraint.constant
            }
            else{
                bottomConstraint.constant += keyboardSize.height
            }
            */
            
            tableView.scrolltoBottom()
        }
    }
    
    func pressedSend(button: UIButton){
        
        //guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        //let managedContext = coreDataStack.managedContext
        checkTemporaryContext()
        guard let context = context else {return}
        guard let text = newMessageField.text, text.characters.count > 0 else {return}
        guard let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as? Message else {return}
        //let message = Message(context: context)

        message.text = text
        message.timestamp = NSDate()
        message.chat = chat
        chat?.lastMessageTime = message.timestamp
        newMessageField.text = ""
        
        //save to core data
        
        do {
            try context.save()
        }
        catch {
            print ("there is a problem saving")
            return
        }
        view.endEditing(true)
    }
    
    func addMessage(message: Message){
        guard let date = message.timestamp else {return}
        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: date as Date)
        
        var messages = sections[startDay]
        if messages == nil {
            dates.append(startDay as Date)
            dates = dates.sorted()
            messages = [Message]()
        }
        messages!.append(message)
        messages!.sort{$0.timestamp!.earlierDate($1.timestamp! as Date) == $0.timestamp! as Date}
        sections[startDay] = messages
    }
    
    func contextUpdated(notification: Notification) {
        guard let set = (notification.userInfo![NSInsertedObjectsKey] as? NSSet) else {return}
        let objects = set.allObjects
        for obj in objects {
            guard let message = obj as? Message else {continue}
            if message.chat?.objectID == chat?.objectID {
                addMessage(message: message)
            }
        }
        
        tableView.reloadData()
        tableView.scrolltoBottom()
    }
    
    func checkTemporaryContext() {
        if let mainContext = context?.parent, let chat = chat {
            let tempContext = context
            context = mainContext
            do {
                try tempContext?.save()
            } catch {
                print("Error saving tempContext")
            }
            self.chat = mainContext.object(with: chat.objectID) as? Chat
        }
    }
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
}

//END ChatViewController



/*extension Chat: NSManagedObject {
    //var managedContext: NSManagedObjectContext!
    var lastMessage:Message? {
        let request = NSFetchRequest<Message>(entityName: "Message")
        request.predicate = NSPredicate(format: "chat = %@", self)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        request.fetchLimit = 1
        do {
            guard let results = try self.managedContext.fetch(request) else
            {return nil}
            return results.first
        }
        catch {
            print("Error for Request")
        }
        return nil
    }
}*/


extension ChatViewController: UITableViewDataSource {
    
    func getMessages(section: Int) -> [Message] {
        let date = dates[section]
        return sections[date]!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dates.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getMessages(section: section).count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MessageCell
        
        let messages = getMessages(section: indexPath.section)
        let message = messages[indexPath.row]
        cell.messageLabel.text = message.text
        cell.incoming(incoming: message.isIncoming)
        cell.backgroundColor = UIColor.clear
        
        //remove separator
        cell.separatorInset = UIEdgeInsetsMake(0, tableView.bounds.size.width, 0, 0)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        let paddingView = UIView()
        view.addSubview(paddingView)
        paddingView.translatesAutoresizingMaskIntoConstraints = false
        let dateLabel = UILabel()
        paddingView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints:[NSLayoutConstraint] = [
        paddingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        paddingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        dateLabel.centerXAnchor.constraint(equalTo: paddingView.centerXAnchor),
        dateLabel.centerYAnchor.constraint(equalTo: paddingView.centerYAnchor),
        paddingView.heightAnchor.constraint(equalTo: dateLabel.heightAnchor, constant: 5),
        paddingView.widthAnchor.constraint(equalTo: dateLabel.widthAnchor, constant: 10),
        view.heightAnchor.constraint(equalTo: paddingView.heightAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, YYYY"
        dateLabel.text = formatter.string(from: dates[section] as Date)
        
        paddingView.layer.cornerRadius = 10
        paddingView.layer.masksToBounds = true
        paddingView.backgroundColor = UIColor(red:153/255, green: 204/255, blue: 255/255, alpha: 1.0)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
}

//turn off highlighting in cell
extension ChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
