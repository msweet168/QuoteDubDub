//
//  ViewController.swift
//  QuoteDubDub
//
//  Created by Mitchell Sweet on 4/4/17.
//  Copyright © 2017 Mitchell Sweet. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Spring

class CustomTableViewCell : UITableViewCell {
	//maybe add more stuff later??
	@IBOutlet weak var quoteLabel: UILabel!
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
	var handle: AuthStateDidChangeListenerHandle?
	var ref: DatabaseReference!
    
    @IBOutlet var table:UITableView!
	@IBOutlet weak var quoteCard: SpringImageView!
	@IBOutlet weak var enterQuoteTextField: SpringTextView!
	@IBOutlet weak var addButton: UIButton!
	@IBOutlet weak var addButtonInitial: SpringButton!
	@IBOutlet weak var animateTableView: SpringView!
	@IBOutlet weak var addButtonAnimateDecoy: UIImageView!
	
	var quotes: [String: String] = [:] {
        didSet {
            quotes_keys = Array(quotes.keys)
        }
    }
    var quotes_keys: [String] = []
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        FirebaseSetup()
	
		self.table.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "custom")
		
		animationPropertiesSetup()
    }
    
    
    func FirebaseSetup() {
		Database.database().isPersistenceEnabled = true
        
		ref = Database.database().reference()
        
        // Auth stuff
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
	
    @IBAction func didTapSignout(_ sender: Any) {
		let firebaseAuth = Auth.auth()
        do {
			try firebaseAuth.signOut()
        } catch let error {
            print("Error on signout: \(error.localizedDescription)")
        }
    }
    
	@IBAction func didTapAddButton(_ sender: Any) {
		//animate these later
		animateTableView.animation = "fadeInRight"
		animateTableView.animate()
		
		addButton.isHidden = true
		addButtonAnimateDecoy.isHidden = false
		UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.curveEaseInOut, animations:{
			self.addButtonAnimateDecoy.frame = CGRect.init(x:self.addButtonInitial.frame.midX - (self.addButtonInitial.frame.size.width/2), y: self.addButton.frame.origin.y, width: self.addButtonAnimateDecoy.frame.size.width, height: self.addButtonAnimateDecoy.frame.size.height)
		}, completion: {(finished:Bool) in
			self.addButtonAnimateDecoy.isHidden = true
			self.addButtonInitial.isHidden = false
		})
		
		quoteCard.animation = "fadeInLeft"
		quoteCard.animateTo()
		
		enterQuoteTextField.animation = "fadeInLeft"
		enterQuoteTextField.animateTo()
		
		guard let textField = enterQuoteTextField else { return }
		guard let text = textField.text else { return }
		guard !text.isEmpty else { return }
		//guard let user = FIRAuth.auth()?.currentUser?.email else { return }
		//guard let userCode = FIRAuth.auth()?.currentUser else { return }
		
		// Save text
		self.ref.child("quotes").childByAutoId().setValue(text)
		
		self.enterQuoteTextField.resignFirstResponder()
		table.isHidden = false
		
	}
	
	func animationPropertiesSetup() {
		
		self.addButtonAnimateDecoy.frame = CGRect.init(x:self.addButtonInitial.frame.midX - (self.addButtonInitial.frame.size.width/2), y: self.addButton.frame.origin.y - (self.addButtonInitial.frame.size.height/4), width: self.addButtonAnimateDecoy.frame.size.width, height: self.addButtonAnimateDecoy.frame.size.height)
		
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
	
	@IBAction func didTapAdd(_ sender: Any) {
		//animate these later
		//table.isHidden = true
		
		animateTableView.animation = "fadeInRight"
		animateTableView.animateTo()
		
		addButtonInitial.isHidden = true
		addButtonAnimateDecoy.isHidden = false
		
		UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.curveEaseInOut, animations:{
			self.addButtonAnimateDecoy.frame = CGRect.init(x: (self.view.frame.size.width/2) -  (self.addButton.frame.size.width/2), y: self.addButton.frame.origin.y, width: self.addButtonAnimateDecoy.frame.size.width, height: self.addButtonAnimateDecoy.frame.size.height)
		}, completion: {(finished:Bool) in
			self.addButtonAnimateDecoy.isHidden = true
			self.addButton.isHidden = false
		})
		
		quoteCard.isHidden = false
		
		quoteCard.animation = "fadeInLeft"
		quoteCard.animate()
		
		enterQuoteTextField.isHidden = false
		
		enterQuoteTextField.animation = "fadeInLeft"
		enterQuoteTextField.animate()
		
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotes_keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell : CustomTableViewCell = self.table.dequeueReusableCell(withIdentifier: "custom") as! CustomTableViewCell
		
        let key = quotes_keys[indexPath.row]
        let data = quotes[key]
        
        cell.quoteLabel.text = data ?? ""
		
        return cell
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
}

