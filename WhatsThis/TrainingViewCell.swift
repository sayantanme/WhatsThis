//
//  TrainingViewCell.swift
//  WhatsThis
//
//  Created by Sayantan Chakraborty on 19/05/17.
//  Copyright © 2017 Sayantan Chakraborty. All rights reserved.
//

import UIKit

class TrainingViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgViewTraining: UIImageView!
    var representedAssetIdentifier:String?
    
    var thumbImage: UIImage! {
        didSet {
            imgViewTraining.image = thumbImage
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgViewTraining.image = nil
    }
}
