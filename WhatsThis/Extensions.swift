//
//  Extensions.swift
//  WhatsThis
//
//  Created by Sayantan Chakraborty on 19/05/17.
//  Copyright © 2017 Sayantan Chakraborty. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func addBlur(){
        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
    }
}
