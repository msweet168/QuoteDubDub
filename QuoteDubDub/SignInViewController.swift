//
//  SignInViewController.swift
//  QuoteDubDub
//
//  Created by Mitchell Sweet on 4/4/17.
//  Copyright © 2017 Mitchell Sweet. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {
    
    @IBOutlet weak var eField: UITextField!
    @IBOutlet weak var passField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ViewSetup()

    }
    
    @IBAction func didTapSignup() {
        guard let email = self.eField.text, let password = self.passField.text else { return showMessagePrompt("email and password can't be empty") }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password) { user, error in
            guard error == nil else { return self.showMessagePrompt(error!.localizedDescription) }
            
            print("\(user!.email!) created")
            self.navigationController?.dismiss(animated: true)
        }
    }
    
    @IBAction func didTapSignin() {
        guard let email = self.eField.text, let password = self.passField.text else { return showMessagePrompt("email and password can't be empty") }
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password) { user, error in
            guard error == nil else { return self.showMessagePrompt(error!.localizedDescription) }
            
            print("\(user!.email!) signed in")
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func didTapForgotPassword() {
        guard let email = self.eField.text else { return showMessagePrompt("email can't be empty") }
        
        FIRAuth.auth()?.sendPasswordReset(withEmail: email) { error in
            guard error == nil else { return self.showMessagePrompt(error!.localizedDescription) }
            
            self.showMessagePrompt("Sent!")
        }
    }
    
    func showMessagePrompt(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        
        self.present(alert, animated: true)
    }
    
    
    func ViewSetup() {
        
        
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
