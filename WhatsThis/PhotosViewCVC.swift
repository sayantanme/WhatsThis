//
//  PhotosViewCVC.swift
//  WhatsThis
//
//  Created by Sayantan Chakraborty on 16/05/17.
//  Copyright © 2017 Sayantan Chakraborty. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "Cell"

class PhotosViewCVC: UICollectionViewController,UICollectionViewDelegateFlowLayout {

    var assetCollection: PHAssetCollection?
    var fetchResult: PHFetchResult<PHAsset>?
    fileprivate var thumbnailSize: CGSize!
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var selectedImageIdentifiers = [String]()
    var selectedImageAssets = [PHAsset]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(GallertImageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ status in
                if status == .authorized {
                    self.fetchGalleryPhotos()
                }else {
                    print("Photos Authorization needed")
                }
            })
        }else if photos == .authorized {
            fetchGalleryPhotos()
        }
        
    }

    func fetchGalleryPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let collection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        
        collection.enumerateObjects({ (assetColl, index, bool) in
            let a = assetColl as PHAssetCollection
            if a.localizedTitle! == "Camera Roll"{
                self.fetchResult = PHAsset.fetchAssets(in: a, options: fetchOptions)
                //print(self.fetchResult)
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            }
            
        })
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Determine the size of the thumbnails to request from the PHCachingImageManager
        let scale = UIScreen.main.scale
        let cellSize = (collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func doneImageChoosing(_ sender: UIBarButtonItem) {
//        let trainVc = TrainingImagesVC()
//        //scanVc.isActionAdd = true
//        trainVc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
//        trainVc.modalTransitionStyle = .coverVertical
//        present(trainVc, animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.destination is TrainingImagesVC {
            let dest = segue.destination as! TrainingImagesVC
            dest.imageAssets = selectedImageAssets
        }
    }
 

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard (fetchResult != nil) else{
            return 0
        }
        return (fetchResult?.count)!
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GallertImageCell
        let asset = fetchResult?.object(at: indexPath.row)
        cell.imageSelected.isHidden = true
        cell.representedAssetIdentifier = asset?.localIdentifier
        imageManager.requestImage(for: asset!, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            // The cell may have been recycled by the time this handler gets called;
            // set the cell's thumbnail image only if it's still showing the same asset.
            if cell.representedAssetIdentifier == asset?.localIdentifier {
                cell.thumbnailImage = image
            }
        })
        if selectedImageIdentifiers.contains(cell.representedAssetIdentifier!) {
            cell.imageSelected.isHidden = false
        }
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! GallertImageCell
        let asset = fetchResult?.object(at: indexPath.row)
        if !cell.imageSelected.isHidden {
            cell.imageSelected.isHidden = true
            if let index = selectedImageIdentifiers.index(of: (asset?.localIdentifier)!){
                selectedImageIdentifiers.remove(at: index)
            }
            if let index = selectedImageAssets.index(of: (asset)!){
                selectedImageAssets.remove(at: index)
            }
            
        }else {
            cell.imageSelected.isHidden = false
            //cell.galleryImage.addBlur()
            selectedImageIdentifiers.append((asset?.localIdentifier)!)
            selectedImageAssets.append(asset!)
        }
        self.navigationItem.title = "Selected items \(selectedImageIdentifiers.count)"
    }
    
}