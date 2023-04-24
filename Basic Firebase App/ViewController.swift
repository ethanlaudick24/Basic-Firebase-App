//
//  ViewController.swift
//  Basic Firebase App
//
//  Created by Scott Laudick on 4/23/23.
//

class Stuff{
    var ref = Database.database().reference()
    var text: String
    var number: Int
    var key = ""
    
    init(text: String, number: Int) {
        self.text = text
        self.number = number
    }
    
    init(dict: [String: Any]) {
        if let n = dict["text"] as? String {
            text = n
        } else{
            text = "default"
        }
        if let a = dict["number"] as? Int {
            number = a
        } else{
            number = 0
        }
        
    }
    
    func saveToFirebase(){
        let dict = ["text": text, "number": number] as [String: Any]
        key = ref.child("objects").childByAutoId().key ?? "0"
        ref.child("objects").child(key).setValue(dict)
    }
    
    
    func deleteFromFirebase() {
        ref.child("objects").child(key).removeValue()
    }
    
    func editOnFirebase() {
        let dict = ["text": text, "number": number] as! [String: Any]
        ref.child("objects").child(key).updateChildValues(dict)
    }
    
}

import UIKit
import FirebaseCore
import FirebaseDatabase

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textFieldNumber: UITextField!
    @IBOutlet weak var tableViewOutlet: UITableView!
    
    var ref: DatabaseReference!
    var text = [String]()
    var things = [Stuff]()
    var selectedIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableViewOutlet.delegate = self
        tableViewOutlet.dataSource = self
        
        ref = Database.database().reference()
        /*
        ref.child("text").observe(.childAdded, with: { (snapshot) in
                    let n = snapshot.value as! String
                    if !self.text.contains(n){
                        self.text.append(n)
                    }
            self.tableViewOutlet.reloadData()
                })

        ref.child("text").observeSingleEvent(of: .value, with: { snapshot in
                        print("--inital load has completed and the last user was read--")
                        print(self.text)
                    })
        */
        ref.child("objects").observe(.childAdded, with: { (snapshot) in
            
                    let dict = snapshot.value as! [String:Any]
                    let s = Stuff(dict: dict)
                    s.key = snapshot.key
                    self.things.append(s)
            self.tableViewOutlet.reloadData()
                })
                
                ref.child("objects").observeSingleEvent(of: .value, with: { snapshot in
                        print("--inital load has completed and the last object was read--")
                    // print the number of objects to see if it worked
                    print(self.things.count)
                    self.tableViewOutlet.reloadData()
                    })
        
        ref.child("students2").observe(.childAdded) { snapshot in
            
            for i in 0..<self.things.count {
                if self.things[i].key == snapshot.key {
                    self.things.remove(at: i)
                    self.tableViewOutlet.reloadData()
                    break
                }
            }
            self.tableViewOutlet.reloadData()
        }
        
        ref.child("students2").observe(.childChanged) { snapshot in
            let key = snapshot.key
            let value = snapshot.value as! [String: Any]
            for i in 0..<self.things.count {
                if self.things[i].key == key {
                    self.things[i].text = value["text"] as! String
                    self.things[i].number = value["number"] as! Int
                    break
                }
            }
            self.tableViewOutlet.reloadData()
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(things.count)
        return things.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewOutlet.dequeueReusableCell(withIdentifier: "myCell")!
        cell.textLabel?.text = things[indexPath.row].text
        cell.detailTextLabel?.text = String(things[indexPath.row].number)
        return cell
    }


    @IBAction func buttonButton(_ sender: Any) {
        
        let object = Stuff(text: textField.text!, number: Int(textFieldNumber.text!)!)
        object.saveToFirebase()
        tableViewOutlet.reloadData()
        
    }
    
    @IBAction func editButton(_ sender: Any) {
        things[selectedIndex].text = textField.text!
        things[selectedIndex].number = Int(textFieldNumber.text!)!
        things[selectedIndex].editOnFirebase()
        tableViewOutlet.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //delete func
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            things[indexPath.row].deleteFromFirebase()
            things.remove(at: indexPath.row)
            tableViewOutlet.reloadData()
        }
    }
    
}

