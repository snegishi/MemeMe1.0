//
//  EditorViewController.swift
//  MemeMe
//
//  Created by Shin Negishi on 12/1/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

class EditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // MARK: Properties
    
    struct Meme {
        var topText: String
        var bottomText: String
        var originalImage: UIImage!
        var memedImage: UIImage!
    }
    
    var meme: Meme?
    var memedImage: UIImage?
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: -3.0
    ]
    
    // MARK: IBOutlets
    
    @IBOutlet weak var naviBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    // MARK: Configuration for TextField
    
    func configure(textField: UITextField) {
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.isHidden = true
    }
    
    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure(textField: topTextField)
        configure(textField: bottomTextField)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        subscribeToHideKeyboardNotifications()
        shareButton.isEnabled = false
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotifications()
        unsubscribeToHideKeyboardNotifications()
    }
    
    // MARK: Text Field Operations
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == topTextField {
            topTextField.text = ""
        }
        
        if textField == bottomTextField {
            bottomTextField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // MARK: Keyboard Functions
    
    // TODO limit the funciton to move the keyboard position only when editing the bottom text
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if bottomTextField.isEditing {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    func subscribeToHideKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToHideKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    // MARK: Image Operations
    
    func presentImagePickerWith(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        presentImagePickerWith(sourceType: .photoLibrary)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        topTextField.isHidden = false
        bottomTextField.isHidden = false
        
        picker.dismiss(animated: true, completion: nil)
        shareButton.isEnabled = true

        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.image = image
        }
    }
    
    @IBAction func takeAnImageByCamera(_ sender: Any) {
        presentImagePickerWith(sourceType: .camera)
    }
    
    // MARK: Activities
    
    @IBAction func shareImage() {
        memedImage = generateMemedImage()
        
        let activityViewController = UIActivityViewController(activityItems: [memedImage!], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed:
        Bool, arrayReturnedItems: [Any]?, error: Error?) in
            if completed {
                self.save()
                print("share completed")
                return
            } else {
                print("cancel")
            }
            if let shareError = error {
                print("error while sharing: \(shareError.localizedDescription)")
            }
        }
        present(activityViewController, animated: true, completion: nil)
    }
 
    func save() {
        meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
    }
    
    func hideTopAndBottomBars(_ hide: Bool) {
        naviBar.isHidden = hide
        toolBar.isHidden = hide
    }
    
    func generateMemedImage() -> UIImage {
        
        // Hide toolbar and navbar
        hideTopAndBottomBars(true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        hideTopAndBottomBars(false)
        
        return memedImage
    }
    
    @IBAction func cancelView() {
        
        // delete the image
        meme = nil
        memedImage = nil
        imagePickerView.image = nil

        shareButton.isEnabled = false

        // Hide textfields
        topTextField.isHidden = true
        bottomTextField.isHidden = true
    }
}

