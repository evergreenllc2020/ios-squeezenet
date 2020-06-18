//
//  ViewController.swift
//  Object Detection
//
//  Created by Evergreen Technologies on 6/7/20.
//  Copyright © 2020 Evergreen Technologies. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var userPickedImageView: UIImageView!
    @IBOutlet weak var classifyingLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if isCameraAvailable()
        {
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imagePicker.dismiss(animated: true, completion: nil)
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            let orientation = CGImagePropertyOrientation(userPickedImage.imageOrientation)
            print("before setting image")
            self.userPickedImageView.image = userPickedImage
            print("after setting image")
            guard let ciImage = CIImage(image: userPickedImage) else { fatalError(" Failed to convert image to CIImage")}
            detect(image: ciImage, orientation : orientation)
            
        }
        
        
        
    }
    
    func detect(image : CIImage, orientation: CGImagePropertyOrientation)
    {
        //instantiate model
        guard let model = try? VNCoreMLModel(for: SqueezeNet().model) else { fatalError("Failed to instantiate squeezenet ml model") }
        
        //create request
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            
            guard let classifications = request.results as? [VNClassificationObservation] else {fatalError("Failed to classfications")}
            
            DispatchQueue.main.async {
                if classifications.isEmpty
                {
                    self.classifyingLabel.text = "Nothing recognized"
                }
                else
                {
                    let topClasssifications = classifications.prefix(2)
                    let descriptions = topClasssifications.map {classification in
                        return String(format: " (%.2f) %@", classification.confidence, classification.identifier)
                    }
                    self.classifyingLabel.text = "Classification:\n" + descriptions.joined(separator: "\n")
                    
                }
                
                
                
                
            }
            
            
            
            
            
        }
        
        
        
        //call request
       
        let handler = VNImageRequestHandler(ciImage: image, orientation: orientation)
            
        do
        {
            try handler.perform([request])
        }
        catch{
            print("there was error while running inference. \(error.localizedDescription) ")
        }
            
       
        
        
    
        
    }
    


    @IBAction func cameraClicked(_ sender: UIBarButtonItem) {
        
     if !isCameraAvailable()
     {
          presentPhotoPicker(sourceType: .photoLibrary)
          return
      }
      let photoSourcePicker = UIAlertController()
      photoSourcePicker.popoverPresentationController?.sourceView = self.view
        photoSourcePicker.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
      let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { [unowned self] _ in
          self.presentPhotoPicker(sourceType: .camera)
      }
      let choosePhoto = UIAlertAction(title: "Choose Photo", style: .default) { [unowned self] _ in
          self.presentPhotoPicker(sourceType: .photoLibrary)
      }
      
      photoSourcePicker.addAction(takePhoto)
      photoSourcePicker.addAction(choosePhoto)
      photoSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
      
      present(photoSourcePicker, animated: true)


        
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        print("inside presnt photo picker")
        
        
          // Do any additional setup after loading the view.
             if let popoverPresentationController = self.popoverPresentationController
             {
                 print("inside if ")
                 popoverPresentationController.sourceView = self.view
                 popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
             }
             
        
        imagePicker.sourceType = sourceType
        
        present(imagePicker, animated: true)
    }
    
    func isCameraAvailable() -> Bool {
        
        if(UIImagePickerController.isSourceTypeAvailable(.camera))
        {
            return true
        }
        else
        {
            let alertController = UIAlertController.init(title:nil, message: "Device has no camera", preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "alright", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return false
        }
        
        
    }
    
    
}

