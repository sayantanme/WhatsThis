//
//  GallertImageCell.swift
//  WhatsThis
//
//  Created by Sayantan Chakraborty on 17/05/17.
//  Copyright © 2017 Sayantan Chakraborty. All rights reserved.
//

import UIKit

class GallertImageCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageSelected: UIImageView!
    @IBOutlet weak var galleryImage: UIImageView!
    var representedAssetIdentifier:String?
    
    var thumbnailImage: UIImage! {
        didSet {
            galleryImage.image = thumbnailImage
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        galleryImage.image = nil
    }
}
