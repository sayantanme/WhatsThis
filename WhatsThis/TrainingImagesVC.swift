//
//  TrainingImagesVC.swift
//  WhatsThis
//
//  Created by Sayantan Chakraborty on 19/05/17.
//  Copyright © 2017 Sayantan Chakraborty. All rights reserved.
//

import UIKit
import Photos
import Zip

private let reuseIdentifier = "trainingViewCell"

class TrainingImagesVC: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {


    @IBOutlet weak var previewImage: UIImageView!
    var previewImg: UIImage! {
        didSet {
            previewImage.image = previewImg
        }
    }
    
    @IBOutlet weak var trainingImagesCollectionView: UICollectionView!
    var imageAssets = [PHAsset]()
    fileprivate var thumbnailSize: CGSize!
    fileprivate var previewSize:CGSize!
    fileprivate let imageManager = PHCachingImageManager()
    var isGestureHappening = false
    var item = 0
    fileprivate var saveImagesPath: URL? = nil
    var indicator: UIActivityIndicatorView?
    var modalVCDelegate:ModalViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(gesture:)))
        trainingImagesCollectionView.addGestureRecognizer(longPressGesture)
        // Do any additional setup after loading the view.
        indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        indicator?.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        indicator?.center = view.center
        view.addSubview(indicator!)
        indicator?.bringSubview(toFront: view)
        print(imageAssets)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Determine the size of the thumbnails to request from the PHCachingImageManager
        let scale = UIScreen.main.scale
        let cellSize = (trainingImagesCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
        
        initialImageForImgView()
    }
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initialImageForImgView() {
        let asset = imageAssets[0]
        print("Width:\(asset.pixelWidth), Height:\(asset.pixelHeight)")
        let sizeToFit = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        imageManager.requestImage(for: asset, targetSize: sizeToFit, contentMode: .aspectFill, options: nil,resultHandler:  { image, _ in
            self.previewImg = image
        })
    }
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        indicator?.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async {
            self.createDirectory()
            self.saveImagesToFilePath()
            self.createZipFile()
            DispatchQueue.main.async {
                self.indicator?.stopAnimating()
                self.modalVCDelegate.returnValue(value: "After positive examples set")
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func createDirectory() {
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        saveImagesPath = documentsDir.appendingPathComponent("PositiveExamples")
        print(saveImagesPath?.absoluteString ?? "")
        
        do {
            if !FileManager.default.fileExists(atPath: (saveImagesPath?.absoluteString)!) {
                try FileManager.default.createDirectory(at: saveImagesPath!, withIntermediateDirectories: true, attributes: nil)
            }
        }catch let error as NSError {
            print("Error :\(error.localizedDescription)")
        }
    }
    
    func saveImagesToFilePath(){
        for asset in imageAssets {
            let localIdentifier = asset.localIdentifier.replacingOccurrences(of: "/", with: "_", options: .literal, range: nil)
            let savePathWithImageName = saveImagesPath?.appendingPathComponent("\(localIdentifier).png")
            var path = savePathWithImageName?.absoluteString
            let index = path?.index((path?.startIndex)!, offsetBy:6)
            path = path?.substring(from: index!)
            let suggestedImageSize = CGSize(width: 32, height: 32)
            imageManager.requestImage(for: asset, targetSize: suggestedImageSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
                let imageData = UIImagePNGRepresentation(image!)
                let isImageCreated = FileManager.default.createFile(atPath: path!, contents: imageData, attributes: nil)
                print("\(isImageCreated)")
            })
        }
    }
    
    func createZipFile(){
        do {
            let zipPath = try Zip.quickZipFiles([saveImagesPath!], fileName: "PositiveExamples")
            print(zipPath.absoluteString)
        }catch let error as NSError {
            print("Error:\(error.localizedDescription)")
        }
    }
    
    func handleLongPressGesture(gesture: UILongPressGestureRecognizer){
        
        switch gesture.state {
        case .began:
            guard let selectedIndexPath = trainingImagesCollectionView.indexPathForItem(at: gesture.location(in: trainingImagesCollectionView)) else {
                break
            }
            if !isGestureHappening{
                item = selectedIndexPath.item
            }
            isGestureHappening = true
            trainingImagesCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
            print("start path:\(selectedIndexPath)")
            break
        case .changed:
            trainingImagesCollectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view))
            
            break
        case .ended:
            print("end path:\(gesture.location(in: gesture.view))")
            isGestureHappening = false
            if gesture.location(in: gesture.view).y < 0 {
                let alert = UIAlertController(title: "Remove", message: "You want to remove the item", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action) in
                    print("ok pressed \(self.item)")
                    self.imageAssets.remove(at: self.item)
                    self.trainingImagesCollectionView.reloadData()
                    self.initialImageForImgView()
                }))
            self.present(alert, animated: true, completion: nil)
            }
            trainingImagesCollectionView.endInteractiveMovement()
            break
        default:
            trainingImagesCollectionView.cancelInteractiveMovement()
            break
        }
    }
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (imageAssets.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TrainingViewCell
        let asset = imageAssets[indexPath.row]
//        cell.imageSelected.isHidden = true
        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            // The cell may have been recycled by the time this handler gets called;
            // set the cell's thumbnail image only if it's still showing the same asset.
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.thumbImage = image
            }
        })
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print("Move")
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //let cell = collectionView.cellForItem(at: indexPath) as! TrainingViewCell
        let asset = imageAssets[indexPath.row]
        print("Width:\(asset.pixelWidth), Height:\(asset.pixelHeight)")
        let sizeToFit = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        imageManager.requestImage(for: asset, targetSize: sizeToFit, contentMode: .aspectFill, options: nil,resultHandler:  { image, _ in
            self.previewImg = image
        })
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
