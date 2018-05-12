//
//  SignInViewController.swift
//  QuoteDubDub
//
//  Created by Mitchell Sweet on 4/4/17.
//  Copyright © 2017 Mitchell Sweet & Erik Martin. All rights reserved.
//

import UIKit
import FirebaseAuth

extension UITextField {
    func setBottomBorder() {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 0.7
        self.layer.shadowRadius = 0.0
    }
}

class SignInViewController: UIViewController {

	@IBOutlet weak var eField: UITextField!
	@IBOutlet weak var passField: UITextField!

    //assigned to all buttons so we can adjust thier properties simotaneuosly
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
		super.viewDidLoad()
        
        eField.setBottomBorder()
        passField.setBottomBorder()
        
        //let buttonRoundedCorner = UIBezierPath(roundedRect: button.bounds, cornerRadius: 20.0)
        //let maskLayer = CAShapeLayer()
        //maskLayer.path = buttonRoundedCorner.cgPath
        //button.mask = UIView(maskLayer)
    }

    
    func addPaddingAndBorder(to textfield: UITextField) {
        
        let leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 5.0, height: 0.0))
        textfield.leftView = leftView
        textfield.leftViewMode = .always
       
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
