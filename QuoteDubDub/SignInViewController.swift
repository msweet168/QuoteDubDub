//
//  SignInViewController.swift
//  QuoteDubDub
//
//  Created by Mitchell Sweet on 4/4/17.
//  Copyright © 2017 Mitchell Sweet & Erik Martin. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {

    //TODO: Fix textField offset
    
	@IBOutlet weak var eField: UITextField!
	@IBOutlet weak var passField: UITextField!

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	@IBAction func didTapSignup() {
        guard let email = self.eField.text, let password = self.passField.text else { return showMessagePrompt("email and password can't be empty", title: " ") }

		Auth.auth().createUser(withEmail: email, password: password) { user, error in
            guard error == nil else { return self.showMessagePrompt(error!.localizedDescription, title: " ") }

			print("\(user!.email!) created")
			self.navigationController?.dismiss(animated: true)
		}
	}

	@IBAction func didTapSignin() {
        guard let email = self.eField.text, let password = self.passField.text else { return showMessagePrompt("email and password can't be empty", title: " ") }

		Auth.auth().signIn(withEmail: email, password: password) { user, error in
            guard error == nil else { return self.showMessagePrompt(error!.localizedDescription, title: " ") }

			print("\(user!.email!) signed in")
			self.dismiss(animated: true)
		}
	}

	@IBAction func didTapForgotPassword() {
        guard let email = self.eField.text else { return showMessagePrompt("email can't be empty", title: " ") }

		Auth.auth().sendPasswordReset(withEmail: email) { error in
            guard error == nil else { return self.showMessagePrompt(error!.localizedDescription, title: " ") }

            self.showMessagePrompt("Check your email to reset your password.", title: "Email sent!")
		}
	}

    func showMessagePrompt(_ message: String, title: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .default))

		self.present(alert, animated: true)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

}
