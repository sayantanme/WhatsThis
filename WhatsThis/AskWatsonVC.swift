//
//  ViewController.swift
//  WhatsThis
//
//  Created by Sayantan Chakraborty on 11/05/17.
//  Copyright © 2017 Sayantan Chakraborty. All rights reserved.
//

import UIKit
import MobileCoreServices
import VisualRecognitionV3
import FirebaseAuth
import FirebaseStorage
import Photos

private let reuseIdentifier = "classificationsViewCell"
class AskWatsonVC: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionViewClassifications: UICollectionView!
    @IBOutlet weak var imgViewSelected: UIImageView!
    let picker = UIImagePickerController()
    var uploadedFileUrl: String? = nil
    var uploadedPhoto: UIImage? = nil
    var classificationResults = [Classification]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //doVisualRecog()
        //collectionViewClassifications.collectionViewLayout
    }
    
    @IBAction func btnTakePic(_ sender: UIButton) {
        let mediaPicker = UIImagePickerController();
        mediaPicker.delegate = self
        mediaPicker.allowsEditing = true
        mediaPicker.sourceType = .camera
        mediaPicker.cameraCaptureMode = .photo
        self.present(mediaPicker, animated: true, completion: nil)
    }
    
    @IBAction func btnChooseImage(_ sender: UIButton) {
        let mediaPicker = UIImagePickerController();
        mediaPicker.delegate = self
        mediaPicker.allowsEditing = true
        mediaPicker.sourceType = .photoLibrary
        self.present(mediaPicker, animated: true, completion: nil)
    }
    
    //MARK: - Utility Methods
    
    @IBAction func btnWatson(_ sender: UIBarButtonItem) {
        let recog = VisualRecog()
        DispatchQueue.global(qos: .userInitiated).async {
            recog.getImageDetailsbyClassifiers(url: self.uploadedFileUrl!, image: self.uploadedPhoto!){classifiedResults in
                //print(classifiedResults.count)
                DispatchQueue.main.async {
                    self.classificationResults = (classifiedResults.first?.classes)!
                    self.collectionViewClassifications.reloadData()
                }
            }
        }
    }
    fileprivate func uploadMedia(photo: UIImage?,imageName: String){
        if let photo = photo{
            let uploadFirbasepath = "\(imageName)/\(NSDate.timeIntervalSinceReferenceDate)"
            let data = UIImageJPEGRepresentation(photo, 0.1)
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpg"
            FIRStorage.storage().reference().child("watson-images").child(uploadFirbasepath).put(data!, metadata: metadata) { (downMeta, error:Error?) in
                guard error == nil else{
                    print(error?.localizedDescription ?? "no error desc")
                    return
                }
                if let fileUrl = downMeta?.downloadURLs?[0].absoluteString {
                    self.uploadedFileUrl = fileUrl
                    self.uploadedPhoto = photo
                    DispatchQueue.main.async {
                        self.imgViewSelected.loadImageFromImageUrlFromCache(url: fileUrl)
                    }
                }
                
            }
            
        }
    }
    
//    fileprivate func setupLabelsWithClassifiers(classResults: [Classification]){
//        print(classResults.count)
//        DispatchQueue.main.async {
//            self.noTags = classResults.count
//            for classes in classResults{
//                let detectedText = classes.classification
//                let label = UILabel(frame: CGRect(x: 10, y: 0, width: self.imgViewSelected.frame.width-10, height: 30))
//                label.textColor = UIColor.black
//                label.text = detectedText
//                self.imgViewSelected.addSubview(label)
//            }
//        }
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return classificationResults.count
        //return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ClassificationsViewCell
        let classifications = classificationResults[indexPath.row]
        //        cell.imageSelected.isHidden = true
        cell.txtClassification.text = classifications.classification
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size: CGSize = classificationResults[indexPath.row].classification.size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)])
        
        return CGSize(width: size.width + 45 , height: collectionViewClassifications.bounds.size.height)
    }
}

extension AskWatsonVC: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImagePicker:UIImage?
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImagePicker = editedImage
        }else if let origImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            selectedImagePicker = origImage
        }
        
        if let imageUrl = info[UIImagePickerControllerReferenceURL] as? URL {
            let result = PHAsset.fetchAssets(withALAssetURLs: [imageUrl], options: nil)
            let asset = result.firstObject
            uploadMedia(photo: selectedImagePicker, imageName: asset?.value(forKey: "filename") as! String)
            print(asset?.value(forKey: "filename") ?? "")
        }else{
            uploadMedia(photo: selectedImagePicker, imageName: "WatsonPic")
        }
        
        
        print(selectedImagePicker?.description ?? "No Image")
        self.dismiss(animated: true, completion: nil)
    }
}

