//
//  ViewController.swift
//  Meme Me 1.0
//
//  Created by Erich Clark on 3/19/18.
//  Copyright © 2018 Erich Clark. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
    UITextFieldDelegate
{
    
    // MARK: Outlets
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var galleryButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var topMemeTextField: UITextField!
    @IBOutlet weak var bottomMemeTextField: UITextField!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var imageSourceToolbar: UIToolbar!
    @IBOutlet weak var sharingToolbar: UIToolbar!
    
    struct Meme {
        var topText: String
        var bottomText: String
        var originalImage: UIImage
        var memedImage: UIImage?
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.topMemeTextField.delegate = self
        self.topMemeTextField.textColor = UIColor.white
        topMemeTextField.defaultTextAttributes = memeTextAttributes
        topMemeTextField.textAlignment = .center
        
        self.bottomMemeTextField.delegate = self
        self.bottomMemeTextField.textColor = UIColor.white
        bottomMemeTextField.defaultTextAttributes = memeTextAttributes
        bottomMemeTextField.textAlignment = .center
    }

    // MARK: ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
        print("Native bounds w\(UIScreen.main.nativeBounds.width) h\(UIScreen.main.nativeBounds.height)")
    }
    
    // MARK: ViewWill Dissapear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: Actions
    // Image Pickers and ImagePickerControllers
    @IBAction func requestImageFromAlbums(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func requestImageFromCamera (_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Default meme text formatting
    let memeTextAttributes:[String: Any] = [
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
        NSAttributedStringKey.font.rawValue: UIFont(name: "impact", size: 55)!,
        NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
        NSAttributedStringKey.strokeWidth.rawValue: -6.0]
    
    // MARK: Keyboard show / hide / subscribe
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
            view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
            view.frame.origin.y += getKeyboardHeight(notification)
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func requestShare(){
        if imagePickerView.image == nil {
            print("Image View is empty.")
        } else {
            let meme = generateMeme()
            saveImage(meme)
        }
    }
    
    // MARK: Save functions
    func saveImage(_ meme: Meme) {
        UIImageWriteToSavedPhotosAlbum(meme.memedImage!, nil, nil, nil)
    }
    
    
    func generateMeme() -> Meme {
        
        imageSourceToolbar.isHidden = true
        sharingToolbar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.imagePickerView.frame.size)
        view.drawHierarchy(in: self.imagePickerView.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        imageSourceToolbar.isHidden = false
        sharingToolbar.isHidden = false
        
        let meme = Meme(topText: topMemeTextField.text!, bottomText: bottomMemeTextField.text!, originalImage: imagePickerView.image!, memedImage: memedImage)

        return meme
    }
    
    
}

