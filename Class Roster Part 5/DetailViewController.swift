//
//  DetailViewController.swift
//  Class Roster Part 5
//
//  Created by Jeff Chavez on 8/23/14.
//  Copyright (c) 2014 Jeff Chavez. All rights reserved.
//
/* Questions:
    - Why can't I put a function inside of handler: instead of a closure?
    - How come in alertTextField = textField I don't need .text parameters?
    - How do I save from within DetailViewController? Currently the only way to save is to go back to ViewController because viewWillAppear is being called which has NSKeyedArchiver inside of it
*/

import UIKit

class DetailViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate {
    
    var selectedPerson : Person?
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var gitHubUserNameTextField: UITextField!
    @IBOutlet weak var gitHubPhotoImageView: UIImageView!
    @IBOutlet weak var gitHubActivityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        decideToDisplayPlaceholderImages()
        applyImageViewStyles()
    }

    override func viewWillAppear(animated: Bool) {
        fillInTextFields()
        decideTextForTitleBar()
    }

    override func viewWillDisappear(animated: Bool) {
        self.selectedPerson?.firstName = firstNameTextField.text
        self.selectedPerson?.lastName = lastNameTextField.text
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        self.view.endEditing(true)
    }

    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    //MARK: UIImagePickerController Delegate
    @IBAction func choosePhotoIsPressed (sender: AnyObject) {
        var choosePhoto = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        choosePhoto.addAction(UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) == true {
                var imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                imagePickerController.allowsEditing = true
                imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
                self.presentViewController(imagePickerController, animated: true, completion: nil)
            }
            else {
                var alert = UIAlertView()
                alert.title = "No Device"
                alert.message = "Your device does not have the proper camera"
                alert.addButtonWithTitle("OK")
                alert.show()
            }
        })
        choosePhoto.addAction(UIAlertAction(title: "Choose Existing", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            var imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = true
            imagePickerController.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            self.presentViewController(imagePickerController, animated: true, completion: nil)
        })
        if self.selectedPerson?.photo != nil {
            choosePhoto.addAction(UIAlertAction(title: "Delete Photo", style: UIAlertActionStyle.Destructive) { (UIAlertAction) -> Void in
                self.photoImageView.image = UIImage (named: "placeholder.jpg")
                self.selectedPerson!.photo  = nil
            })
        }
        choosePhoto.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:nil))
        self.presentViewController(choosePhoto, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        var editedImage = info[UIImagePickerControllerEditedImage] as UIImage
        self.photoImageView.image = editedImage
        self.selectedPerson!.photo = editedImage
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Enter GitHub Username
    @IBAction func grabGitButton (sender:AnyObject) {
        var alertTextField : UITextField = UITextField()
        var enterGitHubInfo = UIAlertController(title: "Grab Info", message: "What is the peron's GitHub Username?", preferredStyle: UIAlertControllerStyle.Alert)
        enterGitHubInfo.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Username"
            alertTextField = textField
        })
        enterGitHubInfo.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:nil))
        enterGitHubInfo.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            self.gitHubUserNameTextField.text = alertTextField.text
            self.selectedPerson!.gitHubUserName = alertTextField.text
            self.getGitHubProfilePhoto(alertTextField.text)
        })
        self.presentViewController(enterGitHubInfo, animated: true, completion: nil)
    }
    
    var imageDownloadQueue = NSOperationQueue()
    func getGitHubProfilePhoto (searchUsername: String) -> Void {
        self.gitHubActivityIndicator.startAnimating()
        let gitHubURL = NSURL (string: "https://api.github.com/users/\(searchUsername)")
        var profilePhotoURL = NSURL()
        self.imageDownloadQueue.addOperationWithBlock { () -> Void in
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithURL(gitHubURL, completionHandler: { (data, response, error) -> Void in
                if error != nil {
                    println("error1")
                }
                var err: NSError?
                var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
                if err != nil {
                    println("error2")
                }
                if let avatarURL = jsonResult["avatar_url"] as? String {
                    profilePhotoURL = NSURL(string: avatarURL)
                }
                var profilePhotoData = NSData(contentsOfURL: profilePhotoURL)
                var profilePhotoImage = UIImage (data: profilePhotoData)
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.gitHubPhotoImageView.image = profilePhotoImage
                    self.selectedPerson!.gitHubPhoto = profilePhotoImage
                    self.gitHubActivityIndicator.stopAnimating()
                    if self.gitHubPhotoImageView.image == nil {
                        self.gitHubPhotoImageView.image = UIImage (named: "gitHubDefault")
                        self.gitHubUserNameTextField.text = nil
                        var alert = UIAlertView()
                        alert.title = "Invalid Username"
                        alert.message = "Please enter a valid GitHub Username"
                        alert.addButtonWithTitle("OK")
                        alert.show()
                    }
                })
            })
            task.resume()
        }
    }
    //MARK: Misc Functions
    func decideToDisplayPlaceholderImages() {
        if self.selectedPerson?.photo != nil {
            self.photoImageView.image = self.selectedPerson?.photo
        }
        else {
            self.photoImageView.image = UIImage (named: "placeholder.jpg")
        }
        if self.selectedPerson?.gitHubPhoto != nil {
            self.gitHubPhotoImageView.image = self.selectedPerson?.gitHubPhoto
        }
        else {
            self.gitHubPhotoImageView.image = UIImage (named: "gitHubDefault")
        }
    }
    
    func applyImageViewStyles() {
        self.photoImageView.layer.cornerRadius = 100.0
        self.photoImageView.layer.masksToBounds = true
        self.photoImageView.layer.borderWidth = 0.5
        
        self.gitHubPhotoImageView.layer.cornerRadius = 3
        self.gitHubPhotoImageView.layer.masksToBounds = true
        self.gitHubPhotoImageView.layer.borderWidth = 0.5
    }
    
    func decideTextForTitleBar() {
        if firstNameTextField.text == "" && lastNameTextField.text == "" {
            self.title = "Add New Person"
        }
        else {
            self.title = "\(selectedPerson!.fullName())"
        }
    }
    
    func fillInTextFields() {
        firstNameTextField.text = selectedPerson?.firstName
        lastNameTextField.text = selectedPerson?.lastName
        gitHubUserNameTextField.text = selectedPerson?.gitHubUserName
    }
}