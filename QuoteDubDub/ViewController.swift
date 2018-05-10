//
//  ViewController.swift
//  QuoteDubDub
//
//  Created by Mitchell Sweet on 4/4/17.
//  Copyright © 2017 Mitchell Sweet & Erik Martin. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Spring

class CustomTableViewCell: UITableViewCell {
	//maybe add more stuff later??
	@IBOutlet weak var quoteLabel: UILabel!
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	var handle: AuthStateDidChangeListenerHandle?
	var ref: DatabaseReference!
    
    // View IDs:
    // 1 - main menu
    // 2 - add post menu
    
    var currentViewID = 1

    // UI Elements: //
	@IBOutlet var table: UITableView!
	
	@IBOutlet weak var quoteCard: SpringImageView!
	@IBOutlet weak var enterQuoteTextField: SpringTextView!

	@IBOutlet weak var addButton: SpringButton!
	
	@IBOutlet weak var animateTableView: SpringView!

	@IBOutlet weak var backButton: UIButton!
	@IBOutlet weak var signOutButton: UIButton!
	
    //database array:
	var quotes: [String: String] = [:] {
		didSet {
			quotes_keys = Array(quotes.keys)
		}
	}

	var quotes_keys: [String] = []

	override func viewDidLoad() {
		super.viewDidLoad()
        
		FirebaseSetup()

		self.table.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "custom")

		animationPropertiesSetup()
		
		//uncomment this line to clear database, just here for testing purposes.
		//self.ref.removeValue()
	}
    
    
    //////////////////////////
    // MARK: Firebase Stuff //
    //////////////////////////
    
	func FirebaseSetup() {
		Database.database().isPersistenceEnabled = true

		ref = Database.database().reference()

		//auth stuff
		handle = Auth.auth().addStateDidChangeListener() { auth, user in
			if user == nil {
				self.navigationController?.performSegue(withIdentifier: "signin", sender: self)
			} else {
				self.setupData(withUser: user!)
			}
		}
	}

	func setupData(withUser user: User) {
		ref.child("quotes").observe(.value, with: { snapshot in
			self.quotes = snapshot.value as? [String: String] ?? [:]
			DispatchQueue.main.async {
				self.table.reloadData()
			}
		})
	}
    
    
    
    /////////////////////////////////
    // MARK: UI Element Animations //
    /////////////////////////////////
    
    var backTracker = 0
    
    func didTapBackOrSignOut() {
        
        if backTracker == 0 {
           
            //log out
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch let error {
                print("Error on signout: \(error.localizedDescription)")
            }
            
            backTracker = 1
            
        } else if backTracker == 1 {
            
            UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.curveEaseInOut, animations:{
               
                self.addButton.frame = CGRect.init(
                    x: self.view.frame.size.width - self.addButton.frame.size.width,
                    y: self.addButton.frame.origin.y,
                    width: self.addButton.frame.size.width,
                    height: self.addButton.frame.size.height)
                
            }, completion: { (finished: Bool) in})
            
            //make a function for this?
            // {{
            animateTableView.animation = "fadeInRight"
            animateTableView.animate()
            
            quoteCard.animation = "fadeInLeft"
            quoteCard.animateTo()
            
            enterQuoteTextField.animation = "fadeInLeft"
            enterQuoteTextField.animateTo()
            
            table.isHidden = false
            // }}
            
            self.enterQuoteTextField.resignFirstResponder()
            
            tracker = 0
            backTracker = 0
        }
    }
    
	@IBAction func didTapSignout(_ sender: Any) {
        
        //make sure we are only able to sign out while on the main menu
        if currentViewID == 1 {
            backTracker = 0
        } else {
            backTracker = 1
        }
        
        didTapBackOrSignOut()
	}
    
    //TODO: rename tacker & backtracker to better names (to,from?)
    var tracker = 0
    
    func addButtonPressed() {
        if tracker == 0 {
            
            UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                self.addButton.frame = CGRect.init(
                    x: (self.view.frame.size.width / 2) - (self.addButton.frame.size.width / 2),
                    y: self.addButton.frame.origin.y,
                    width: self.addButton.frame.size.width,
                    height: self.addButton.frame.size.height)
            }, completion: { (finished: Bool) in})
            
            tracker = 1
            
            quoteCard.isHidden = false
            enterQuoteTextField.isHidden = false
            
            animateTableView.animation = "fadeInRight"
            animateTableView.animateTo()
            
            quoteCard.animation = "fadeInLeft"
            quoteCard.animate()
            
            enterQuoteTextField.animation = "fadeInLeft"
            enterQuoteTextField.animate()
            
            currentViewID = 2
            
        } else if tracker == 1 {

            UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                self.addButton.frame = CGRect.init(
                    x: self.view.frame.size.width - self.addButton.frame.size.width,
                    y: self.addButton.frame.origin.y,
                    width: self.addButton.frame.size.width,
                    height: self.addButton.frame.size.height)
            }, completion: { (finished: Bool) in})
            
            self.tracker = 0
            
            self.animateTableView.animation = "fadeInRight"
            self.animateTableView.animate()
            
            self.quoteCard.animation = "fadeInLeft"
            self.quoteCard.animateTo()
            
            self.enterQuoteTextField.animation = "fadeInLeft"
            self.enterQuoteTextField.animateTo()
            
            self.table.isHidden = false
            
            guard let textField = self.enterQuoteTextField else { return }
            guard let text = textField.text else { return }
            guard !text.isEmpty else { return }
            
            // Save text
            self.ref.child("quotes").childByAutoId().setValue(text)
            
            self.enterQuoteTextField.resignFirstResponder()
            
            currentViewID = 1
        }
    }
    
	@IBAction func didTapAdd(_ sender: Any) {
        addButtonPressed()
	}

	func animationPropertiesSetup() {

		self.addButton.frame = CGRect.init(
			x: self.addButton.frame.midX - (self.addButton.frame.size.width / 2),
			y: self.addButton.frame.origin.y - (self.addButton.frame.size.height / 4),
			width: self.addButton.frame.size.width,
			height: self.addButton.frame.size.height)

		animateTableView.curve = "easeInOut"
		animateTableView.damping = 0.7
		animateTableView.velocity = 0.7
		animateTableView.duration = 1.0

		quoteCard.curve = "easeInOut"
		quoteCard.damping = 0.7
		quoteCard.velocity = 0.7
		quoteCard.duration = 1.0

		enterQuoteTextField.curve = "easeInOut"
		enterQuoteTextField.damping = 0.7
		enterQuoteTextField.velocity = 0.7
		enterQuoteTextField.duration = 1.0
		
	}
    
    ////////////////////////////////////
	// MARK: - Table View Data Source //
    ////////////////////////////////////
    
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return quotes_keys.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: CustomTableViewCell = self.table.dequeueReusableCell(withIdentifier: "custom") as! CustomTableViewCell

		let key = quotes_keys[indexPath.row]
		let data = quotes[key]

		cell.quoteLabel.text = data ?? ""
		
		return cell
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

}

