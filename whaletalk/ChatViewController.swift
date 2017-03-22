//
//  ViewController.swift
//  whaletalk
//
//  Created by WONGKAI MING on 17/3/17.
//  Copyright © 2017年 WONGKAI MING. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {

    private let tableView = UITableView()
    private let newMessageField = UITextView()
    
    public var messages = [Message]()
    private var bottomConstraint: NSLayoutConstraint!
    private var newMessageIndex: NSIndexPath!
    public let cellIdentifier = "Cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var localIncoming = true
        
        for i in 0...10{
            let m = Message()
            m.text = "This is a longer message"
            m.incoming = localIncoming
            localIncoming = !localIncoming
            messages.append(m)
        }
        
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
        
        tableView.register(ChatCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.estimatedRowHeight = 44
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        let tableViewConstraints: [NSLayoutConstraint] = [
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: newMessageArea.topAnchor)
        ]
        
        NSLayoutConstraint.activate(tableViewConstraints)
        
        //keyboard observer
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapRecognizer)
    }
//END viewdidload
    
    //keyboard oberserver func
    func keyboardWillShow(notification: NSNotification) {
        //if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            //let window = self.view.window?.frame {
            // We're not just minusing the kb height from the view height because
            // the view could already have been resized for the keyboard before
            //self.view.frame = CGRect(x: self.view.frame.origin.x,
            //                         y: self.view.frame.origin.y,
            //                         width: self.view.frame.width,
            //                         height: window.origin.y + window.height - keyboardSize.height)
        //else {
        //    debugPrint("We're showing the keyboard and either the keyboard size or window is nil: panic widely.")
        //}
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
            let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: animationduration, animations: {self.view.layoutIfNeeded()})
            if bottomConstraint.constant == 0{
                bottomConstraint.constant = self.view.frame.origin.y - keyboardSize.height
                //self.view.frame.origin.y = bottomConstraint.constant
            }
            else{
                bottomConstraint.constant += keyboardSize.height
            }
        }
    }
    
    func pressedSend(button: UIButton){
        
        guard let text = newMessageField.text, text.characters.count > 0 else {return}
        let message = Message()
        message.text = text
        message.incoming = false
        messages.append(message)
        tableView.reloadData()
        newMessageIndex = NSIndexPath(row: tableView.numberOfRows(inSection: 0)-1, section: 0)
        tableView.scrollToRow(at: newMessageIndex as IndexPath, at: .bottom, animated: true)
        
    }

}
//END ChatViewController


extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ChatCell
        let message = messages[indexPath.row]
        cell.messageLabel.text = message.text
        cell.incoming(incoming: message.incoming)
        
        //remove separator
        cell.separatorInset = UIEdgeInsetsMake(0, tableView.bounds.size.width, 0, 0)
        
        return cell
    }
}

//turn off highlighting in cell
extension ChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
