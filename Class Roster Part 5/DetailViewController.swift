//
//  DetailViewController.swift
//  Class Roster Part 5
//
//  Created by Jeff Chavez on 8/23/14.
//  Copyright (c) 2014 Jeff Chavez. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var selectedPerson : Person?
    
    @IBOutlet weak var selectedPersonImage: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        if self.selectedPerson?.photo != nil {
            self.selectedPersonImage.image = self.selectedPerson?.photo
        }
        else {
            self.selectedPersonImage.image = UIImage (named: "placeholder.jpg")
        }
        self.selectedPersonImage.layer.cornerRadius = 100.0
        self.selectedPersonImage.layer.masksToBounds = true
        self.selectedPersonImage.layer.borderWidth = 1.0
    }
    
    override func viewDidAppear(animated: Bool) {
        firstNameTextField.text = selectedPerson?.firstName
        lastNameTextField.text = selectedPerson?.lastName
        self.title = "Person Details"
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.selectedPerson?.firstName = firstNameTextField.text
        self.selectedPerson?.lastName = lastNameTextField.text
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        self.view.endEditing(true)
    }
    
     //MARK: UIImagePickerController Delegate
    
    @IBAction func choosePhotoIsPressed(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) == true {
            var imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = true
            imagePickerController.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            self.presentViewController(imagePickerController, animated: true, completion: nil)
        }
        else {
            var alert = UIAlertView()
            alert.title = "No Device"
            alert.message = "Your device does not have the proper camera"
            alert.addButtonWithTitle("OK")
            alert.show()
        }
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        //gets fired when the image picker is done
        var editedImage = info[UIImagePickerControllerEditedImage] as UIImage
        self.selectedPersonImage.image = editedImage
        self.selectedPerson!.photo = editedImage
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}