//
//  ItemViewController.swift
//  ??
//
//  Created by Xiaolan Zhou on 10/27/17.
//  Copyright © 2017 Richard Liu. All rights reserved.
//

import UIKit
import os.log

class ItemViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var item: Item?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        nameTextField.delegate = self;
        
        // if editing existing item
        if let item = item {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            let dateString = formatter.string(from: item.time)
            
            navigationItem.title = item.name
            nameTextField.text = item.name
            photoImageView.image = item.photo
            descTextView.text = item.desc
            timeLabel.text = dateString
        }
        
        updateSaveButtonState()
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = nameTextField.text
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // disable save while user is editing
        saveButton.isEnabled = false
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        photoImageView.image = selectedImage
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        let isPresentingInAddItemMode = presentingViewController is UINavigationController
        
        if isPresentingInAddItemMode {
            dismiss(animated: true, completion: nil)
        } else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        } else {
            fatalError("The ItemViewController is not inside a navigation controller.")
        }
    }
    
    // configure new view controller before it's presented
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        os_log("unwinding back to table view", log: OSLog.default, type: .debug)
        
        // configure destination view controller only when save button was pressed
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let name = nameTextField.text ?? ""
        let photo = photoImageView.image
        let desc = descTextView.text
        let time = Date()
        item = Item(name: name, photo: photo, desc: desc, time: time)
    }
    
    // MARK: Actions
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        nameTextField.resignFirstResponder()
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.sourceType = .photoLibrary
        
        present(imagePickerController, animated: true, completion: nil)
        imagePickerController.delegate = self

    }
    
    // MARK: Private methods
    private func updateSaveButtonState() {
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
}

