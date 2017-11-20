//
//  ItemTableViewController.swift
//  ??
//
//  Created by Xiaolan Zhou on 10/28/17.
//  Copyright © 2017 Richard Liu. All rights reserved.
//

import UIKit
import os.log

class ItemTableViewController: UITableViewController {
    
    // MARK: Properties
    var items = [Item]()
    // combination of username and password, hashed
    var userpswd: String?
    @IBOutlet weak var tableTitle: UINavigationItem!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // enable edit button
        navigationItem.leftBarButtonItem = editButtonItem

        // load saved items, otherwise load no items
        loadItems()
//        loadSampleItems()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "AddItem":
            os_log("Adding a new item", log: OSLog.default, type: .debug)
        
        case "ShowDetail":
            guard let itemDetailViewController = segue.destination as? ItemViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedItemCell = sender as? ItemTableViewCell else {
                fatalError("Unexpected sender: \(sender ?? "")")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedItemCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedItem = items[indexPath.row]
            itemDetailViewController.item = selectedItem
        
        case "Login":
            os_log("loggin in", log: OSLog.default, type: .debug)
        
        case "Signup":
            os_log("signing up", log: OSLog.default, type: .debug)
        
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier ?? "")")
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // reuse table cells
        let cellIdentifier = "ItemTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ItemTableViewCell else {
            fatalError("The dequeued cell is not an instance of ItemTableViewCell.")
        }
        
        // get item at this row
        let item = items[indexPath.row]
        
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        let dateString = formatter.string(from: item.time)
        
        cell.nameLabel.text = item.name
        cell.photoImageView.image = item.photo
        cell.timeLabel.text = dateString
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            print(items)
            items.remove(at: indexPath.row)
            saveItems()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    // MARK: Actions
    @IBAction func unwindToItemList(sender: UIStoryboardSegue) {
        // from detailed item view/edit
        if let source = sender.source as? ItemViewController, let item = source.item {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                items[selectedIndexPath.row] = item
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                let newIndexPath = IndexPath(row: items.count, section: 0)
                
                items.append(item)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            saveItems()
        }
        
        // from login view
        if let source = sender.source as? LoginViewController {
            os_log("unwound from login view", log: OSLog.default, type: .debug)
            userpswd = source.userpswd
            
            loadItems()
            print(items)
        }
        
        // from sign up view
        if let source = sender.source as? SignupViewController {
            os_log("unwound from sign up view", log: OSLog.default, type: .debug)
            userpswd = source.userpswd
            
            saveItems()
        }
    }
    
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        if userpswd != nil {
            print(items)
            userpswd = nil
            for i in 0..<items.count {
                print(i)
                items.remove(at: 0)
                tableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }
            
            tableTitle.title = "Your Items"
            
            let myAlert = UIAlertController(title: "Log out successful", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            myAlert.addAction(okAction)
            self.present(myAlert, animated: true, completion: nil)
        } else {
            let myAlert = UIAlertController(title: "You are not logged in", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            myAlert.addAction(okAction)
            self.present(myAlert, animated: true, completion: nil)
        }

    }
    
    
    
    // MARK: Private methods
    private func loadSampleItems() {
        os_log("loading sample images", log: OSLog.default, type: .debug)
        
        let photo1 = UIImage(named: "item1")
        let photo2 = UIImage(named: "item2")
        let photo3 = UIImage(named: "item3")
        
        guard let item1 = Item(name: "Tennis racket", photo: photo1, desc: "Black adult tennis racket, second shelf", time: Date(timeIntervalSince1970: 1509499706)) else {
            fatalError("Unable to instantiate item1")
        }
        guard let item2 = Item(name: "Skis", photo: photo2, desc: "Pair of adult skis, left hand side at the very top.", time: Date(timeIntervalSince1970: 1459214906)) else {
            fatalError("Unable to instantiate item2")
        }
        guard let item3 = Item(name: "Guitar", photo: photo3, desc: "Old Yamaha from my Grandpa. In a black cover on the 3rd shelf.", time: Date(timeIntervalSince1970: 1429147706)) else {
            fatalError("Unable to instantiate item2")
        }
        
        items += [item1, item2, item3]
    }
    
    private func saveItems() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(items, toFile: Item.ArchiveURL.path)
        
        if isSuccessfulSave {
            os_log("items saved successfully", log: OSLog.default, type: .debug)
        } else {
            os_log("failed to save items", log: OSLog.default, type: .debug)
        }
        
        os_log("saving items online...", log: OSLog.default, type: .debug)
        
        // clear user's items
        if let up = userpswd {
            tableTitle.title = "\(up.components(separatedBy: "_")[0])'s Items"
            
            self.set(withItem: up.data(using: String.Encoding.utf8)!.base64EncodedString(), withString: "{\"placeholder\": 1}", withCompletion: {() -> Void in
                for item in self.items {
                    var json: JSON = ["foo": "true"]
                    
                    json["name"].stringValue = item.name
                    if let img = item.photo {
                        let imageData: Data = UIImagePNGRepresentation(img)!
                        json["image"].stringValue = imageData.base64EncodedString()
                    } else {
                        json["image"].stringValue = ""
                    }
                    json["desc"].stringValue = item.desc ?? ""
                    json["time"].doubleValue = item.time.timeIntervalSince1970
                    
//                    print(json.rawString()!)
                    
                    // add a new item each time
                    self.add(withItem: up.data(using: String.Encoding.utf8)!.base64EncodedString(), withString: json.rawString()!, withCompletion: { () -> Void in })
                }
            })
        } else {
            os_log("user has not logged in yet, not saving items", log: OSLog.default, type: .debug)
        }
    }
    
    private func loadItems() {
        // delete table items
        for i in 0..<items.count {
            print(i)
            tableView.deleteRows(at: [IndexPath(row: i, section: 0)], with: .automatic)
        }
        items = []
        
        if let up = userpswd {
            tableTitle.title = "\(up.components(separatedBy: "_")[0])'s Items"
            
            get(withItem: up.data(using: String.Encoding.utf8)!.base64EncodedString(), withCompletion: { (json: JSON?) -> Void in
                if let json = json {
                    os_log("got the json", log: OSLog.default, type: .debug)
                    for (key,subJson):(String, JSON) in json {
                        if key != "placeholder" {
                            var image: UIImage?
                            if subJson["image"].stringValue == "" {
                                image = nil
                            } else {
                                if let data = Data(base64Encoded: subJson["image"].stringValue, options: .ignoreUnknownCharacters) {
                                    image = UIImage(data: data)
                                } else {
                                    os_log("corrupt image string", log: OSLog.default, type: .debug)
                                }
                            }
                            
                            let i = Item(name: subJson["name"].stringValue, photo: image, desc: subJson["desc"].stringValue, time: Date(timeIntervalSince1970: subJson["time"].doubleValue))!
                            
                            let newIndexPath = IndexPath(row: self.items.count, section: 0)
                            
                            self.items.append(i)
                            self.tableView.insertRows(at: [newIndexPath], with: .automatic)
                        }
                    }
                }
            })
        } else {
            /*os_log("user has not logged in yet, will load archived items", log: OSLog.default, type: .debug)
            if let arcItems = NSKeyedUnarchiver.unarchiveObject(withFile: Item.ArchiveURL.path) as? [Item] {
                newItems = arcItems
            } else {
                os_log("archived items loading failed. not loading any items", log: OSLog.default, type: .debug)
            }*/
        }
    }
    
    
    // MARK: Firebase
    let baseUrl: String = "https://keeptrackofthings-1a133.firebaseio.com/"
    
    func get(withItem item: String, withCompletion completion: @escaping (JSON?) -> Void) {
        let session = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: OperationQueue.main)
        let url = URL(string: "\(baseUrl)\(item).json")!
        let task = session.dataTask(with: url, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            guard let data = data else {
                completion(nil)
                os_log("data is nil", log: OSLog.default, type: .debug)
                return
            }
            // debug: print string
//            print(String(data: data, encoding: String.Encoding.utf8) as String!)
            
            do {
                let json = try JSON(data: data)
                completion(json)
            } catch {
                os_log("json conversion failed", log: OSLog.default, type: .debug)
            }
        })
        task.resume()
    }
    
    func set(withItem item: String, withString str: String, withCompletion completion: @escaping () -> Void) {
        let session = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: OperationQueue.main)
        let url = URL(string: "\(baseUrl)\(item).json")!
        var req = URLRequest(url: url)
        req.httpMethod = "PUT"
        req.httpBody = str.data(using: .utf8)!
        
        let task = session.dataTask(with: req, completionHandler: { (data, response, err) in
            if data != nil {
                os_log("put response", log: OSLog.default, type: .debug)
//                print(String(data: data!, encoding: .utf8)!)
            }
            if err != nil {
                os_log("error in putting data, response code below", log: OSLog.default, type: .debug)
                if let httpResponse = response as? HTTPURLResponse {
//                    print(httpResponse.statusCode)
                }
            } else {
                completion()
            }
        })
        task.resume()
    }
    
    func add(withItem item: String, withString str: String, withCompletion completion: @escaping () -> Void) {
        let session = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: OperationQueue.main)
        let url = URL(string: "\(baseUrl)\(item).json")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST" // only differance from set
        req.httpBody = str.data(using: .utf8)!
        
        let task = session.dataTask(with: req, completionHandler: { (data, response, err) in
            if data != nil {
                os_log("put response", log: OSLog.default, type: .debug)
//                print(String(data: data!, encoding: .utf8)!)
            }
            if err != nil {
                os_log("error in putting data, response code below", log: OSLog.default, type: .debug)
                if let httpResponse = response as? HTTPURLResponse {
//                    print(httpResponse.statusCode)
                }
            } else {
                completion()
            }
        })
        task.resume()
    }

}
