//
//  LoginViewController.swift
//  keepTrackOfThings
//
//  Created by Xiaolan Zhou on 11/18/17.
//  Copyright © 2017 Richard Liu. All rights reserved.
//

import UIKit
import os.log

class LoginViewController: UIViewController, UINavigationControllerDelegate {

    // MARK: Properties
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var userpswd: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        os_log("navigating from login view back to item table view", log: OSLog.default, type: .debug)
        
        // send back to item table vc only when done button was pressed
        guard let button = sender as? UIBarButtonItem, button === doneButton else {
            os_log("The done button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
    }
    
    // alert user and stop segue if userpswd is empty or user doesn't exist
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "unwindLogin" {
            userpswd = (usernameTextField.text ?? "") + "_" + (passwordTextField.text ?? "")
            print(userpswd)
            
            if userpswd == "" {
                os_log("password is empty, alerting the user", log: OSLog.default, type: .debug)
                let myAlert = UIAlertController(title: "Please enter something", message: "Please enter a username and password", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                
                myAlert.addAction(okAction)
                
                self.present(myAlert, animated: true, completion: nil)
                
                return false
            } else {
                // check that user exists (base64 encode userpswd)
                get(withItem: userpswd.data(using: String.Encoding.utf8)!.base64EncodedString(), withCompletion: { (string: String?) in
                    if let str = string {
                        if str == "null" {
                            os_log("user or password is incorrect, alerting the user", log: OSLog.default, type: .debug)
                            let myAlert = UIAlertController(title: "Wrong password", message: "Incorrect username or password!", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            
                            myAlert.addAction(okAction)
                            
                            self.present(myAlert, animated: true, completion: nil)
                        } else {
                            self.performSegue(withIdentifier: "unwindLogin", sender: self.doneButton)
                        }
                    } else {
                        // failed to connect to internet
                        os_log("no internet connection", log: OSLog.default, type: .debug)
                        let myAlert = UIAlertController(title: "No internet connection", message: "Internet connection is required to sign up", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        myAlert.addAction(okAction)
                        self.present(myAlert, animated: true, completion: nil)
                    }
                })
                // don't perform segue for now, may perform segue in get() completion
                return false
            }
        } else {
            return true
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: Firebase
    let baseUrl: String = "https://keeptrackofthings-1a133.firebaseio.com/"
    
    // returns the bool that completion returns
    func get(withItem item: String, withCompletion completion: @escaping (String?) -> Void) {
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
            
            completion(String(data: data, encoding: String.Encoding.utf8))
        })
        task.resume()
    }

}
