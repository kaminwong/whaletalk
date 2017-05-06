//
//  SignUpViewController.swift
//  WhaleTalk
//
//  Created by WONGKAI MING on 6/5/17.
//  Copyright © 2017年 WONGKAI MING. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    private let phoneNumberField = UITextField()
    private let emailField = UITextField()
    private let passwordField = UITextField()
    
    var remoteStore: RemoteStore?
    var contactImporter: ContactImporter?
    var rootViewController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        let label = UILabel()
        label.text = "Sign up with Kalink"
        label.font = UIFont.systemFont(ofSize: 24)
        view.addSubview(label)
        
        let continueButton = UIButton()
        continueButton.setTitle("Continue", for: .normal)
        continueButton.setTitleColor(UIColor.black, for: .normal)
        continueButton.addTarget(self, action: #selector(self.pressedContinue), for: .touchUpInside)
        view.addSubview(continueButton)
        
        phoneNumberField.keyboardType = .phonePad
        
        label.translatesAutoresizingMaskIntoConstraints = false
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        
        let fields = [(phoneNumberField, "Phone Number"), (emailField, "Email"), (passwordField, "Password")]
        fields.forEach {
            $0.0.placeholder = $0.1
        }
        
        passwordField.isSecureTextEntry = true
        
        let stackView = UIStackView(arrangedSubviews: fields.map{$0.0})
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 20
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints: [NSLayoutConstraint] = [
        label.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 20),
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        stackView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
        stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
        stackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        continueButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
        continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        phoneNumberField.becomeFirstResponder()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pressedContinue(sender: UIButton) {
        sender.isEnabled = false
        guard let phoneNumber = phoneNumberField.text, phoneNumber.characters.count > 0 else {
            alertForError(error: "Please include your phone number")
            sender.isEnabled = true
            return
        }
        guard let email = emailField.text, email.characters.count > 0 else {
            alertForError(error: "Please include your email")
            sender.isEnabled = true
            return
        }
        guard let password = passwordField.text, password.characters.count >= 6 else {
            alertForError(error: "Password must be at least 6 characters")
            sender.isEnabled = true
            return
        }
        
        remoteStore?.signUp(phoneNumber: phoneNumber, email: email, password: password, success: {
            guard let rootVC = self.rootViewController, let remoteStore = self.remoteStore, let contactImporter = self.contactImporter else {return}
            remoteStore.startSyncing()
            contactImporter.fetch()
            contactImporter.listenForChanges()
            
            self.present(rootVC, animated: true, completion: nil)
        
        }, error: {
            errorString in
            self.alertForError(error: errorString)
            sender.isEnabled = true
        })
    }
    
    private func alertForError(error: String) {
        let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    



}
