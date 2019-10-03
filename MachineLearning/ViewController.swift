//
//  ViewController.swift
//  MachineLearning
//
//  Created by Eric Cook on 11/11/17.
//  Copyright © 2017 Better Search, LLC. All rights reserved.
//

import UIKit
import CoreML
import Vision
import MessageUI

var photoPicked = UIImage()
var photoNumber = Int()
var pickerCategorySource = ["--Please select a Category--","Implants","Oral Pathology","Radiolucent Lesions"]


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate,  UIPickerViewDataSource, UIPickerViewDelegate {
    
    //var mlModel =  ImageClassifier() //ImplantModel()  //ImplantsCleaned()  //oralPath()  //DefaultCustomModel_312342192()  //Resnet50() //Food101() //Resnet50()  //VGG16() //GoogLeNetPlaces()
    
    
    @IBAction func retryButton(_ sender: Any) {
        
        getMachineLearningInfo()
    }
    
    @IBOutlet var categoryPicker: UIPickerView!
    
    var categoryPicked = ""
    
    var selectedImagePicked = UIImage()
    
    var iPathEmail = [String]()
    
    var iPathText = [String]()
    
    var implantType = String()
    
    var percentAccuracy = String()
    
    var emailSent = 0
    
    var textSent = 0
    
    @IBAction func contactButton(_ sender: Any) {
        
        let alert = UIAlertController(title: "Contact Us", message: "Email or Rate Us.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Email", style: .default, handler: { action in
            
            alert.dismiss(animated: true, completion: nil)
            
            self.sendEmailToBS()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Rate Us", style: .default, handler: { action in
            
            alert.dismiss(animated: true, completion: nil)
            
            self.rateUs()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
            
            alert.dismiss(animated: true, completion: nil)
            
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBOutlet var confidenceLabel: UILabel!
    
    @IBOutlet var descriptionLabel: UILabel!
    
    @IBOutlet var imageToPost: UIImageView!
    
    @IBOutlet var uploadButtonTitle: UIButton!
    
    @IBAction func uploadButton(_ sender: Any) {
        
        performSegue(withIdentifier: "viewToUpload", sender: self)
    }
    
    
    @IBOutlet var saveButtonTitle: UIButton!
    
    @IBAction func saveButton(_ sender: Any) {
        
        takeScreenshot(true)
        
    }
    
    @IBOutlet var sendButtonTitle: UIButton!
    
    @IBAction func sendButton(_ sender: Any) {
        
        let alert = UIAlertController(title: "Email or Text", message: "", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Email", style: .default, handler: { action in
            
            self.sendEmail()
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Text", style: .default, handler: { action in
            
            self.sendText()
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func camera(_ sender: Any) {
        
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerController.SourceType.camera
        image.allowsEditing = false
        
        present(image, animated: true, completion: nil)
        
    }
    
    @IBAction func pickPhoto(_ sender: Any) {
        
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        image.allowsEditing = false
        
        present(image, animated: true, completion: nil)
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerCategorySource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return pickerCategorySource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let label = UILabel()
        
        label.font = UIFont(name: "Times New Roman", size: 16.0)
        label.textAlignment = .center
        label.text = pickerCategorySource[row]
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.categoryPicked = pickerCategorySource[row]
        print(pickerCategorySource[row])
        //pickedName.text = pickerCategorySource[row]
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        if let selectedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            
            print("")
            print("************************************************************")
            print("Image selected")
            print("************************************************************")
            print("")
            
            imageToPost.image = selectedImage
            selectedImagePicked = selectedImage
            photoPicked = selectedImage
            photoNumber = 1
            
            picker.dismiss(animated: true, completion: nil)
            
            
        }
        
        if selectedImagePicked != UIImage(named: "Icon-1024.png")! {
            
            getMachineLearningInfo()
            
        }
        
    }
    
    func getMachineLearningInfo() {
        
        self.implantType = ""
        
        self.percentAccuracy = ""
        
        
        switch categoryPicked {
        
        case "Implants":
            
            let mlModel = ImageClassifier()
            
            let model = try? VNCoreMLModel(for: mlModel.model)
            
            let request = VNCoreMLRequest(model: model!, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
                
            })
            request.imageCropAndScaleOption = .centerCrop
            
            if let imageData = (self.selectedImagePicked).pngData() {
                let handler = VNImageRequestHandler(data: imageData, options: [:])
                try? handler.perform([request])
            }
        
        case "Oral Pathology":
            
            let mlModel = Oral_Pathology()
            
            let model = try? VNCoreMLModel(for: mlModel.model)
            
            let request = VNCoreMLRequest(model: model!, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
                
            })
            request.imageCropAndScaleOption = .centerCrop
            
            if let imageData = (self.selectedImagePicked).pngData() {
                let handler = VNImageRequestHandler(data: imageData, options: [:])
                try? handler.perform([request])
            }
        
        case "Radiolucent Lesions":
            
            let mlModel = RadiolucentLesions()
            
            let model = try? VNCoreMLModel(for: mlModel.model)
            
            let request = VNCoreMLRequest(model: model!, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
                
            })
            request.imageCropAndScaleOption = .centerCrop
            
            if let imageData = (self.selectedImagePicked).pngData() {
                let handler = VNImageRequestHandler(data: imageData, options: [:])
                try? handler.perform([request])
            }
            
        case "--Please select a Category--":
            
            let alert = UIAlertController(title: "Please select a Category.", message: "", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: { action in
                
                alert.dismiss(animated: true, completion: nil)
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        
        default:
            
            print("Some other category was picked.")
            
        }
        
        /*if (categoryPicked == "Implants") {
            
            let mlModel = ImageClassifier()
            
            let model = try? VNCoreMLModel(for: mlModel.model)
            
            let request = VNCoreMLRequest(model: model!, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
                
            })
            request.imageCropAndScaleOption = .centerCrop
            
            if let imageData = (self.selectedImagePicked).pngData() {
                let handler = VNImageRequestHandler(data: imageData, options: [:])
                try? handler.perform([request])
            }
            
        } else {
            
            let mlModel = OralPathology()
            
            let model = try? VNCoreMLModel(for: mlModel.model)
            
            let request = VNCoreMLRequest(model: model!, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
                
            })
            request.imageCropAndScaleOption = .centerCrop
            
            if let imageData = (self.selectedImagePicked).pngData() {
                let handler = VNImageRequestHandler(data: imageData, options: [:])
                try? handler.perform([request])
            }
            
        }*/
        
        self.saveButtonTitle.isEnabled = true
        
        saveButtonTitle.tintColor = UIColor.blue.withAlphaComponent(0.6)
        
        self.sendButtonTitle.isEnabled = true
        
        sendButtonTitle.tintColor = UIColor.blue.withAlphaComponent(0.6)
        
        return
        
        
        /*if let model = try? VNCoreMLModel(for: self.mlModel.model) {
            
            let request = VNCoreMLRequest(model: model, completionHandler: { (request, error) in
              
                if let results = request.results as? [VNClassificationObservation] {
                   for classification in results {
                        let firstResult = results.first
                        if firstResult != nil {
                            print("ID: \(classification.identifier) Confidence: \(classification.confidence)")
                            let percent = firstResult!.confidence * 100
                            self.descriptionLabel.text = firstResult!.identifier.capitalized
                            self.confidenceLabel.text = String(format: "%.2f", percent) + "%"
                        }
                        
                    }
                    
                }
            })
            
            if let imageData = UIImagePNGRepresentation(selectedImagePicked) {
                let handler = VNImageRequestHandler(data: imageData, options: [:])
                try? handler.perform([request])
            }
        }*/
    }
    
    /*func processQuery(for request: VNRequest, error: Error?, k: Int = 5) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                self.descriptionLabel.text = "Unable to classify image.\n\(error!.localizedDescription)"
                return
            }
            
            let queryResults = results as! [VNCoreMLFeatureValueObservation]
            let distances = queryResults.first!.featureValue.multiArrayValue!
            
            // Create an array of distances to sort
            let numReferenceImages = distances.shape[0].intValue
            var distanceArray = [Double]()
            for r in 0..<numReferenceImages {
                distanceArray.append(Double(truncating: distances[r]))
            }
            
            let sorted = distanceArray.enumerated().sorted(by: {$0.element < $1.element})
            let knn = sorted[..<min(k, numReferenceImages)]
            
            self.descriptionLabel.text = String(describing: knn)
            self.confidenceLabel.text = String(describing: sorted)
        }
    }*/
    
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard request.results != nil else {
                self.descriptionLabel.text = "Unable to classify image.\n\(error!.localizedDescription)"
                return
            }
            // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
            if let results = request.results as? [VNClassificationObservation] {
                for classification in results {
                    let firstResult = results.first
                    let secondResult = results[1]
                    let thirdResult = results[2]
                    if firstResult != nil {
                        
                        print("ID: \(classification.identifier) Confidence: \(classification.confidence)")
                        let percent = Int((firstResult!.confidence * 100.0).rounded())
                        let percent2 = Int((results[1].confidence * 100.0).rounded())
                        let percent3 = Int((results[2].confidence * 100.0).rounded())
                        if percent <= 20 {
                            
                            self.descriptionLabel.text = "We could not analyize this picture."
                            self.implantType = self.descriptionLabel.text!
                            self.confidenceLabel.text = "Please try again!"
                            self.percentAccuracy = self.confidenceLabel.text!
                            
                        } else {
                            
                            self.descriptionLabel.text = firstResult!.identifier.capitalized + " - \(percent)%"
                            self.implantType = firstResult!.identifier.capitalized
                            self.confidenceLabel.text = secondResult.identifier.capitalized + " - \(percent2)%\r" + thirdResult.identifier.capitalized + " - \(percent3)%"
                            self.percentAccuracy = "\(percent)%"
                            
                        }
                        
                    }
                    
                }
                
                self.saveImageDocumentDirectory()
                
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: true)  //isNavigationBarHidden = false
        
        descriptionLabel.text = "Please pick a category and take or pick a photo to be analyzed!"
        
        confidenceLabel.text = ""
        
        imageToPost.image = UIImage(named: "Icon-1024.png")
        
        selectedImagePicked = UIImage(named: "Icon-1024.png")!
        
        self.saveButtonTitle.isEnabled = false
        
        saveButtonTitle.tintColor = UIColor.blue.withAlphaComponent(0.0)
        
        self.sendButtonTitle.isEnabled = false
        
        sendButtonTitle.tintColor = UIColor.blue.withAlphaComponent(0.0)
        
        self.categoryPicker.dataSource = self
        
        self.categoryPicker.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if  photoNumber != 0  {
            
            noInternetConnection()
            
            imageToPost.image = photoPicked
            
            getMachineLearningInfo()
            
        } else {
            
            
            noInternetConnection()
        }
        
        
    }
    
    func noInternetConnection() {
        
        if Reachability.isConnectedToNetwork() == true {
            
            print("Internet connection OK")
            
            //authenticate()
            
        } else {
            
            print("Internet connection FAILED")
            
            let alert = UIAlertController(title: "Sorry, no internet connection found.", message: "Thia app requires an internet connection.", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Try Again?", style: .default, handler: { action in
                
                alert.dismiss(animated: true, completion: nil)
                
                self.noInternetConnection()
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
            
        }
        
    }

    
    func takeScreenshot(_ shouldSave: Bool) -> UIImage? {
        
        if shouldSave == true {
            
            var screenshotImage :UIImage?
            
            let layer = UIApplication.shared.keyWindow!.layer
            
            let scale = UIScreen.main.scale
            
            UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
            
            guard let context = UIGraphicsGetCurrentContext() else {return nil}
            
            layer.render(in:context)
            
            screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            if let image = screenshotImage, shouldSave {
                
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                
                savedToPhotoAlbumComplete()
                
            }
            
            return screenshotImage
            
        } else {
            
            self.saveButtonTitle.isEnabled = false
            
            saveButtonTitle.tintColor = UIColor.blue.withAlphaComponent(0.0)
            
            self.sendButtonTitle.isEnabled = false
            
            sendButtonTitle.tintColor = UIColor.blue.withAlphaComponent(0.0)
            
            return nil
        }
        
    }
    
    func savedToPhotoAlbumComplete() {
        
        let alert = UIAlertController(title: "Your photo has been saved to your Photos.", message: "", preferredStyle: UIAlertController.Style.alert)
        
        
        alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: { action in
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveImageDocumentDirectory(){
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("implant.jpg")
        let image = selectedImagePicked  //UIImage(named: "implant.jpg")
        print("implant.jpg saved to: " + paths)
        let imageData = image.jpegData(compressionQuality: 0.5)
        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
    }
    
    func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getImage(){
        let fileManager = FileManager.default
        let imagePAth = (getDirectoryPath() as NSString).appendingPathComponent("implant.jpg")
        if fileManager.fileExists(atPath: imagePAth){
            self.imageToPost.image = UIImage(contentsOfFile: imagePAth)
        }else{
            print("No Image")
        }
    }
    
    func sendText() {
        
        let messageVC = MFMessageComposeViewController()
        
        messageVC.subject = "Your Dental ML guess is " + self.implantType
        
        messageVC.body =  "Your Dental ML guess is " + self.implantType + " with a " + percentAccuracy + " accuracy. Other possibilities are " + self.confidenceLabel.text!
        
        getImage()
        
        let attachment = (getDirectoryPath() as NSString).appendingPathComponent("implant.jpg")
        
        if let fileData = NSData(contentsOfFile: attachment) {
            
            print("File data loaded.")
            
            messageVC.addAttachmentData(fileData as Data, typeIdentifier: "image/jpeg", filename: "implant.jpg")
        }
        
        
        messageVC.recipients = iPathText
        
        messageVC.messageComposeDelegate = self;
        
        self.present(messageVC, animated: false, completion: nil)
        
    }
    
    func sendEmail() {
        
        let toRecipents = iPathEmail
        
        print(toRecipents)
        
        let mc: MFMailComposeViewController = MFMailComposeViewController()
        
        mc.mailComposeDelegate = self
        
        mc.setSubject("Your Dental ML guess is " + self.implantType)
        
        mc.setMessageBody("Your Dental ML guess is " + self.implantType + " with a " + percentAccuracy + " accuracy. Other possibilities are " + self.confidenceLabel.text!, isHTML: true)
        
        getImage()
        
        let attachment = (getDirectoryPath() as NSString).appendingPathComponent("implant.jpg")
        
        if let fileData = NSData(contentsOfFile: attachment) {
        
            print("File data loaded.")
            
            mc.addAttachmentData(fileData as Data, mimeType: "image/jpeg", fileName: "implant.jpg")
        }
        
        mc.setToRecipients(toRecipents)
        
        self.present(mc, animated: true, completion: nil)
        
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result.rawValue) {
        case MessageComposeResult.cancelled.rawValue:
            print("Message was cancelled")
            
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.failed.rawValue:
            print("Message failed")
            
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.sent.rawValue:
            print("Message was sent")
            textSent = 1
            self.dismiss(animated: true, completion: nil)
        default:
            break;
        }
        
        textSentSuccess()
    }
    
    
    func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith result:MFMailComposeResult, error:Error?) {
        
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            print("Mail cancelled")
            
        case MFMailComposeResult.saved.rawValue:
            print("Mail saved")
            
        case MFMailComposeResult.sent.rawValue:
            print("Mail sent")
            emailSent = 1
        case MFMailComposeResult.failed.rawValue:
            print("Mail sent failure: \(error!.localizedDescription)")
            
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
        emailSentSuccess()
    }
    
    func emailSentSuccess() {
        
        if emailSent == 0 {
            
            let alert = UIAlertController(title: "Your email failed to send or was cancelled.", message: "", preferredStyle: UIAlertController.Style.alert)
            
            
            alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: { action in
                
                alert.dismiss(animated: true, completion: nil)
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            
            let alert = UIAlertController(title: "Your email has been sent.", message: "", preferredStyle: UIAlertController.Style.alert)
            
            
            alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: { action in
                
                alert.dismiss(animated: true, completion: nil)
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
            emailSent = 0
        }
        
        
    }
    
    func textSentSuccess() {
        
        if textSent == 0 {
            
            let alert = UIAlertController(title: "Your text failed to send or was cancelled.", message: "", preferredStyle: UIAlertController.Style.alert)
            
            
            alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: { action in
                
                alert.dismiss(animated: true, completion: nil)
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            
            let alert = UIAlertController(title: "Your text has been sent.", message: "", preferredStyle: UIAlertController.Style.alert)
            
            
            alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: { action in
                
                alert.dismiss(animated: true, completion: nil)
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
            textSent = 0
            
        }
        
        
    }
    
    
    func rateUs() {
        
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id1462375241") {
            UIApplication.shared.open(url, options: [:])
        }
        
    }
    
    func sendEmailToBS() {
        
        let toRecipents = ["dentalml@bettersearchllc.com"]
        
        let mc: MFMailComposeViewController = MFMailComposeViewController()
        
        mc.mailComposeDelegate = self
        
        mc.setToRecipients(toRecipents)
        
        self.present(mc, animated: true, completion: nil)
        
    }
    
    

}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}



