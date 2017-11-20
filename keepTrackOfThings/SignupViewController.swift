//
//  SignupViewController.swift
//  keepTrackOfThings
//
//  Created by Xiaolan Zhou on 11/18/17.
//  Copyright © 2017 Richard Liu. All rights reserved.
//

import UIKit
import os.log

class SignupViewController: UIViewController, UINavigationControllerDelegate {

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
        os_log("navigating from sign up view back to item table view", log: OSLog.default, type: .debug)
        
        // send back to item table vc only when done button was pressed
        guard let button = sender as? UIBarButtonItem, button === doneButton else {
            os_log("The done button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
    }
    
    // alert user and stop segue if userpswd is empty
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "unwindSignup" {
            userpswd = (usernameTextField.text ?? "") + "_" + (passwordTextField.text ?? "")
            print(userpswd)
            
            if userpswd == "" || usernameTextField.text == nil || passwordTextField.text == nil {
                os_log("password is empty, alerting the user", log: OSLog.default, type: .debug)
                let myAlert = UIAlertController(title: "Please enter something", message: "Please enter a username and password", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                
                myAlert.addAction(okAction)
                
                self.present(myAlert, animated: true, completion: nil)
                
                return false
            } else {
                // check that user doesn't exist
                get(withItem: userpswd.data(using: String.Encoding.utf8)!.base64EncodedString(), withCompletion: { (string: String?) in
                    if let str = string {
                        if str == "null" {
                            os_log("creating a new user", log: OSLog.default, type: .debug)
                            
                            print("setting \(self.userpswd) to {\"placeholder\": 1}")
                            self.set(withItem: self.userpswd.data(using: String.Encoding.utf8)!.base64EncodedString(), withString: "{\"placeholder\": 1}", withCompletion: {() -> Void in })
                            self.performSegue(withIdentifier: "unwindSignup", sender: self.doneButton)
                        } else {
                            os_log("user exists, alerting the user", log: OSLog.default, type: .debug)
                            let myAlert = UIAlertController(title: "User exists!", message: "Please log in with your username and password", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            myAlert.addAction(okAction)
                            self.present(myAlert, animated: true, completion: nil)
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
                // don't perform segue for now, perform segue after get() completed
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

}
