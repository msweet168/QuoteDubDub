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

class CustomTableViewCell : UITableViewCell {
	
	@IBOutlet weak var quoteLabel: UILabel!
	
	
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var handle: FIRAuthStateDidChangeListenerHandle?
    var ref: FIRDatabaseReference!
    
    @IBOutlet var table:UITableView!
    
    var quotes: [String: String] = [:] {
        didSet {
            quotes_keys = Array(quotes.keys)
        }
    }
    var quotes_keys: [String] = []
    
    @IBOutlet weak var emailLabel: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        FirebaseSetup()
        ViewSetup()
		
		self.table.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "custom")
    }
    
    
    func FirebaseSetup() {
        
        FIRDatabase.database().persistenceEnabled = true
        
        ref = FIRDatabase.database().reference()
        
        // Auth stuff
        handle = FIRAuth.auth()?.addStateDidChangeListener() { auth, user in
            if user == nil {
                self.navigationController?.performSegue(withIdentifier: "signin", sender: self)
            } else {
                self.setupData(withUser: user!)
            }
        }
        
    }
    
    func setupData(withUser user: FIRUser) {
        ref.child("quotes").observe(.value, with: { snapshot in
            self.quotes = snapshot.value as? [String: String] ?? [:]
            DispatchQueue.main.async {
                self.table.reloadData()
            }
        })
        
        emailLabel.text = user.email!

    }
    
    
    
    @IBAction func didTapSignout(_ sender: Any) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
        } catch let error {
            print("Error on signout: \(error.localizedDescription)")
        }
    }
    
    @IBAction func didTapAdd(_ sender: Any) {
        let alert = UIAlertController(title: "Add Data", message: "Enter your quote: ", preferredStyle: .alert)
        
        alert.addTextField() { textfield in
        }
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { [weak alert] _ in
            guard let textField = alert?.textFields?[0] else { return }
            guard let text = textField.text else { return }
            guard !text.isEmpty else { return }
            //guard let user = FIRAuth.auth()?.currentUser?.email else { return }
            //guard let userCode = FIRAuth.auth()?.currentUser else { return }
            
            // Save text
            self.ref.child("quotes").childByAutoId().setValue(text)
        })
        
        self.present(alert, animated: true)
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotes_keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : CustomTableViewCell = self.table.dequeueReusableCell(withIdentifier: "custom") as! CustomTableViewCell
        let key = quotes_keys[indexPath.row]
        let data = quotes[key]
        
        cell.quoteLabel.text = data ?? ""
        //cell.detailTextLabel?.text = key
        
        return cell
}
    

    
    
    func ViewSetup() {
        
        self.title = "WWDC Quotes"
        
        
    }
    
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        
        
    }


}

