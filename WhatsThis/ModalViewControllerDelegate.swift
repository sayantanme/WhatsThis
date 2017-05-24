//
//  ModalViewControllerDelegate.swift
//  WhatsThis
//
//  Created by Sayantan Chakraborty on 21/05/17.
//  Copyright © 2017 Sayantan Chakraborty. All rights reserved.
//

import Foundation
import Photos

protocol ModalViewControllerDelegate {
    func returnValue( value: String,imageAssets:[PHAsset], zipPath:URL, selectionMode:Bool)
}
