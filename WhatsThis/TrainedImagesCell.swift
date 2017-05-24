//
//  TrainedImagesCell.swift
//  WhatsThis
//
//  Created by Sayantan Chakraborty on 24/05/17.
//  Copyright © 2017 Sayantan Chakraborty. All rights reserved.
//

import UIKit

class TrainedImagesCell: UITableViewCell {

    @IBOutlet weak var txtTrainedName: UITextView!
    @IBOutlet weak var btnTrain: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
